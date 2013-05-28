//
//  GLLight.m
//
//  GLView Project
//  Version 1.5.1
//
//  Created by Nick Lockwood on 17/05/2012.
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

#import "GLLight.h"


@implementation GLLight

- (id)init
{
    if ((self = [super init]))
    {
        self.ambientColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
        self.diffuseColor = [UIColor whiteColor];
        self.specularColor = [UIColor whiteColor];
        self.transform = CATransform3DMakeTranslation(0.0f, 0.0f, 1.0f);
    }
    return self;
}

- (void)bind:(GLuint)light
{
    //enable light(ing)
    glEnable(GL_COLOR_MATERIAL);
    glEnable(GL_LIGHTING);
    glEnable(light);
    
    //set colors
    GLfloat color[4];
    [self.ambientColor getGLComponents:color];
    glLightfv(light, GL_AMBIENT, color);
    [self.diffuseColor getGLComponents:color];
    glLightfv(light, GL_DIFFUSE, color);
    [self.specularColor getGLComponents:color];
    glLightfv(light, GL_SPECULAR, color);
    
    //set position
    GLfloat position[4] = {self.transform.m41, self.transform.m42, self.transform.m43, self.transform.m44};
    glLightfv(light, GL_POSITION, position);
}

@end
