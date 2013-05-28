//
//  GLImage.h
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

#import <UIKit/UIKit.h>
#import "GLUtils.h"


typedef void (^GLImageDrawingBlock)(CGContextRef context);


@interface GLImage : NSObject <NSCopying>

@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) CGSize textureSize;
@property (nonatomic, readonly) CGRect clipRect;
@property (nonatomic, readonly) CGRect contentRect;
@property (nonatomic, readonly) BOOL premultipliedAlpha;
@property (nonatomic, readonly) const GLfloat *textureCoords;
@property (nonatomic, readonly) const GLfloat *vertexCoords;

+ (GLImage *)imageNamed:(NSString *)nameOrPath;
+ (GLImage *)imageWithContentsOfFile:(NSString *)nameOrPath;
+ (GLImage *)imageWithUIImage:(UIImage *)image;
+ (GLImage *)imageWithSize:(CGSize)size scale:(CGFloat)scale drawingBlock:(GLImageDrawingBlock)drawingBlock;
+ (GLImage *)imageWithData:(NSData *)data scale:(CGFloat)scale;

- (GLImage *)initWithContentsOfFile:(NSString *)nameOrPath;
- (GLImage *)initWithUIImage:(UIImage *)image;
- (GLImage *)initWithSize:(CGSize)size scale:(CGFloat)scale drawingBlock:(GLImageDrawingBlock)drawingBlock;
- (GLImage *)initWithData:(NSData *)data scale:(CGFloat)scale;

- (GLImage *)imageWithPremultipliedAlpha:(BOOL)premultipliedAlpha;
- (GLImage *)imageWithClipRect:(CGRect)clipRect;
- (GLImage *)imageWithContentRect:(CGRect)clipRect;
- (GLImage *)imageWithScale:(CGFloat)scale;
- (GLImage *)imageWithSize:(CGSize)size;

- (void)bindTexture;
- (void)drawAtPoint:(CGPoint)point;
- (void)drawInRect:(CGRect)rect;

@end
