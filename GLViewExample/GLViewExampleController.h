//
//  GLViewViewController.h
//
//  Created by Nick Lockwood on 09/07/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLImageView.h"


@interface GLViewExampleController : UIViewController

@property (readonly, nonatomic) IBOutlet GLImageView *imageView1;
@property (readonly, nonatomic) IBOutlet GLImageView *imageView2;

@end
