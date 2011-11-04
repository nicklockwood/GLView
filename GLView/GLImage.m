//
//  GLImage.m
//  Version 1.1.1
//
//  Created by Nick Lockwood on 10/07/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//
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

#import "GLImage.h"
#import "GLView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


typedef struct
{
	GLuint headerSize;
	GLuint height;
	GLuint width;
	GLuint mipmapCount;
	GLuint pixelFormatFlags;
	GLuint textureDataSize;
	GLuint bitCount; 
	GLuint redBitMask;
	GLuint greenBitMask;
	GLuint blueBitMask;
	GLuint alphaBitMask;
	GLuint magicNumber;
	GLuint surfaceCount;
}
PVRTextureHeader;


typedef enum
{
	OGL_RGBA_4444 = 0x10,
	OGL_RGBA_5551,
	OGL_RGBA_8888,
	OGL_RGB_565,
	OGL_RGB_555,
	OGL_RGB_888,
	OGL_I_8,
	OGL_AI_88,
	OGL_PVRTC2,
	OGL_PVRTC4
}
PVRPixelType;


@interface GLImage ()

@property (nonatomic, assign) GLuint texture;
@property (nonatomic, assign) BOOL premultipliedAlpha;

@end


@implementation GLImage

@synthesize size;
@synthesize scale;
@synthesize texture;
@synthesize premultipliedAlpha;


#pragma mark -
#pragma mark Utils


+ (NSString *)scaleSuffixForImagePath:(NSString *)nameOrPath
{
    nameOrPath = [nameOrPath stringByDeletingPathExtension];
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

+ (NSString *)normalisedImagePath:(NSString *)nameOrPath
{
    //get or add file extension
    NSString *extension = [nameOrPath pathExtension];
    if ([extension isEqualToString:@""])
    {
        extension = DEFAULT_FILE_EXTENSION;
        nameOrPath = [nameOrPath stringByAppendingPathExtension:extension];
    }
    
    //convert to absolute path
    if (![nameOrPath isAbsolutePath])
    {
        nameOrPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:nameOrPath];
    }
    
    //get or add scale suffix
    NSString *scaleSuffix = [self scaleSuffixForImagePath:nameOrPath];
    if (!scaleSuffix)
    {
        scaleSuffix = [NSString stringWithFormat:@"@%ix", (int)[[UIScreen mainScreen] scale]];
        NSString *path = [[[nameOrPath stringByDeletingPathExtension] stringByAppendingString:scaleSuffix] stringByAppendingPathExtension:extension];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            nameOrPath = path;
        }
    }
    
    //return normalised path
    return nameOrPath;
}


#pragma mark -
#pragma mark Caching

static NSMutableDictionary *imageCache = nil;

