//
//  GLUtils.m
//
//  GLView Project
//  Version 1.3.2
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


void CGRectGetGLCoords(CGRect rect, GLfloat *coords)
{
    coords[0] = rect.origin.x;
    coords[1] = rect.origin.y;
    coords[2] = rect.origin.x + rect.size.width;
    coords[3] = rect.origin.y;
    coords[4] = rect.origin.x + rect.size.width;
    coords[5] = rect.origin.y + rect.size.height;
    coords[6] = rect.origin.x;
    coords[7] = rect.origin.y + rect.size.height;
}


@implementation NSString (GL)

- (NSString *)stringByAppendingScaleSuffix
{
    if ([UIScreen mainScreen].scale > 1.0f)
    {
        NSString *extension = [self pathExtension];
        NSString *deviceSuffix = [self interfaceIdiomSuffix];
        NSString *scaleSuffix = [NSString stringWithFormat:@"@%ix", (int)[UIScreen mainScreen].scale];
        NSString *path = [[self stringByDeletingPathExtension] stringByDeletingInterfaceIdiomSuffix];
        return [[path stringByAppendingFormat:@"%@%@", scaleSuffix, deviceSuffix] stringByAppendingPathExtension:extension];
    }
    return self;
}

- (NSString *)stringByDeletingScaleSuffix
{
    NSString *scaleSuffix = [self scaleSuffix];
    if ([scaleSuffix length])
    {
        NSString *extension = [self pathExtension];
        NSString *deviceSuffix = [self interfaceIdiomSuffix];
        NSString *path = [[self stringByDeletingPathExtension] stringByDeletingInterfaceIdiomSuffix];
        path = [path substringToIndex:[path length] - [scaleSuffix length]];
        return [[path stringByAppendingString:deviceSuffix] stringByAppendingPathExtension:extension];
    }
    return self;
}

- (NSString *)scaleSuffix
{
    //note: this isn't very robust as it only handles single-digit integer scales
    //for the forseeable future though, it's unlikely that we'll have to worry about that
    NSString *path = [[self stringByDeletingPathExtension] stringByDeletingInterfaceIdiomSuffix];
    if ([path length] >= 3)
    {
        NSString *scaleSuffix = [path substringFromIndex:[path length] - 3];
        if ([[scaleSuffix substringToIndex:1] isEqualToString:@"@"] &&
            [[scaleSuffix substringFromIndex:2] isEqualToString:@"x"])
        {
            return scaleSuffix;
        }
    }
    return @"";
}

- (CGFloat)scale
{
    NSString *scaleSuffix = [self scaleSuffix];
    if ([scaleSuffix length])
    {
        return [[scaleSuffix substringWithRange:NSMakeRange(1, 1)] floatValue];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [self isHD])
    {
        return 2.0f;
    }
    return 1.0f;
}

- (NSString *)stringByAppendingInterfaceIdiomSuffix
{
    NSString *extension = [self pathExtension];
    NSString *suffix = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)? @"~ipad": @"~iphone";
    return [[[self stringByDeletingPathExtension] stringByAppendingString:suffix] stringByAppendingPathExtension:extension];
}

- (NSString *)stringByDeletingInterfaceIdiomSuffix
{
    NSString *suffix = [self interfaceIdiomSuffix];
    if ([suffix length])
    {
        NSString *extension = [self pathExtension];
        NSString *path = [self stringByDeletingPathExtension];
        return [[path substringToIndex:[path length] - [suffix length]] stringByAppendingPathExtension:extension];
    }
    return self;
}

- (NSString *)interfaceIdiomSuffix
{
    NSString *path = [self stringByDeletingPathExtension];
    if ([path hasSuffix:@"~iphone"])
    {
        return @"~iphone";
    }
    else if ([path hasSuffix:@"~ipad"])
    {
        return @"~ipad";
    }
    return @"";
}

