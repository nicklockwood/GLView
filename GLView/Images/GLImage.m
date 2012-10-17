//
//  GLImage.m
//
//  GLView Project
//  Version 1.4
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

#import "GLImage.h"
#import "GLView.h"


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


@interface NSString (Private)

- (BOOL)GL_hasRetinaFileSuffix;
- (NSString *)GL_normalizedPathWithDefaultExtension:(NSString *)extension;

@end


@interface NSData (Private)

- (NSData *)GL_unzippedData;

@end


@interface GLView (Private)

+ (EAGLContext *)sharedContext;

@end


@interface GLImage ()

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) GLuint texture;
@property (nonatomic, assign) CGSize textureSize;
@property (nonatomic, assign) const GLfloat *textureCoords;
@property (nonatomic, assign) const GLfloat *vertexCoords;
@property (nonatomic, assign) CGRect clipRect;
@property (nonatomic, assign) CGRect contentRect;
@property (nonatomic, getter = isRotated) BOOL rotated;
@property (nonatomic, assign) BOOL premultipliedAlpha;
@property (nonatomic, strong) GLImage *superimage;

@end


@implementation GLImage

@synthesize size = _size;
@synthesize scale = _scale;
@synthesize texture = _texture;
@synthesize textureSize = _textureSize;
@synthesize textureCoords = _textureCoords;
@synthesize vertexCoords = _vertexCoords;
@synthesize clipRect = _clipRect;
@synthesize contentRect = _contentRect;
@synthesize rotated = _rotated;
@synthesize premultipliedAlpha = _premultipliedAlpha;
@synthesize superimage = _superimage;


#pragma mark -
#pragma mark Caching

static NSCache *imageCache = nil;

+ (void)initialize
{
    imageCache = [[NSCache alloc] init];
}

