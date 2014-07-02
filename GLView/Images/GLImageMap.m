//
//  GLImageMap.m
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

#import "GLImageMap.h"


#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"
#pragma GCC diagnostic ignored "-Wdirect-ivar-access"
#pragma GCC diagnostic ignored "-Wgnu"


@interface NSString (Private)

- (NSString *)GL_stringByDeletingPathExtension;
- (BOOL)GL_hasRetinaFileSuffix;
- (NSString *)GL_stringByDeletingRetinaSuffix;
- (NSString *)GL_normalizedPathWithDefaultExtension:(NSString *)extension;

@end


@interface NSDictionary (Private)

+ (NSDictionary *)GL_dictionaryWithData:(NSData *)data;

@end


@interface GLImage (Private)

@property (nonatomic, getter = isRotated) BOOL rotated;

@end


@interface GLImageMap ()

@property (nonatomic, copy) NSArray *imageNames;
@property (nonatomic, strong) NSMutableDictionary *imagesByName;

@end


@implementation GLImageMap

+ (instancetype)imageMapWithContentsOfFile:(NSString *)nameOrPath
{
    return [(GLImageMap *)[self alloc] initWithContentsOfFile:nameOrPath];
}

+ (instancetype)imageMapWithImage:(GLImage *)image data:(NSData *)data
{
    return [[self alloc] initWithImage:image data:data];
}