- (UIUserInterfaceIdiom)interfaceIdiom
{
    if ([[self interfaceIdiomSuffix] isEqualToString:@"~ipad"])
    {
        return UIUserInterfaceIdiomPad;
    }
    else if ([[self interfaceIdiomSuffix] isEqualToString:@"~iphone"])
    {
        return UIUserInterfaceIdiomPhone;
    }
    return UI_USER_INTERFACE_IDIOM();
}

- (NSString *)stringByAppendingHDSuffix
{
    if ([UIScreen mainScreen].scale > 1.0f || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        NSString *extension = [self pathExtension];
        NSString *deviceSuffix = [self interfaceIdiomSuffix];
        NSString *scaleSuffix = [self scaleSuffix];
        NSString *path = [[[self stringByDeletingPathExtension] stringByDeletingInterfaceIdiomSuffix] stringByDeletingScaleSuffix];
        return [[path stringByAppendingFormat:@"-hd%@%@", scaleSuffix, deviceSuffix] stringByAppendingPathExtension:extension];
    }
    return self;
}

- (NSString *)stringByDeletingHDSuffix
{
    NSString *HDSuffix = [self HDSuffix];
    if ([HDSuffix length])
    {
        NSString *extension = [self pathExtension];
        NSString *deviceSuffix = [self interfaceIdiomSuffix];
        NSString *scaleSuffix = [self scaleSuffix];
        NSString *path = [[[self stringByDeletingPathExtension] stringByDeletingInterfaceIdiomSuffix] stringByDeletingScaleSuffix];
        path = [path substringToIndex:[path length] - [HDSuffix length]];
        return [[path stringByAppendingFormat:@"%@%@", scaleSuffix, deviceSuffix] stringByAppendingPathExtension:extension];
    }
    return self;
}

- (NSString *)HDSuffix
{
    NSString *path = [[[self stringByDeletingPathExtension] stringByDeletingInterfaceIdiomSuffix] stringByDeletingScaleSuffix];
    if ([path hasSuffix:@"-hd"])
    {
        return @"-hd";
    }
    return @"";
}

- (BOOL)isHD
{
    return [[self HDSuffix] length] > 0;
}

- (NSString *)absolutePathWithDefaultExtensions:(NSString *)firstExtension, ...
{
    //set up cache
    static NSCache *cache = nil;
    if (cache == nil)
    {
        cache = [[NSCache alloc] init];
    }
    
    //convert to absolute path
    NSString *path = self;
    if (![path isAbsolutePath])
    {
        path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path];
    }

    //add file extension if not already set
    NSString *extension = [path pathExtension];
    if ([extension length] == 0)
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
    
    //check cache
    NSString *cacheKey = path;
    BOOL cachable = [path hasPrefix:[[NSBundle mainBundle] resourcePath]];
    if (cachable)
    {
        NSString *_path = [cache objectForKey:cacheKey];
        if (_path)
        {
            return [_path length]? _path: nil;
        }
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        //check for HD version
        NSString *_path = [path stringByAppendingHDSuffix];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_path])
        {
            path = _path;
        }
        
        //check for scaled version
        if ([UIScreen mainScreen].scale > 1.0f)
        {
            NSString *_path = [path stringByAppendingScaleSuffix];
            if ([[NSFileManager defaultManager] fileExistsAtPath:_path])
            {
                path = _path;
            }
        }
    }
    else if ([UIScreen mainScreen].scale > 1.0f)
    {
        //check for HD version
        NSString *_path = [path stringByAppendingHDSuffix];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_path])
        {
            path = _path;
        }
        else
        {
            //check for scaled version
            NSString *_path = [path stringByAppendingScaleSuffix];
            if ([[NSFileManager defaultManager] fileExistsAtPath:_path])
            {
                path = _path;
            }
        }
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        //check for ipad/iphone version
        NSString *_path = [path stringByAppendingInterfaceIdiomSuffix];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_path])
        {
            path = _path;
        }
    }
    else
    {
        //file doesn't exist
        path = nil;
    }
    
    //add to cache
    if (cachable)
    {
        [cache setObject:path ?: @"" forKey:cacheKey];
    }
    
    //return path
    return path;
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
