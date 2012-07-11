//
//  GLViewViewController.m
//
//  Created by Nick Lockwood on 09/07/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "GLViewImageExampleController.h"


@implementation GLViewImageExampleController

@synthesize scrollView;
@synthesize contentView;
@synthesize imageView1;
@synthesize imageView2;
@synthesize imageView3;
@synthesize imageView4;
@synthesize imageView5;
@synthesize imageView6;
@synthesize imageView7;
@synthesize imageView8;
@synthesize imageView9;
@synthesize imageView10;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	scrollView.contentSize = contentView.bounds.size;
	[scrollView addSubview:contentView];
	
    imageView1.image = [GLImage imageNamed:@"logo.png"];
	imageView2.image = [GLImage imageNamed:@"logo-opaque.png"];
	imageView3.image = [GLImage imageNamed:@"logo-RGBA8888.pvr"];
	imageView4.image = [GLImage imageNamed:@"logo-RGBA8888-opaque.pvr"];
	imageView5.image = [GLImage imageNamed:@"logo-RGBA4444.pvr"];
	imageView6.image = [GLImage imageNamed:@"logo-RGB565.pvr"];
	imageView7.image = [GLImage imageNamed:@"logo-RGBA4.pvr"];
	imageView8.image = [GLImage imageNamed:@"logo-RGB4.pvr"];
	imageView9.image = [GLImage imageNamed:@"logo-RGBA2.pvr"];
	imageView10.image = [GLImage imageNamed:@"logo-RGB2.pvr"];
}

- (void)viewDidAppear:(BOOL)animated
{
	[scrollView flashScrollIndicators];
    
    //take a snaphost of the first imageview
    //and save it in the documents folder
    UIImage *image = [imageView1 snapshot];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"image.png"];
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

- (void)dealloc
{
	[scrollView release];
	[contentView release];
    [imageView1 release];
    [imageView2 release];
	[imageView3 release];
	[imageView4 release];
	[imageView5 release];
	[imageView6 release];
	[imageView7 release];
	[imageView8 release];
	[imageView9 release];
	[imageView10 release];
    [super dealloc];
}

@end
