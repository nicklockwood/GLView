//
//  GLModelView.h
//
//  GLView Project
//  Version 1.5.1
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

#import "GLModelView.h"


@implementation GLModelView

- (void)setUp
{
	[super setUp];
    
	self.fov = M_PI_2;
    
    GLLight *light = [[GLLight alloc] init];
    light.transform = CATransform3DMakeTranslation(-0.5f, 1.0f, 0.5f);
    self.lights = @[light];
    
    _modelTransform = CATransform3DIdentity;
}

- (void)setLights:(NSArray *)lights
{
    if (_lights != lights)
    {
        _lights = lights;
        [self setNeedsDisplay];
    }
}

- (void)setModel:(GLModel *)model
{
    if (_model != model)
    {
        _model = model;
        [self setNeedsDisplay];
    }
}

- (void)setBlendColor:(UIColor *)blendColor
{
    if (_blendColor != blendColor)
    {
        _blendColor = blendColor;
        [self setNeedsDisplay];
    }
}

- (void)setTexture:(GLImage *)texture
{
    if (_texture != texture)
    {
        _texture = texture;
        [self setNeedsDisplay];
    }
}

- (void)setModelTransform:(CATransform3D)modelTransform
{
    _modelTransform = modelTransform;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    //apply lights
    if ([self.lights count])
    {
        //normalize normals
        glEnable(GL_NORMALIZE);
        
        for (int i = 0; i < GL_MAX_LIGHTS; i++)
        {
            if (i < [self.lights count])
            {
                [(self.lights)[i] bind:GL_LIGHT0 + i];
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
    
    //apply model transform
    glLoadMatrixf((GLfloat *)&_modelTransform);
    
    //set texture
    [self.blendColor ?: [UIColor whiteColor] bindGLColor];
    if (self.texture)
    {
        [self.texture bindTexture];
    }
    else
    {
        glDisable(GL_TEXTURE_2D);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    }
    
    //render the model
    [self.model draw];
}

@end
