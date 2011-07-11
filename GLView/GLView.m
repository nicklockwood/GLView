//
//  GLView.m
//
//  Created by Nick Lockwood on 10/07/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "GLView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


@interface GLView ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) GLint framebufferWidth;
@property (nonatomic, assign) GLint framebufferHeight;
@property (nonatomic, assign) GLuint defaultFramebuffer;
@property (nonatomic, assign) GLuint colorRenderbuffer;

- (void)createFramebuffer;
- (void)deleteFramebuffer;

@end


@implementation GLView

@synthesize context;
@synthesize framebufferWidth;
@synthesize framebufferHeight;
@synthesize defaultFramebuffer;
@synthesize colorRenderbuffer;

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

#pragma mark -
#pragma mark View lifecyle

- (void)setup
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
    [self createFramebuffer];
}

- (id)initWithCoder:(NSCoder*)coder
{
	if ((self = [super initWithCoder:coder]))
    {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
    {
        [self setup];
    }
    return self;
}

- (void)layoutSubviews
{
    //rebuild framebuffer
    [self deleteFramebuffer];
    [self createFramebuffer];
}

- (void)dealloc
{
    [self deleteFramebuffer];
    if ([EAGLContext currentContext] == context)
    {
        [EAGLContext setCurrentContext:nil];
    }
    [context release];
    [super dealloc];
}

- (void)createFramebuffer
{
    [EAGLContext setCurrentContext:context];
    
    //create default framebuffer object
    glGenFramebuffers(1, &defaultFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
    
    //create color render buffer and allocate backing store
    glGenRenderbuffers(1, &colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
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
}

- (void)bindFramebuffer
{
    [EAGLContext setCurrentContext:context];
    
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
    glViewport(0, 0, framebufferWidth, framebufferHeight);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(0, self.bounds.size.width, self.bounds.size.height, 0, -1.0, 1.0);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

- (BOOL)presentFramebuffer
{
    [EAGLContext setCurrentContext:context];
    
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    return [context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
