//
//  GLUtils.m
//
//  GLView Project
//  Version 1.3
//
//  Created by Nick Lockwood on 04/06/2012.
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

#import "GLUtils.h"


@implementation NSString (GL)

- (NSString *)absolutePathWithDefaultExtensions:(NSString *)firstExtension, ... NS_REQUIRES_NIL_TERMINATION
{
    //convert to absolute path
    NSString *path = self;
    if (![path isAbsolutePath])
    {
        path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path];
    }
    
    //get or add file extension
    NSString *extension = [path pathExtension];
    if ([extension isEqualToString:@""])
    {
        va_list arguments;
        va_start(arguments, firstExtension);
        extension = firstExtension;
        while (extension)
        {
            NSString *_path = [path stringByAppendingPathExtension:extension];
            if ([[NSFileManager defaultManager] fileExistsAtPath:_path])
            {
                path = _path;
                break;
            }
            extension = va_arg(arguments, NSString *);
        }
        va_end(arguments);
    }
        
    //check for scaled version
    if ([UIScreen mainScreen].scale > 1.0f)
    {
        NSString *_path = [path stringByAppendingImageScaleSuffix];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_path])
        {
            path = _path;
        }
    }
    
    //return normalised path
    return path;
}

- (NSString *)stringByAppendingImageScaleSuffix
{
    //check for scaled version
    NSString *nameOrPath = self;
    if ([UIScreen mainScreen].scale > 1.0f)
    {
        NSString *extension = [nameOrPath pathExtension];
        NSString *scaleSuffix = [NSString stringWithFormat:@"@%ix", (int)[UIScreen mainScreen].scale];
        nameOrPath = [[[nameOrPath stringByDeletingPathExtension] stringByAppendingString:scaleSuffix] stringByAppendingPathExtension:extension];
    }
    return nameOrPath;
}

- (NSString *)imageScaleSuffix
{
    NSString *nameOrPath = [self stringByDeletingPathExtension];
    if ([nameOrPath length] >= 3)
    {
        NSString *scaleSuffix = [nameOrPath substringFromIndex:[nameOrPath length] - 3];
        if ([[scaleSuffix substringToIndex:1] isEqualToString:@"@"] &&
            [[scaleSuffix substringFromIndex:2] isEqualToString:@"x"])
        {
            return scaleSuffix;
        }
    }
    return nil;
}

- (CGFloat)imageScaleValue
{
    NSString *suffix = [self imageScaleSuffix];
    return suffix? [[suffix substringWithRange:NSMakeRange(1, 1)] floatValue]: 1.0f;
}

@end


@implementation UIColor (GL)

- (void)getGLComponents:(GLfloat *)rgba
{
    CGColorSpaceModel model = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    switch (model)
    {
        case kCGColorSpaceModelMonochrome:
        {
            rgba[0] = components[0];
            rgba[1] = components[0];
            rgba[2] = components[0];
            rgba[3] = components[1];
            break;
        }
        case kCGColorSpaceModelRGB:
        {
            rgba[0] = components[0];
            rgba[1] = components[1];
            rgba[2] = components[2];
            rgba[3] = components[3];
            break;
        }
        default:
        {
            
#ifdef DEBUG
            
            //unsupported format
            NSLog(@"Unsupported color model: %i", model);
#endif
            rgba[0] = 0.0f;
            rgba[1] = 0.0f;
            rgba[2] = 0.0f;
            rgba[3] = 1.0f;
            break;
        }
    }
}

- (void)bindGLClearColor
{
    GLfloat rgba[4];
    [self getGLComponents:rgba];
    glClearColor(rgba[0], rgba[1], rgba[2], rgba[3]);
}

- (void)bindGLBlendColor
{    
    GLfloat rgba[4];
    [self getGLComponents:rgba];
    glColor4f(rgba[0], rgba[1], rgba[2], rgba[3]);
}

@end