+ (GLImage *)imageNamed:(NSString *)nameOrPath
{
    NSString *path = [nameOrPath GL_normalizedPathWithDefaultExtension:@"png"];
    GLImage *image = nil;
    if (path)
    {
        image = [imageCache objectForKey:path];
        if (!image)
        {
            image = [self imageWithContentsOfFile:nameOrPath];
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

+ (GLImage *)imageWithContentsOfFile:(NSString *)nameOrPath
{
    return [[[self alloc] initWithContentsOfFile:nameOrPath] autorelease];
}

+ (GLImage *)imageWithUIImage:(UIImage *)image
{
    return [[[self alloc] initWithUIImage:image] autorelease];
}

+ (GLImage *)imageWithSize:(CGSize)size scale:(CGFloat)scale drawingBlock:(GLImageDrawingBlock)drawingBlock
{
    return [[[self alloc] initWithSize:size scale:scale drawingBlock:drawingBlock] autorelease];
}

+ (GLImage *)imageWithData:(NSData *)data scale:(CGFloat)scale
{
    return [[[self alloc] initWithData:data scale:scale] autorelease];
}

- (GLImage *)initWithContentsOfFile:(NSString *)nameOrPath
{
    //get normalised path
    NSString *path = [nameOrPath GL_normalizedPathWithDefaultExtension:@"png"];

    //load image
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [self initWithData:data scale:[path GL_hasRetinaFileSuffix]? 2.0f: 1.0f];
}

- (GLImage *)initWithUIImage:(UIImage *)image
{
    if (image)
    {
        return [self initWithSize:image.size scale:image.scale drawingBlock:^(CGContextRef context)
        {
            [image drawAtPoint:CGPointZero];
        }];
    }
    
    //no image supplied
    [self release];
    return nil;
}

- (GLImage *)initWithSize:(CGSize)size scale:(CGFloat)scale drawingBlock:(GLImageDrawingBlock)drawingBlock
{
    if ((self = [super init]))
    {
        //dimensions and scale
        self.scale = scale;
        self.size = size;
        self.textureSize = CGSizeMake(powf(2.0f, ceilf(log2f(size.width * scale))),
                                      powf(2.0f, ceilf(log2f(size.height * scale))));
        
        //clip and content rects
        self.clipRect = CGRectMake(0.0f, 0.0f, size.width * scale, size.height * scale);
        self.contentRect = CGRectMake(0.0f, 0.0f, size.width, size.height);

        //alpha
        self.premultipliedAlpha = YES;
        
        //create cg context
        GLint width = self.textureSize.width;
        GLint height = self.textureSize.height;
        void *imageData = calloc(height * width, 4);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, 4 * width, colorSpace,
                                                     kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
        CGColorSpaceRelease(colorSpace);
        
        //perform drawing
        CGContextTranslateCTM(context, 0, self.textureSize.height);
        CGContextScaleCTM(context, self.scale, -self.scale);
        UIGraphicsPushContext(context);
        if (drawingBlock) drawingBlock(context);
        UIGraphicsPopContext();
        
        //bind shared gl context
        EAGLContext *glContext = [EAGLContext currentContext];
        [EAGLContext setCurrentContext:[GLView performSelector:@selector(sharedContext)]];
        
        //create texture
        glGenTextures(1, &_texture);
        glBindTexture(GL_TEXTURE_2D, self.texture);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
        
        //restore gl context
        [EAGLContext setCurrentContext:glContext];
        
        //free cg context
        CGContextRelease(context);
        free(imageData);
    }
    return self;
}

- (GLImage *)initWithData:(NSData *)data scale:(CGFloat)scale
{
    //attempt to unzip data
    data = [data GL_unzippedData];
    
    //attempt to load as PVR first
    if ([data length] >= sizeof(PVRTextureHeader))
    {
        //parse header
        PVRTextureHeader *header = (PVRTextureHeader *)[data bytes];
        
        //check magic number
        if (CFSwapInt32HostToBig(header->magicNumber) == 'PVR!')
        {
            //initalize
            if ((self = [super init]))
            {
                //dimensions
                GLint width = header->width;
                GLint height = header->height;
                self.scale = scale;
                self.size = CGSizeMake((float)width/self.scale, (float)height/self.scale);
                self.textureSize = CGSizeMake(width, height);
                self.clipRect = CGRectMake(0.0f, 0.0f, width, height);
                self.contentRect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
                
                //format
                BOOL compressed;
                NSInteger bitsPerPixel;
                GLuint type;
                GLuint format;
                self.premultipliedAlpha = NO;
                BOOL hasAlpha = header->alphaBitMask;
                switch (header->pixelFormatFlags & 0xff)
                {
                    case OGL_RGBA_4444:
                    {
                        compressed = NO;
                        bitsPerPixel = 16;
                        format = GL_RGBA;
                        type = GL_UNSIGNED_SHORT_4_4_4_4;
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
                    case OGL_RGBA_8888:
                    {
                        compressed = NO;
                        bitsPerPixel = 32;
                        format = GL_RGBA;
                        type = GL_UNSIGNED_BYTE;
                        break;
                    }
                    case OGL_RGB_565:
                    {
                        compressed = NO;
                        bitsPerPixel = 16;
                        format = GL_RGB;
                        type = GL_UNSIGNED_SHORT_5_6_5;
                        break;
                    }
                    case OGL_RGB_555:
                    {
                        NSLog(@"RGB 555 PVR format is not currently supported");
                        [self release];
                        return nil;
                    }
                    case OGL_RGB_888:
                    {
                        compressed = NO;
                        bitsPerPixel = 24;
                        format = GL_RGB;
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
                
                //bind shared context
                EAGLContext *context = [EAGLContext currentContext];
                [EAGLContext setCurrentContext:[GLView performSelector:@selector(sharedContext)]];
                
                //create texture
                glGenTextures(1, &_texture);
                glBindTexture(GL_TEXTURE_2D, self.texture);
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
                
                //restore context
                [EAGLContext setCurrentContext:context];
            }
            return self;
        }
    }

    //attempt to load as regular image
    UIImage *image = [UIImage imageWithData:data];
    image = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:UIImageOrientationUp];
    return [self initWithUIImage:image];
}

- (void)dealloc
{
    if (!_superimage)
    {
        EAGLContext *context = [EAGLContext currentContext];
        [EAGLContext setCurrentContext:[GLView performSelector:@selector(sharedContext)]];
        glDeleteTextures(1, &_texture);
        [EAGLContext setCurrentContext:context];
    }
    if (_textureCoords) free((void *)_textureCoords);
    if (_vertexCoords) free((void *)_vertexCoords);
    [_superimage release];
    [super ah_dealloc];
}


#pragma mark -
#pragma mark Copying

- (id)copyWithZone:(NSZone *)zone
{
    GLImage *copy = [[[self class] allocWithZone:zone] init];
    copy.superimage = self.superimage ?: self;
    copy.texture = self.texture;
    copy.premultipliedAlpha = self.premultipliedAlpha;
    copy.scale = self.scale;
    copy.size = self.size;
    copy.textureSize = self.textureSize;
    copy.clipRect = self.clipRect;
    copy.contentRect = self.contentRect;
    return copy;
}

- (GLImage *)imageWithPremultipliedAlpha:(BOOL)premultipliedAlpha
{
    GLImage *copy = [[self copy] autorelease];
    copy.premultipliedAlpha = premultipliedAlpha;
    return copy;
}

- (GLImage *)imageWithClipRect:(CGRect)clipRect
{
    GLImage *copy = [[self copy] autorelease];
    copy.clipRect = clipRect;
    copy.size = CGSizeMake(clipRect.size.width / copy.scale, clipRect.size.height / copy.scale);
    copy.contentRect = CGRectMake(0.0f, 0.0f, copy.size.width, copy.size.height);
    return copy;
}

- (GLImage *)imageWithContentRect:(CGRect)contentRect
{
    GLImage *copy = [[self copy] autorelease];
    copy.contentRect = contentRect;
    return copy;
}

- (GLImage *)imageWithScale:(CGFloat)scale
{
    CGFloat deltaScale = scale / self.scale;
    GLImage *copy = [[self copy] autorelease];
    copy.scale = scale;
    copy.size = CGSizeMake(copy.size.width * deltaScale, copy.size.height * deltaScale);
    copy.contentRect = CGRectMake(self.contentRect.origin.x * deltaScale, self.contentRect.origin.y * deltaScale, self.contentRect.size.width * deltaScale, self.contentRect.size.height * deltaScale);
    return copy;
}

- (GLImage *)imageWithSize:(CGSize)size
{
    CGPoint scale = CGPointMake(size.width / self.size.width, size.height / self.size.height);
    GLImage *copy = [[self copy] autorelease];
    copy.size = size;
    copy.contentRect = CGRectMake(self.contentRect.origin.x * scale.x, self.contentRect.origin.y * scale.y, self.contentRect.size.width * scale.x, self.contentRect.size.height * scale.y);
    return copy;
}


#pragma mark -
#pragma mark Drawing

- (void)bindTexture
{
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(self.premultipliedAlpha? GL_ONE: GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glBindTexture(GL_TEXTURE_2D, self.texture);
}

- (const GLfloat *)textureCoords
{
    if (_textureCoords == NULL)
    {
        //normalise coordinates
        CGRect rect = self.clipRect;
        rect.origin.x /= self.textureSize.width;
        rect.origin.y /= self.textureSize.height;
        rect.size.width /= self.textureSize.width;
        rect.size.height /= self.textureSize.height;
        
        //set non-rotated coordinates
        GLfloat *coords = malloc(8 * sizeof(GLfloat));
        CGRectGetGLCoords(rect, coords);

        if (self.rotated)
        {
            //rotate coordinates 90 degrees anticlockwise
            GLfloat u = coords[0];
            GLfloat v = coords[1];
            coords[0] = coords[2];
            coords[1] = coords[3];
            coords[2] = coords[4];
            coords[3] = coords[5];
            coords[4] = coords[6];
            coords[5] = coords[7];
            coords[6] = u;
            coords[7] = v;
        }

        _textureCoords = coords;
    }
    return _textureCoords;
}

- (const GLfloat *)vertexCoords
{
    if (_vertexCoords == NULL)
    {
        GLfloat *coords = malloc(8 * sizeof(GLfloat));
        CGRectGetGLCoords(self.contentRect, coords);
        _vertexCoords = coords;
    }
    return _vertexCoords;
}

- (void)drawWithVertexCoords:(const GLfloat *)vertexCoords
{
    [self bindTexture];
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    
    glVertexPointer(2, GL_FLOAT, 0, vertexCoords);
    glTexCoordPointer(2, GL_FLOAT, 0, self.textureCoords);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}

- (void)drawAtPoint:(CGPoint)point
{
    const GLfloat *coords = self.vertexCoords;
    
    //calculate vertices
    GLfloat vertexCoords[8];
    vertexCoords[0] = coords[0] + point.x;
    vertexCoords[1] = coords[1] + point.y;
    vertexCoords[2] = coords[2] + point.x;
    vertexCoords[3] = vertexCoords[1];
    vertexCoords[4] = vertexCoords[2];
    vertexCoords[5] = coords[5] + point.y;
    vertexCoords[6] = vertexCoords[0];
    vertexCoords[7] = vertexCoords[5];
    
    //draw
    [self drawWithVertexCoords:vertexCoords];
}

- (void)drawInRect:(CGRect)rect
{
    const GLfloat *coords = self.vertexCoords;
    CGPoint scale = CGPointMake(rect.size.width / self.size.width, rect.size.height / self.size.height);
    
    //calculate vertices
    GLfloat vertexCoords[8];
    vertexCoords[0] = coords[0] * scale.x + rect.origin.x;
    vertexCoords[1] = coords[1] * scale.y + rect.origin.y;
    vertexCoords[2] = coords[2] * scale.x + rect.origin.x;
    vertexCoords[3] = vertexCoords[1];
    vertexCoords[4] = vertexCoords[2];
    vertexCoords[5] = coords[5] * scale.y + rect.origin.y;
    vertexCoords[6] = vertexCoords[0];
    vertexCoords[7] = vertexCoords[5];

    //draw
    [self drawWithVertexCoords:vertexCoords];
}

@end