- (instancetype)init
{
    if ((self = [super init]))
    {
        _imagesByName = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)initWithContentsOfFile:(NSString *)nameOrPath
{
    //check for xc texture atlas
    NSString *dataPath = [nameOrPath GL_normalizedPathWithDefaultExtension:@"atlasc"];
    if (dataPath && [[dataPath pathExtension] isEqualToString:@"atlasc"])
    {
        if ((self = [self init]))
        {
            //load atlas
            NSString *plistPath = [dataPath stringByAppendingPathComponent:[[[dataPath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"]];
            NSDictionary *atlas = [NSDictionary dictionaryWithContentsOfFile:plistPath];
            
            //add sprites
            for (NSDictionary *dict in atlas[@"images"])
            {
                NSString *imagePath = [dataPath stringByAppendingPathComponent:dict[@"path"]];
                GLImage *image = [GLImage imageWithContentsOfFile:imagePath];
                [self addFrames:dict[@"subimages"] withImage:image scale:1.0f];
            }
            
            //set sorted image names
            self.imageNames = [[self.imagesByName allKeys] sortedArrayUsingSelector:NSSelectorFromString(@"compare:")];
        }
        return self;
    }
    else
    {
        //load cocos sprite atlas
        dataPath = [nameOrPath GL_normalizedPathWithDefaultExtension:@"plist"];
        return [self initWithImage:nil path:nameOrPath dictionary:[NSDictionary GL_dictionaryWithData:[NSData dataWithContentsOfFile:dataPath]]];
    }
}

- (instancetype)initWithImage:(GLImage *)image path:(NSString *)path dictionary:(NSDictionary *)dict
{
    //calculate scale from path
    NSString *plistPath = [path GL_normalizedPathWithDefaultExtension:@"plist"];
    CGFloat plistScale = [plistPath GL_hasRetinaFileSuffix]? 2.0f: 1.0f;
    CGFloat scale = image.scale / plistScale;

    if (dict && [dict isKindOfClass:[NSDictionary class]])
    {
        if (!image)
        {
            //generate default image path
            path = [path GL_stringByDeletingPathExtension];

            //get metadata
            NSDictionary *metadata = dict[@"metadata"];
            if (metadata)
            {
                //get image file from metadata
                NSString *imageFile = metadata[@"textureFileName"];
                if (!imageFile)
                {
                    NSDictionary *target = metadata[@"target"];
                    if (target)
                    {
                        imageFile = target[@"textureFileName"];
                        NSString *extension = target[@"textureFileExtension"];
                        if (imageFile && extension)
                        {
                            if ([extension hasPrefix:@"."])
                            {
                                imageFile = [imageFile stringByAppendingString:extension];
                            }
                            else
                            {
                                imageFile = [imageFile stringByAppendingPathExtension:extension];
                            }
                        }
                    }
                    if (!imageFile) imageFile = [path lastPathComponent];
                }
                
                //load image
                path = [[path ?: @"" stringByDeletingLastPathComponent] stringByAppendingPathComponent:imageFile];
                image = [GLImage imageWithContentsOfFile:[path GL_normalizedPathWithDefaultExtension:@"png"]];
                
                //set premultiplied property
                BOOL premultiplied = [[metadata valueForKeyPath:@"target.premultipliedAlpha"] boolValue];
                image = [image imageWithPremultipliedAlpha:premultiplied];
                
                //set scale
                scale = (image.textureSize.width / CGSizeFromString(metadata[@"size"]).width) ?: (image.scale / plistScale);
            }
            else
            {
                image = [GLImage imageWithContentsOfFile:path];
                scale = image.scale / plistScale;
            }
        }
        
        if (image)
        {
            //get frames
            NSDictionary *frames = dict[@"frames"];
            if (frames)
            {
                if ((self = [self init]))
                {
                    //add sprites
                    [self addFrames:frames withImage:image scale:scale];
                        
                    //set sorted image names
                    self.imageNames = [[self.imagesByName allKeys] sortedArrayUsingSelector:NSSelectorFromString(@"compare:")];
                }
                return self;
            }
            else
            {
                NSLog(@"ImageMap data contains no image frames");
            }
        }
        else
        {
            NSLog(@"Could not locate ImageMap texture file");
        }
    }
    else
    {
        NSLog(@"Unrecognised ImageMap data format");
    }
    
    //not a recognised data format
    return nil;
}

- (instancetype)initWithImage:(GLImage *)image data:(NSData *)data
{
    return [self initWithImage:image path:nil dictionary:[NSDictionary GL_dictionaryWithData:data]];
}

- (void)addFrames:(id)frames withImage:(GLImage *)image scale:(CGFloat)scale
{
    for (id item in frames)
    {
        //get sprite name and data
        NSString *name = nil;
        NSDictionary *sprite = nil;
        BOOL cocosFormat = [item isKindOfClass:[NSString class]];
        if (cocosFormat)
        {
            name = item;
            sprite = frames[name];
        }
        else
        {
            sprite = item;
            name = [item[@"name"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if ([name GL_hasRetinaFileSuffix])
            {
                name = [name GL_stringByDeletingRetinaSuffix];
                if (self.imagesByName[name] && [[UIScreen mainScreen] scale] < 2.0f) continue;
            }
            else if (self.imagesByName[name])
            {
                continue;
            }
        }
        
        //get clip rect
        CGRect clipRect = CGRectFromString(sprite[@"textureRect"] ?: sprite[@"frame"]);
        clipRect.origin.x *= scale;
        clipRect.origin.y *= scale;
        clipRect.size.width *= scale;
        clipRect.size.height *= scale;
        
        //get image size
        CGSize size = CGSizeFromString(sprite[@"spriteSourceSize"] ?: sprite[@"spriteSize"] ?: sprite[@"sourceSize"]);
        
        //get content rect
        CGRect contentRect = CGRectZero;
        if (cocosFormat)
        {
            contentRect = CGRectFromString(sprite[@"spriteColorRect"] ?: sprite[@"sourceColorRect"]);
        }
        else
        {
            contentRect.origin = CGPointFromString(sprite[@"spriteOffset"]);
            contentRect.size = CGRectFromString(sprite[@"textureRect"]).size;
        }
        
        //get rotation
        BOOL rotated = [sprite[@"textureRotated"] ?: sprite[@"rotated"] boolValue];
        if (rotated)
        {
            if (sprite[@"frame"])
            {
                clipRect.size = CGSizeMake(clipRect.size.height,
                                           clipRect.size.width);
            }
            else if (!cocosFormat)
            {
                contentRect.size = CGSizeMake(contentRect.size.height, contentRect.size.width);
            }
        }
        if (CGRectIsEmpty(contentRect))
        {
            contentRect = CGRectMake(0.0f, 0.0f, size.width, size.height);
        }
        else if (!cocosFormat)
        {
            contentRect.origin.y = size.height - contentRect.origin.y - contentRect.size.height;
        }
        
        //add subimage
        GLImage *subimage = [[[image imageWithClipRect:clipRect] imageWithSize:size] imageWithContentRect:contentRect];
        subimage.rotated = rotated; //TODO: replace with more robust orientation mechanism
        self.imagesByName[name] = subimage;
        
        //aliases
        for (NSString *alias in sprite[@"aliases"])
        {
            self.imagesByName[alias] = subimage;
        }
    }
}

- (NSUInteger)imageCount
{
    return [self.imagesByName count];
}

- (NSString *)imageNameAtIndex:(NSUInteger)index
{
    return self.imageNames[index];
}

- (GLImage *)imageAtIndex:(NSUInteger)index
{
    return self.imagesByName[self.imageNames[index]];
}

- (GLImage *)imageNamed:(NSString *)name
{
    GLImage *image = (self.imagesByName)[name];
    if (!image)
    {
        return self.imagesByName[[name stringByAppendingPathExtension:@"png"]];
    }
    return image;
}

- (GLImage *)objectAtIndexedSubscript:(NSUInteger)index
{
    return [self imageAtIndex:index];
}

- (GLImage *)objectForKeyedSubscript:(NSString *)name
{
    return [self imageNamed:name];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return [self.imageNames countByEnumeratingWithState:state objects:buffer count:len];
}

@end
