//
//  GLImage.h
//
//  Created by Nick Lockwood on 10/07/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import <UIKit/UIKit.h>


#define FILE_EXTENSION @"png"


@interface GLImage : NSObject

@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) CGFloat scale;

+ (GLImage *)imageNamed:(NSString *)name;
+ (GLImage *)imageWithContentsOfFile:(NSString *)path;
+ (GLImage *)imageWithUIImage:(UIImage *)image;

- (GLImage *)initWithContentsOfFile:(NSString *)path;
- (GLImage *)initWithUIImage:(UIImage *)image;

- (void)bindTexture;
- (void)drawAtPoint:(CGPoint)point;
- (void)drawInRect:(CGRect)rect;

@end
