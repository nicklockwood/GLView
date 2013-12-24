//
//  GLViewMipmapController.m
//  GLImageDemo
//
//  Created by Nick Lockwood on 01/12/2012.
//  Copyright 2012 Charcoal Design. All rights reserved.
//

#import "GLViewMipmapController.h"


@interface GLViewMipmapController () <UIGestureRecognizerDelegate>

@end


@implementation GLViewMipmapController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //load image and set default scale
    self.mipmapImageView.image = [GLImage imageWithContentsOfFile:@"mipmapped-image.pvr"];
    self.mipmapImageView.imageTransform = CATransform3DMakeScale(0.1f, 0.1f, 0.1f);
    
    //pinch gesture
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
}

- (void)pinch:(UIPinchGestureRecognizer *)pinch
{
    CATransform3D transform = self.mipmapImageView.imageTransform;
    transform = CATransform3DScale(transform, pinch.scale, pinch.scale, pinch.scale);
    self.mipmapImageView.imageTransform = transform;
    pinch.scale = 1.0f;
}

@end
