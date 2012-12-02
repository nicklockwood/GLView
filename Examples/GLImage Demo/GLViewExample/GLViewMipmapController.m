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
    _mipmapImageView.image = [GLImage imageWithContentsOfFile:@"mipmapped-image.pvr"];
    _mipmapImageView.imageTransform = CATransform3DMakeScale(0.1f, 0.1f, 0.1f);
    
    //pinch gesture
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
}

- (void)pinch:(UIPinchGestureRecognizer *)pinch
{
    CATransform3D transform = _mipmapImageView.imageTransform;
    transform = CATransform3DScale(transform, pinch.scale, pinch.scale, pinch.scale);
    _mipmapImageView.imageTransform = transform;
    pinch.scale = 1.0f;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.mipmapImageView = nil;
}

@end
