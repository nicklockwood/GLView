//
//  GLView.m
//
//  GLView Project
//  Version 1.6.1
//
//  Created by Nick Lockwood on 10/07/2011.
//  Copyright 2011 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/GLView
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "GLView.h"


#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"
#pragma GCC diagnostic ignored "-Wdirect-ivar-access"
#pragma GCC diagnostic ignored "-Wconversion"
#pragma GCC diagnostic ignored "-Wgnu"


@interface GLLayer : CAEAGLLayer

@end


@interface GLView ()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) CGSize previousSize;
@property (nonatomic, assign) GLint framebufferWidth;
@property (nonatomic, assign) GLint framebufferHeight;
@property (nonatomic, assign) GLuint defaultFramebuffer;
@property (nonatomic, assign) GLuint colorRenderbuffer;
@property (nonatomic, assign) GLuint depthRenderbuffer;
@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic, assign, getter = isAnimating) BOOL animating;
@property (nonatomic, unsafe_unretained) NSTimer *timer;

@end


@implementation GLLayer

- (void)render
{
    //get view
    GLView *view = (GLView *)self.delegate;
    
    //bind context and frame buffer
    [view bindFramebuffer];
    
    //clear view
    [view.backgroundColor ?: [UIColor clearColor] bindGLClearColor];
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //apply transform
    GLLoadCATransform3D(view.contentTransform);
    
    //do drawing
    if (view.fov <= 0.0f)
    {
        [view drawRect:view.bounds];
    }
    else
    {
        [view drawRect:CGRectMake(-1.0f, -1.0f, 2.0f, 2.0f)];
    }
}

- (void)display
{
    //get view
    GLView *view = (GLView *)self.delegate;
    
    //render
    [self render];
    
    //present
    [view presentRenderbuffer];
}

- (void)renderInContext:(CGContextRef)ctx
{
    //get view
    GLView *view = (GLView *)self.delegate;
    
    //render
    [self render];
    
    //read pixel data from the framebuffer
    NSInteger width = view.framebufferWidth;
    NSInteger height = view.framebufferHeight;
    NSInteger dataLength = width * height * 4;
    GLubyte *data = (GLubyte *)malloc(dataLength * sizeof(GLubyte));
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    //create CGImage with the pixel data
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef image = CGImageCreate(width, height, 8, 32, width * 4, colorspace, (CGBitmapInfo)(kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast), dataProvider, NULL, true, kCGRenderingIntentDefault);
    
    //render image in current context
    CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height), image);
    
    //render sublayers
    for (CALayer *layer in self.sublayers)
    {
        CGContextSaveGState(ctx);
        CGContextTranslateCTM(ctx, layer.frame.origin.x, layer.frame.origin.y);
        [layer renderInContext:ctx];
        CGContextRestoreGState(ctx);
    }
    
    //clean up
    free(data);
    CFRelease(dataProvider);
    CFRelease(colorspace);
    CGImageRelease(image);
}

@end


@implementation GLView

- (void)dealloc
{
    [self deleteFramebuffer];
    if ([EAGLContext currentContext] == _context)
    {
        [EAGLContext setCurrentContext:nil];
    }
}

+ (EAGLContext *)sharedContext
{
    //this is used to allow texture sharing, and initialisation
    //of GLImages when no GLView has been created yet
    static EAGLContext *sharedContext = nil;
    if (sharedContext == nil)
    {
        sharedContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    }
    return sharedContext;
}

+ (Class)layerClass
{
    return [GLLayer class];
}

- (void)setUp
{
    //set up layer
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.contentsScale = [UIScreen mainScreen].scale;
    eaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: @NO,
                                    kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
    
    //create context
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1
                                     sharegroup:[[self class] sharedContext].sharegroup];
    
    //create framebuffer
    _framebufferWidth = 0.0f;
    _framebufferHeight = 0.0f;
    _previousSize = CGSizeZero;
    [self createFramebuffer];
	
	//defaults
	_fov = 0.0f; //orthographic
    _frameInterval = 1.0/60.0; // 60 fps
    _contentTransform = CATransform3DIdentity;
}

