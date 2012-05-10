//
//  GLModelView.h
//
//  GLView Project
//  Version 1.2
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
@synthesize transform;

- (void)setUp
{
	[super setUp];
    
	self.fov = M_PI_2;
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
	
	//apply transform
    glLoadMatrixf((GLfloat *)&transform);
    
    [blendColor ?: [UIColor whiteColor] bindGLBlendColor];
    texture? [texture bindTexture]: glBindTexture(GL_TEXTURE_2D, 0);
    [model draw];
	
    [self presentFramebuffer];
}

- (void)dealloc
{
    AH_RELEASE(texture);
    AH_RELEASE(blendColor);
    AH_RELEASE(model);
    AH_SUPER_DEALLOC;
}

@end
