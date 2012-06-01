//
//  GLModelView.h
//
//  GLView Project
//  Version 1.2.2
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

#import "GLModelView.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "UIColor+GL.h"


@implementation GLModelView

@synthesize model;
@synthesize texture;
@synthesize blendColor;
@synthesize lights;
@synthesize transform;

- (void)setUp
{
	[super setUp];
    
	self.fov = M_PI_2;
    
    GLLight *light = [[GLLight alloc] init];
    light.transform = CATransform3DMakeTranslation(-0.5f, 1.0f, 0.5f);
    self.lights = [NSArray arrayWithObject:light];
    AH_RELEASE(light);
}

- (void)setLights:(NSArray *)_lights
{
    if (lights != _lights)
    {
        AH_RELEASE(lights);
        lights = AH_RETAIN(_lights);
        [self setNeedsLayout];
    }
}

- (void)setModel:(GLModel *)_model
{
    if (model != _model)
    {
        AH_RELEASE(model);
        model = AH_RETAIN(_model);
        [self setNeedsLayout];
    }
}

- (void)setBlendColor:(UIColor *)_blendColor
{
    if (blendColor != _blendColor)
    {
        AH_RELEASE(blendColor);
        blendColor = AH_RETAIN(_blendColor);
        [self setNeedsLayout];
    }
}

- (void)setTexture:(GLImage *)_texture
{
    if (texture != _texture)
    {
        AH_RELEASE(texture);
        texture = AH_RETAIN(_texture);
        [self setNeedsLayout];
    }
}

- (void)setTransform:(CATransform3D)_transform
{
    transform = _transform;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self bindFramebuffer];
	
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT + GL_DEPTH_BUFFER_BIT);
    
    //apply lights
    if ([lights count])
    {
        //normalize normals
        glEnable(GL_NORMALIZE);
        
        for (int i = 0; i < GL_MAX_LIGHTS; i++)
        {
            if (i < [lights count])
            {
                [[lights objectAtIndex:i] bind:GL_LIGHT0 + i];
            }
            else
            {
                glDisable(GL_LIGHT0 + i);
            }
        }
    }
    else
    {
        glDisable(GL_LIGHTING);
    }
    
    //apply transform
    glLoadMatrixf((GLfloat *)&transform);

    [blendColor ?: [UIColor whiteColor] bindGLBlendColor];
    if (texture)
    {
        [texture bindTexture];
    }
    else
    {
        glDisable(GL_TEXTURE_2D);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_COLOR);
    }
    [model draw];
	
    [self presentFramebuffer];
}

- (void)dealloc
{
    AH_RELEASE(lights);
    AH_RELEASE(texture);
    AH_RELEASE(blendColor);
    AH_RELEASE(model);
    AH_SUPER_DEALLOC;
}

@end
