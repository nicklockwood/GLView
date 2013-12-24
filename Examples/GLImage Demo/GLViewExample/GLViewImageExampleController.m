//
//  GLViewViewController.m
//
//  Created by Nick Lockwood on 09/07/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "GLViewImageExampleController.h"


@implementation GLViewImageExampleController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.scrollView.contentSize = self.contentView.bounds.size;
	[self.scrollView addSubview:self.contentView];
	
    self.imageView1.image = [GLImage imageNamed:@"logo.png"];
	self.imageView2.image = [GLImage imageNamed:@"logo-opaque.png"];
	self.imageView3.image = [GLImage imageNamed:@"logo-RGBA8888.pvr"];
	self.imageView4.image = [GLImage imageNamed:@"logo-RGBA8888-opaque.pvr"];
	self.imageView5.image = [GLImage imageNamed:@"logo-RGBA4444.pvr"];
	self.imageView6.image = [GLImage imageNamed:@"logo-RGB565.pvr"];
	self.imageView7.image = [GLImage imageNamed:@"logo-RGBA4.pvr"];
	self.imageView8.image = [GLImage imageNamed:@"logo-RGB4.pvr"];
	self.imageView9.image = [GLImage imageNamed:@"logo-RGBA2.pvr"];
	self.imageView10.image = [GLImage imageNamed:@"logo-RGB2.pvr"];
}

- (void)viewDidAppear:(__unused BOOL)animated
{
	[self.scrollView flashScrollIndicators];
    
    //take a snaphost of the first imageview
    //and save it in the documents folder
    UIImage *image = [self.imageView1 snapshot];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"image.png"];
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:path atomically:YES];
}

@end