- (id)initWithCoder:(NSCoder*)coder
{
	if ((self = [super initWithCoder:coder]))
    {
        [self setUp];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
    {
        [self setUp];
    }
    return self;
}

- (void)setFov:(CGFloat)fov
{
	_fov = fov;
	[self setNeedsDisplay];
}

- (void)setNear:(CGFloat)near
{
	_near = near;
	[self setNeedsDisplay];
}

- (void)setFar:(CGFloat)far
{
	_far = far;
	[self setNeedsDisplay];
}

- (void)setContentTransform:(CATransform3D)transform
{
    _contentTransform = transform;
    [self setNeedsDisplay];
}

- (void)setFrameInterval:(NSTimeInterval)frameInterval
{
    if (ABS(_frameInterval - frameInterval) < 0.001)
    {
        _frameInterval = frameInterval;
        if (self.animating)
        {
            [self.timer invalidate];
            [self startTimer];
        }
    }
}

- (void)layoutSubviews
{
    CGSize size = self.bounds.size;
    if (!CGSizeEqualToSize(size, self.previousSize))
    {
        //rebuild framebuffer
        [self deleteFramebuffer];
        [self createFramebuffer];
        
        //update size
        self.previousSize = size;
    }
}

- (void)createFramebuffer
{
    [EAGLContext setCurrentContext:self.context];
    
    //create default framebuffer object
    glGenFramebuffersOES(1, &_defaultFramebuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, self.defaultFramebuffer);
    
    //set up color render buffer
    glGenRenderbuffersOES(1, &_colorRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, self.colorRenderbuffer);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, self.colorRenderbuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer *)self.layer];
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &_framebufferWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &_framebufferHeight);
    
    //set up depth buffer
    glGenRenderbuffersOES(1, &_depthRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, self.depthRenderbuffer);
    glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, self.framebufferWidth, self.framebufferHeight);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, self.depthRenderbuffer);
    
    //check success
    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
    {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
    }
}

- (void)deleteFramebuffer
{
    [EAGLContext setCurrentContext:self.context];
    
    if (_defaultFramebuffer)
    {
        glDeleteFramebuffersOES(1, &_defaultFramebuffer);
        self.defaultFramebuffer = 0;
    }
    
    if (_colorRenderbuffer)
    {
        glDeleteRenderbuffersOES(1, &_colorRenderbuffer);
        self.colorRenderbuffer = 0;
    }
    
    if (_depthRenderbuffer)
    {
        glDeleteRenderbuffersOES(1, &_depthRenderbuffer);
        self.depthRenderbuffer = 0;
    }
}

- (void)bindFramebuffer
{
    [EAGLContext setCurrentContext:self.context];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, self.defaultFramebuffer);
	glViewport(0, 0, _framebufferWidth, self.framebufferHeight);
	
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	if (self.fov <= 0.0f)
	{
		GLfloat near = self.near ?: (-self.framebufferWidth * 0.5f);
		GLfloat far = self.far ?: (self.framebufferWidth * 0.5f);
    	glOrthof(-self.bounds.size.width / 2.0f, self.bounds.size.width / 2.0,
                 self.bounds.size.height / 2.0f, -self.bounds.size.height / 2.0f, near, far);
	}
	else
	{
		GLfloat near = (self.near > 0.0f)? self.near: 1.0f;
		GLfloat far = (self.far > self.near)? self.far: (near + 50.0f);
		GLfloat aspect = self.bounds.size.width / self.bounds.size.height;
		GLfloat top = tanf(self.fov * 0.5f) * near;
		glFrustumf(aspect * -top, aspect * top, -top, top, near, far);
		glTranslatef(0.0f, 0.0f, -near);
	}
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

- (BOOL)presentRenderbuffer
{
    [EAGLContext setCurrentContext:self.context];
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, self.colorRenderbuffer);
    return [self.context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void)display
{
    [self.layer display];
}

- (void)drawRect:(__unused CGRect)rect
{
    //override this
}

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	if (!self.superview)
	{
        //pause
		[self.timer invalidate];
        self.timer = nil;
	}
    else if (!self.timer && self.animating)
    {
        //resume
        [self startTimer];
        [self step];
    }
}


#pragma mark Animation

- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.frameInterval
                                                  target:self
                                                selector:@selector(step)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)startAnimating
{
    self.animating = YES;
	self.lastTime = CACurrentMediaTime();
	self.elapsedTime = 0.0;
	if (!self.timer)
	{
		[self startTimer];
	}
}

- (void)stopAnimating
{
	[self.timer invalidate];
	self.timer = nil;
    self.animating = NO;
}

- (BOOL)shouldStopAnimating
{
    //override this
    return NO;
}

- (void)step
{
	//update time
	NSTimeInterval currentTime = CACurrentMediaTime();
	NSTimeInterval deltaTime = currentTime - self.lastTime;
	self.elapsedTime += deltaTime;
	self.lastTime = currentTime;
    
    //step animation
    [self step:deltaTime];
    
    //update view
    [self setNeedsDisplay];
    
    //check if finished
    if ([self shouldStopAnimating])
    {
        [self stopAnimating];
    }
}

- (void)step:(__unused NSTimeInterval)dt
{
	//override this
}


#pragma mark Screen capture

- (UIImage *)snapshot
{
    //create image context
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.layer.contentsScale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //render the image
    [self.layer renderInContext:context];
    
    //retrieve the image from the current context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
