//
//  GLUtils.m
//
//  GLView Project
//  Version 1.6.1
//
//  Created by Nick Lockwood on 04/06/2012.
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

#import "GLUtils.h"
#import <objc/message.h>


#import <Availability.h>
#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif


#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"
#pragma GCC diagnostic ignored "-Wdirect-ivar-access"
#pragma GCC diagnostic ignored "-Wgnu"


#pragma mark-
#pragma mark Public utils


void CGRectGetGLCoords(CGRect rect, GLfloat *coords)
{
    coords[0] = (GLfloat)rect.origin.x;
    coords[1] = (GLfloat)rect.origin.y;
    coords[2] = (GLfloat)(rect.origin.x + rect.size.width);
    coords[3] = (GLfloat)rect.origin.y;
    coords[4] = (GLfloat)(rect.origin.x + rect.size.width);
    coords[5] = (GLfloat)(rect.origin.y + rect.size.height);
    coords[6] = (GLfloat)rect.origin.x;
    coords[7] = (GLfloat)(rect.origin.y + rect.size.height);
}


void GLLoadCATransform3D(CATransform3D transform)
{
    GLfloat matrix[16];
    for (int i = 0; i < 16; i++)
    {
        matrix[i] = (GLfloat)((CGFloat *)&transform)[i];
    }
    glLoadMatrixf(matrix);
}


@implementation UIColor (GL)

- (void)getGLComponents:(GLfloat *)rgba
{
    CGColorSpaceModel model = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    switch (model)
    {
        case kCGColorSpaceModelMonochrome:
        {
            rgba[0] = (GLfloat)components[0];
            rgba[1] = (GLfloat)components[0];
            rgba[2] = (GLfloat)components[0];
            rgba[3] = (GLfloat)components[1];
            break;
        }
        case kCGColorSpaceModelRGB:
        {
            rgba[0] = (GLfloat)components[0];
            rgba[1] = (GLfloat)components[1];
            rgba[2] = (GLfloat)components[2];
            rgba[3] = (GLfloat)components[3];
            break;
        }
        case kCGColorSpaceModelCMYK:
        case kCGColorSpaceModelDeviceN:
        case kCGColorSpaceModelIndexed:
        case kCGColorSpaceModelLab:
        case kCGColorSpaceModelPattern:
        case kCGColorSpaceModelUnknown:
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
    glClearColor(rgba[0] * rgba[3], rgba[1] * rgba[3], rgba[2] * rgba[3], rgba[3]);
}

- (void)bindGLColor
{    
    GLfloat rgba[4];
    [self getGLComponents:rgba];
    glColor4f(rgba[0], rgba[1], rgba[2], rgba[3]);
}

@end


#pragma mark -
#pragma mark Private utils


@implementation NSData (GL)

- (BOOL)GL_isGzippedData
{
    UInt8 *bytes = (UInt8 *)[self bytes];
    return ([self length] >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b);
}

- (NSData *)GL_unzippedData
{
    if ([self GL_isGzippedData])
    {
        //attempt to unzip using GZIP library
        if ([self respondsToSelector:NSSelectorFromString(@"gunzippedData")])
        {
            return [self valueForKey:@"gunzippedData"];
        }
        else
        {
            NSLog(@"The GZIP library is require to load gzipped files");
            return nil;
        }
    }
    return self;
}

@end


@implementation NSDictionary (GL)

+ (NSDictionary *)GL_dictionaryWithData:(NSData *)data
{
    //attempt to unzip data
    data = [data GL_unzippedData];
    
    //deserialize
    return data? [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:NULL]: nil;
}

@end


@implementation NSString (GL)

- (NSString *)GL_pathExtension
{
    NSString *extension = [self pathExtension];
    if ([extension isEqualToString:@"gz"])
    {
        extension = [[self stringByDeletingPathExtension] pathExtension];
        if ([extension length]) return [extension stringByAppendingPathExtension:@"gz"];
        return @"gz";
    }
    return extension;
}


- (NSString *)GL_stringByDeletingPathExtension
{
    NSString *extension = [self pathExtension];
    NSString *path = [self stringByDeletingPathExtension];
    if ([extension isEqualToString:@"gz"])
    {
        path = [path stringByDeletingPathExtension];
    }
    return path;
}

- (BOOL)GL_hasRetinaFileSuffix
{
    SEL pathScaleSelector = NSSelectorFromString(@"scaleFromSuffix");
    if ([self respondsToSelector:pathScaleSelector])
    {
        return [[self valueForKey:@"scaleFromSuffix"] floatValue] == 2.0f;
    }
    else
    {
        NSString *name = [self GL_stringByDeletingPathExtension];
        if ([name hasSuffix:@"~ipad"]) name = [name substringToIndex:[name length] - 5];
        if ([name hasSuffix:@"~iphone"]) name = [name substringToIndex:[name length] - 7];
        if ([name hasSuffix:@"@2x"]) return YES;
    }
    return NO;
}

- (NSString *)GL_stringByDeletingRetinaSuffix
{
    SEL selector = NSSelectorFromString(@"stringByDeletingRetinaSuffix");
    if ([self respondsToSelector:selector])
    {
        return [self valueForKey:@"stringByDeletingRetinaSuffix"];
    }
    NSString *result = [self stringByDeletingPathExtension];
    if ([result hasSuffix:@"@2x"])
    {
        //TODO: handle ~ipad/~iphone
        result = [result substringToIndex:[result length] - 3];
        return [result stringByAppendingPathExtension:[self pathExtension]];
    }
    return self;
}

- (NSString *)GL_normalizedPathWithDefaultExtension:(NSString *)extension
{
    //extension
    NSString *path = self;
    if (![[self pathExtension] length])
    {
        path = [path stringByAppendingPathExtension:extension];
    }
    else
    {
        extension = [path GL_pathExtension];
    }
    
    //use StandardPaths if available
    SEL normalizedPathSelector = NSSelectorFromString(@"normalizedPathForFile:");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager respondsToSelector:normalizedPathSelector])
    {
        return ((id (*)(id, SEL, id))objc_msgSend)(fileManager, normalizedPathSelector, path);
    }
    
    //convert to absolute path
    if (![self isAbsolutePath])
    {
        path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path];
    }
    
    //check for @2x version
    if ([UIScreen mainScreen].scale == 2.0f)
    {
        NSString *retinaPath = [[[path GL_stringByDeletingPathExtension] stringByAppendingString:@"@2x"] stringByAppendingPathExtension:extension];
        if ([fileManager fileExistsAtPath:retinaPath])
        {
            path = retinaPath;
        }
    }
    
    //check for ~ipad or ~iphone version
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        NSString *iPadPath = [[[path GL_stringByDeletingPathExtension] stringByAppendingString:@"~ipad"] stringByAppendingPathExtension:extension];
        if ([fileManager fileExistsAtPath:iPadPath])
        {
            path = iPadPath;
        }
    }
    else
    {
        NSString *iPhonePath = [[[path GL_stringByDeletingPathExtension] stringByAppendingString:@"~iphone"] stringByAppendingPathExtension:extension];
        if ([fileManager fileExistsAtPath:iPhonePath])
        {
            path = iPhonePath;
        }
    }
    
    //default path
    return [fileManager fileExistsAtPath:path]? path: nil;
}

@end
