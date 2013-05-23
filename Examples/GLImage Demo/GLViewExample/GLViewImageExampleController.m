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
    
	_scrollView.contentSize = _contentView.bounds.size;
	[_scrollView addSubview:_contentView];
	
    _imageView1.image = [GLImage imageNamed:@"logo.png"];
	_imageView2.image = [GLImage imageNamed:@"logo-opaque.png"];
	_imageView3.image = [GLImage imageNamed:@"logo-RGBA8888.pvr"];
	_imageView4.image = [GLImage imageNamed:@"logo-RGBA8888-opaque.pvr"];
	_imageView5.image = [GLImage imageNamed:@"logo-RGBA4444.pvr"];
	_imageView6.image = [GLImage imageNamed:@"logo-RGB565.pvr"];
	_imageView7.image = [GLImage imageNamed:@"logo-RGBA4.pvr"];
	_imageView8.image = [GLImage imageNamed:@"logo-RGB4.pvr"];
	_imageView9.image = [GLImage imageNamed:@"logo-RGBA2.pvr"];
	_imageView10.image = [GLImage imageNamed:@"logo-RGB2.pvr"];
}

- (void)viewDidAppear:(BOOL)animated
{
	[_scrollView flashScrollIndicators];
    
    //take a snaphost of the first imageview
    //and save it in the documents folder
    UIImage *image = [_imageView1 snapshot];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"image.png"];
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:path atomically:YES];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.scrollView = nil;
	self.contentView = nil;
	self.imageView1 = nil;
	self.imageView2 = nil;
	self.imageView3 = nil;
	self.imageView4 = nil;
	self.imageView5 = nil;
	self.imageView6 = nil;
	self.imageView7 = nil;
	self.imageView8 = nil;
	self.imageView9 = nil;
	self.imageView10 = nil;
}


@end
