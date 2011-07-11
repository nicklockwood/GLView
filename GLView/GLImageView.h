//
//  GLImageView.h
//
//  Created by Nick Lockwood on 10/07/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLView.h"
#import "GLImage.h"


@interface GLImageView : GLView

@property (nonatomic, retain) GLImage *image;

- (GLImageView *)initWithImage:(GLImage *)image;

@end
