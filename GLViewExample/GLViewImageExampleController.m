//
//  GLViewViewController.m
//
//  Created by Nick Lockwood on 09/07/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "GLViewImageExampleController.h"


@implementation GLViewImageExampleController

@synthesize imageView1;
@synthesize imageView2;
@synthesize imageView3;
@synthesize imageView4;
@synthesize imageView5;
@synthesize imageView6;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    imageView1.image = [GLImage imageNamed:@"logo.png"];
	imageView2.image = [GLImage imageNamed:@"logo-opaque.png"];
	imageView3.image = [GLImage imageNamed:@"logo-RGBA4444.pvr"];
	imageView4.image = [GLImage imageNamed:@"logo-RGB565.pvr"];
	imageView5.image = [GLImage imageNamed:@"logo-RGBA4.pvr"];
	imageView6.image = [GLImage imageNamed:@"logo-RGB4.pvr"];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.imageView1 = nil;
	self.imageView2 = nil;
	self.imageView3 = nil;
	self.imageView4 = nil;
	self.imageView5 = nil;
	self.imageView6 = nil;
}

- (void)dealloc
{
    [imageView1 release];
    [imageView2 release];
	[imageView3 release];
	[imageView4 release];
	[imageView5 release];
	[imageView6 release];
    [super dealloc];
}

@end
