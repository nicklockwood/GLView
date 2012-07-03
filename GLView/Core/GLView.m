//
//  GLView.m
//
//  GLView Project
//  Version 1.3.3
//
//  Created by Nick Lockwood on 10/07/2011.
//  Copyright 2011 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from either of these locations:
//
//  http://charcoaldesign.co.uk/source/cocoa#glview
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


@interface GLView ()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) CGSize previousSize;
@property (nonatomic, assign) GLint framebufferWidth;
@property (nonatomic, assign) GLint framebufferHeight;
@property (nonatomic, assign) GLuint defaultFramebuffer;
@property (nonatomic, assign) GLuint colorRenderbuffer;
@property (nonatomic, assign) GLuint depthRenderbuffer;
@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic, unsafe_unretained) CADisplayLink *timer;

- (void)createFramebuffer;
- (void)deleteFramebuffer;

@end


@implementation GLView

@synthesize context = _context;
@synthesize previousSize = _previousSize;
@synthesize framebufferWidth = _framebufferWidth;
@synthesize framebufferHeight = _framebufferHeight;
@synthesize defaultFramebuffer = _defaultFramebuffer;
@synthesize colorRenderbuffer = _colorRenderbuffer;
@synthesize depthRenderbuffer = _depthRenderbuffer;
@synthesize lastTime = _lastTime;
@synthesize elapsedTime = _elapsedTime;
@synthesize timer = _timer;
@synthesize fov = _fov;
@synthesize near = _near;
@synthesize far = _far;

- (void)dealloc
{
    [self deleteFramebuffer];
    if ([EAGLContext currentContext] == _context)
    {
        [EAGLContext setCurrentContext:nil];
    }
    AH_RELEASE(_context);
    AH_SUPER_DEALLOC;
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
    return [CAEAGLLayer class];
}

- (void)setUp
{
    //set up layer
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.contentsScale = [UIScreen mainScreen].scale;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
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
	[self setNeedsLayout];
}

- (void)setNear:(CGFloat)near
{
	_near = near;
	[self setNeedsLayout];
}

- (void)setFar:(CGFloat)far
{
	_far = far;
	[self setNeedsLayout];
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
    glGenFramebuffers(1, &_defaultFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, self.defaultFramebuffer);
    
    //set up color render buffer
    glGenRenderbuffers(1, &_colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, self.colorRenderbuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.colorRenderbuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_framebufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_framebufferHeight);
    
    //set up depth buffer
    glGenRenderbuffers(1, &_depthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, self.depthRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.framebufferWidth, self.framebufferHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, self.depthRenderbuffer);
    
    //check success
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}

- (void)deleteFramebuffer
{
    [EAGLContext setCurrentContext:self.context];
    
    if (_defaultFramebuffer)
    {
        glDeleteFramebuffers(1, &_defaultFramebuffer);
        self.defaultFramebuffer = 0;
    }
    
    if (_colorRenderbuffer)
    {
        glDeleteRenderbuffers(1, &_colorRenderbuffer);
        self.colorRenderbuffer = 0;
    }
    
    if (_depthRenderbuffer)
    {
        glDeleteRenderbuffers(1, &_depthRenderbuffer);
        self.depthRenderbuffer = 0;
    }
}

- (void)bindFramebuffer
{
    [EAGLContext setCurrentContext:self.context];
    
    glBindFramebuffer(GL_FRAMEBUFFER, self.defaultFramebuffer);
	glViewport(0, 0, _framebufferWidth, self.framebufferHeight);
	
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	if (self.fov <= 0.0f)
	{
		GLfloat near = self.near ?: (-self.framebufferWidth * 0.5f);
		GLfloat far = self.far ?: (self.framebufferWidth * 0.5f);
    	glOrthof(0, self.bounds.size.width, self.bounds.size.height, 0.0f, near, far);
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

- (BOOL)presentFramebuffer
{
    [EAGLContext setCurrentContext:self.context];
    
    glBindRenderbuffer(GL_RENDERBUFFER, self.colorRenderbuffer);
    return [self.context presentRenderbuffer:GL_RENDERBUFFER];
}


#pragma mark Animation

- (void)startAnimating
{
	self.lastTime = CACurrentMediaTime();
	self.elapsedTime = 0.0;
	if (!self.timer)
	{
		self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(step)];
		[self.timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	}
}

- (void)stopAnimating
{
	[self.timer invalidate];
	self.timer = nil;
}

- (BOOL)isAnimating
{
	return self.timer != nil;
}

- (void)step
{
	//update time
	NSTimeInterval currentTime = CACurrentMediaTime();
	NSTimeInterval deltaTime = currentTime - self.lastTime;
	self.elapsedTime += deltaTime;
	self.lastTime = currentTime;
    
    //only draw when on-screen
    if (self.window)
    {
        //step animation
        [self step:deltaTime];
        
        //update view
        [self setNeedsLayout];
    }
}

- (void)step:(NSTimeInterval)dt
{
	//override this
}

@end
