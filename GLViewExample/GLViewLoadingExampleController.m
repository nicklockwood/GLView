//
//  GLViewLoadingExampleController.m
//  GLView
//
//  Created by Nick Lockwood on 21/07/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "GLViewLoadingExampleController.h"
#import <QuartzCore/QuartzCore.h>
#import "GLImage.h"


#if TARGET_IPHONE_SIMULATOR
#define NUMBER_TO_LOAD 1000
#else
#define NUMBER_TO_LOAD 100
#endif


@implementation GLViewLoadingExampleController

@synthesize ttlLabel;
@synthesize label1;
@synthesize label2;
@synthesize label3;
@synthesize label4;
@synthesize label5;

- (void)dealloc
{
	[ttlLabel release];
	[label1 release];
	[label2 release];
	[label3 release];
	[label4 release];
	[label5 release];
    [super dealloc];
}

- (NSTimeInterval)loadImageName:(NSString *)name
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSTimeInterval startTime = CACurrentMediaTime();
	for (int i = 0; i < NUMBER_TO_LOAD; i++)
	{
		[GLImage imageWithContentsOfFile:name];
	}
	NSTimeInterval endTime = CACurrentMediaTime();
	[pool drain];
	
	return endTime - startTime;
}
 
- (void)loadImages
{	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	//load pngs
	[label1 performSelectorOnMainThread:@selector(setText:)
							 withObject:@"Loading..."
						  waitUntilDone:YES];
	[label1 performSelectorOnMainThread:@selector(setText:)
							 withObject:[NSString stringWithFormat:@"%1.2fs", [self loadImageName:@"logo.png"]]
						  waitUntilDone:YES];
	
	//load pvr RGBA4444
	[label2 performSelectorOnMainThread:@selector(setText:)
							 withObject:@"Loading..."
						  waitUntilDone:YES];
	[label2 performSelectorOnMainThread:@selector(setText:)
							 withObject:[NSString stringWithFormat:@"%1.2fs", [self loadImageName:@"logo-RGBA4444.pvr"]]
						  waitUntilDone:YES];
	
	//load pvr RGB565
	[label3 performSelectorOnMainThread:@selector(setText:)
							 withObject:@"Loading..."
						  waitUntilDone:YES];
	[label3 performSelectorOnMainThread:@selector(setText:)
							 withObject:[NSString stringWithFormat:@"%1.2fs", [self loadImageName:@"logo-RGB565.pvr"]]
						  waitUntilDone:YES];
	
	//load pvr RGBA4
	[label4 performSelectorOnMainThread:@selector(setText:)
							 withObject:@"Loading..."
						  waitUntilDone:YES];
	[label4 performSelectorOnMainThread:@selector(setText:)
							 withObject:[NSString stringWithFormat:@"%1.2fs", [self loadImageName:@"logo-RGBA4.pvr"]]
						  waitUntilDone:YES];
	
	//load pvr RGB4
	[label5 performSelectorOnMainThread:@selector(setText:)
							 withObject:@"Loading..."
						  waitUntilDone:YES];
	[label5 performSelectorOnMainThread:@selector(setText:)
							 withObject:[NSString stringWithFormat:@"%1.2fs", [self loadImageName:@"logo-RGB4.pvr"]]
						  waitUntilDone:YES];
	
	[pool drain];
}

- (IBAction)refresh
{
	[self loadImages];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	ttlLabel.text = [NSString stringWithFormat:@"Time to load %i images", NUMBER_TO_LOAD];
	
	label1.text = @"";
	label2.text = @"";
	label3.text = @"";
	label4.text = @"";
	label5.text = @"";

	[self performSelectorInBackground:@selector(loadImages) withObject:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
	self.ttlLabel = nil;
	self.label1 = nil;
	self.label2 = nil;
	self.label3 = nil;
	self.label4 = nil;
	self.label5 = nil;
}

@end