+ (void)initialize
{
    imageCache = [[NSMutableDictionary alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(flushCache)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
}

+ (void)flushCache
{
    for (NSString *key in [imageCache allKeys])
    {
        GLImage *image = [imageCache objectForKey:key];
        if ([image retainCount] == 1)
        {
            [imageCache removeObjectForKey:key];
        }
    }
}

+ (GLImage *)imageNamed:(NSString *)name
{
    NSString *path = [self normalisedImagePath:name];
    GLImage *image = nil;
    if (path)
    {
        image = [imageCache objectForKey:path];
        if (!image)
        {
            image = [self imageWithContentsOfFile:path];
            if (image)
            {
                [imageCache setObject:image forKey:path];
            }
        }
    }
    return image;
}
            
            
#pragma mark -
#pragma mark Loading

+ (GLImage *)imageWithContentsOfFile:(NSString *)path
{
    return [[[self alloc] initWithContentsOfFile:path] autorelease];
}

+ (GLImage *)imageWithUIImage:(UIImage *)image
{
    return [[[self alloc] initWithUIImage:image] autorelease];
}

- (GLImage *)initWithContentsOfFile:(NSString *)path
{
    path = [[self class] normalisedImagePath:path];
	NSString *extension = [[path pathExtension] lowercaseString];
    if ([extension isEqualToString:@"pvr"] || [extension isEqualToString:@"pvrtc"])
    {
        if ((self = [super init]))
        {
			//get scale factor
            NSString *scaleSuffix = [[self class] scaleSuffixForImagePath:path];
            scale = scaleSuffix? [[scaleSuffix substringWithRange:NSMakeRange(1, 1)] floatValue]: 1.0;
        
            //load data
            NSData *data = [[NSData alloc] initWithContentsOfFile:path];
            
            //parse header
            PVRTextureHeader *header = (PVRTextureHeader *)[data bytes];

			//check magic number
			if (CFSwapInt32HostToBig(header->magicNumber) != 'PVR!')
			{
				NSLog(@"PVR image data was not in a recognised format, or is missing header information");
				[self release];
				return nil;
			}
			
            //dimensions
            GLint width = header->width;
            GLint height = header->height;
            size = CGSizeMake((float)width/scale, (float)height/scale);
            
            //format
            BOOL compressed;
            NSInteger bitsPerPixel;
            GLuint type;
            GLuint format;
            premultipliedAlpha = NO;
            BOOL hasAlpha = header->alphaBitMask;
            switch (header->pixelFormatFlags & 0xff)
            {
                case OGL_RGB_565:
                {
                    compressed = NO;
                    bitsPerPixel = 16;
                    format = GL_RGB;
                    type = GL_UNSIGNED_SHORT_5_6_5;
                    break;
                }
                case OGL_RGBA_5551:
                {
                    compressed = NO;
                    bitsPerPixel = 16;
                    format = GL_RGBA;
                    type = GL_UNSIGNED_SHORT_5_5_5_1;
                    break;
                }
                case OGL_RGBA_4444:
                {
                    compressed = NO;
                    bitsPerPixel = 16;
                    format = GL_RGBA;
                    type = GL_UNSIGNED_SHORT_4_4_4_4;
                    break;
                }
                case OGL_RGBA_8888:
                {
                    compressed = NO;
                    bitsPerPixel = 32;
                    format = GL_RGBA;
                    type = GL_UNSIGNED_BYTE;
                    break;
                }
                case OGL_I_8:
                {
                    NSLog(@"I8 PVR format is not currently supported");
                    [self release];
                    return nil;
                }
                case OGL_AI_88:
                {
                    NSLog(@"AI88 PVR format is not currently supported");
                    [self release];
                    return nil;
                }
                case OGL_PVRTC2:
                {
                    compressed = YES;
                    bitsPerPixel = 2;
                    format = hasAlpha? GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG: GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG;
                    type = 0;
                    break;
                }
                case OGL_PVRTC4:
                {
                    compressed = YES;
                    bitsPerPixel = 4;
                    format = hasAlpha? GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG: GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG;
                    type = 0;
                    break;
                }
                default:
                {
                    NSLog(@"Unrecognised PVR image format: %i", header->pixelFormatFlags & 0xff);
                    [self release];
                    return nil;
                }
            }
            
            //bind context
            [EAGLContext setCurrentContext:[GLView performSelector:@selector(sharedContext)]];

            //create texture
            glGenTextures(1, &texture);
            glBindTexture(GL_TEXTURE_2D, texture);
            glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
            glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
            if (compressed)
            {
                glCompressedTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0,
                                       MAX(32, width * height * bitsPerPixel / 8),
                                       [data bytes] + header->headerSize);
            }
            else
            {
                glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, type,
                             [data bytes] + header->headerSize);
            }
            
            //release image data
            [data release];
        }
        return self;
    }
    else
    {
        return [self initWithUIImage:[UIImage imageWithContentsOfFile:path]];
    }
}

- (GLImage *)initWithUIImage:(UIImage *)image
{
    if ((self = [super init]))
    {
        //dimensions and scale
        scale = image.scale;
        size = image.size;
        GLint width = size.width * scale;
        GLint height = size.height * scale;
        
        //alpha
        premultipliedAlpha = YES;
        
        //create context
        void *imageData = calloc(height * width, 4);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, 4 * width, colorSpace,
                                                     kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
        CGColorSpaceRelease(colorSpace);
        
        //draw image into context
        CGContextTranslateCTM(context, 0, height);
        CGContextScaleCTM(context, scale, -scale);
        UIGraphicsPushContext(context);
        [image drawAtPoint:CGPointMake(0, 0)];
        UIGraphicsPopContext();
        
        //bind context
        if (![EAGLContext currentContext])
        {
            [EAGLContext setCurrentContext:[GLView performSelector:@selector(sharedContext)]];
        }

        //create texture
        glGenTextures(1, &texture);
        glBindTexture(GL_TEXTURE_2D, texture);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
        
        //free context
        CGContextRelease(context);
        free(imageData);
    }
    return self;
}
                                 
- (void)dealloc
{     
    glDeleteTextures(1, &texture); 
    [super dealloc];
}
        
            
#pragma mark -
#pragma mark Drawing

- (void)bindTexture
{
    glBindTexture(GL_TEXTURE_2D, texture);
}

- (void)drawAtPoint:(CGPoint)point
{
    [self drawInRect:CGRectMake(point.x, point.y, size.width, size.height)];
}

- (void)drawInRect:(CGRect)rect
{
    GLfloat vertices[] =
    {
        rect.origin.x, rect.origin.y,
        rect.origin.x + rect.size.width, rect.origin.y,
        rect.origin.x + rect.size.width, rect.origin.y + rect.size.height,
        rect.origin.x, rect.origin.y + rect.size.height
    };
    
    GLfloat texCoords[] =
    {
        0, 0, 1, 0, 1, 1, 0, 1
    };
    
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(premultipliedAlpha? GL_ONE: GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);

    glBindTexture(GL_TEXTURE_2D, texture);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}

@end
