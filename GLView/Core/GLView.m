//
//  GLView.m
//
//  GLView Project
//  Version 1.2.1
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
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


@interface GLView ()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLint framebufferWidth;
@property (nonatomic, assign) GLint framebufferHeight;
@property (nonatomic, assign) GLuint defaultFramebuffer;
@property (nonatomic, assign) GLuint colorRenderbuffer;
@property (nonatomic, assign) GLuint depthRenderbuffer;
@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic, assign) CADisplayLink *timer;

- (void)createFramebuffer;
- (void)deleteFramebuffer;

@end


@implementation GLView

@synthesize context;
@synthesize framebufferWidth;
@synthesize framebufferHeight;
@synthesize defaultFramebuffer;
@synthesize colorRenderbuffer;
@synthesize depthRenderbuffer;
@synthesize lastTime;
@synthesize elapsedTime;
@synthesize timer;
@synthesize fov;
@synthesize near;
@synthesize far;

- (void)dealloc
{
    [self deleteFramebuffer];
    if ([EAGLContext currentContext] == context)
    {
        [EAGLContext setCurrentContext:nil];
    }
    AH_RELEASE(context);
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
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1
                                    sharegroup:[[self class] sharedContext].sharegroup];
    
    //create framebuffer
    framebufferWidth = 0.0f;
    framebufferHeight = 0.0f;
    [self createFramebuffer];
	
	//defaults
	fov = 0.0f; //orthographic
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

- (void)setFov:(CGFloat)_fov
{
	fov = _fov;
	[self setNeedsLayout];
}

- (void)setNear:(CGFloat)_near
{
	near = _near;
	[self setNeedsLayout];
}

- (void)setFar:(CGFloat)_far
{
	far = _far;
	[self setNeedsLayout];
}

- (void)layoutSubviews
{
    //rebuild framebuffer
    [self deleteFramebuffer];
    [self createFramebuffer];
}

- (void)createFramebuffer
{
    [EAGLContext setCurrentContext:context];
    
    //create default framebuffer object
    glGenFramebuffers(1, &defaultFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
    
    //set up color render buffer
    glGenRenderbuffers(1, &colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
    
    //set up depth buffer
    glGenRenderbuffers(1, &depthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, framebufferWidth, framebufferHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);

    //check success
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}

- (void)deleteFramebuffer
{
    [EAGLContext setCurrentContext:context];
    
    if (defaultFramebuffer)
    {
        glDeleteFramebuffers(1, &defaultFramebuffer);
        defaultFramebuffer = 0;
    }
    
    if (colorRenderbuffer)
    {
        glDeleteRenderbuffers(1, &colorRenderbuffer);
        colorRenderbuffer = 0;
    }
    
    if (depthRenderbuffer)
    {
        glDeleteRenderbuffers(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}

- (void)bindFramebuffer
{
    [EAGLContext setCurrentContext:context];
    
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
	glViewport(0, 0, framebufferWidth, framebufferHeight);
	
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	if (fov <= 0.0f)
	{
		GLfloat _near = near ?: (-framebufferWidth * 0.5f);
		GLfloat _far = far ?: (framebufferWidth * 0.5f);
    	glOrthof(0, framebufferWidth, framebufferHeight, 0.0f, _near, _far);
	}
	else
	{
		GLfloat _near = (near > 0.0f)? near: 1.0f;
		GLfloat _far = (far > near)? far: (_near + 50.0f);
		GLfloat aspect = (GLfloat)framebufferWidth / (GLfloat)framebufferHeight;
		GLfloat top = tanf(fov * 0.5f) * _near;
		glFrustumf(aspect * -top, aspect * top, -top, top, _near, _far);
		glTranslatef(0.0f, 0.0f, -_near);
	}
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

- (BOOL)presentFramebuffer
{
    [EAGLContext setCurrentContext:context];
    
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    return [context presentRenderbuffer:GL_RENDERBUFFER];
}


#pragma mark Animation

- (void)startAnimating
{
	lastTime = CACurrentMediaTime();
	elapsedTime = 0.0;
	if (!timer)
	{
		timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(step)];
		[timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
	}
}

- (void)stopAnimating
{
	[timer invalidate];
	timer = nil;
}

- (BOOL)isAnimating
{
	return timer != nil;
}

- (void)step
{
	//update time
	NSTimeInterval currentTime = CACurrentMediaTime();
	NSTimeInterval deltaTime = currentTime - lastTime;
	elapsedTime += deltaTime;
	lastTime = currentTime;
	
	//step animation
	[self step:deltaTime];
	
	//update view
	[self setNeedsLayout];
}

- (void)step:(NSTimeInterval)dt
{
	//override this
}

@end
