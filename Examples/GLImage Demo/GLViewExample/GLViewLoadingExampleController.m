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
static const int NumberToLoad = 1000;
#else
static const int NumberToLoad = 100;
#endif


@implementation GLViewLoadingExampleController

- (NSTimeInterval)loadImageNamed:(NSString *)name
{
	@autoreleasepool
    {
        NSTimeInterval startTime = CACurrentMediaTime();
        for (int i = 0; i < NumberToLoad; i++)
        {
            [GLImage imageWithContentsOfFile:name];
        }
        NSTimeInterval endTime = CACurrentMediaTime();
        return endTime - startTime;
    }
}

- (NSArray *)files
{
	static NSArray *files = nil;
	if (files == nil)
	{
		files = @[@"logo.png",
				 @"logo-maximum.jpg",
				 @"logo-very-high.jpg",
				 @"logo-high.jpg",
				 @"logo-medium.jpg",
				 @"logo-low.jpg",
				 @"logo-RGBA8888.pvr",
				 @"logo-RGBA4444.pvr",
				 @"logo-RGB565.pvr",
				 @"logo-RGBA4.pvr",
				 @"logo-RGB4.pvr",
				 @"logo-RGBA2.pvr",
				 @"logo-RGB2.pvr"];
	}
	return files;
}

- (void)disableRefreshButton
{
	self.refreshButton.enabled = NO;
	self.refreshButton.alpha = 0.25f;
}

- (void)enableRefreshButton
{
	self.refreshButton.enabled = YES;
	self.refreshButton.alpha = 1.0f;
}

- (void)knockBackLabel:(UILabel *)label
{
	label.alpha = 0.25f;
}

- (void)setLabelText:(NSArray *)params
{
	UILabel *label = params[0];
	label.alpha = 1.0f;
	label.text = params[1];
}
 
- (void)loadImages
{	
	@autoreleasepool
	{
		//disable button
		[self performSelectorOnMainThread:@selector(disableRefreshButton) withObject:nil waitUntilDone:YES];
		
		//files
		NSArray *files = [self files];
		
		//clear labels
		for (NSUInteger i = 0; i < [files count]; i++)
		{
			[self performSelectorOnMainThread:@selector(knockBackLabel:)
								   withObject:[self.view viewWithTag:100 + (NSInteger)i]
								waitUntilDone:YES];
		}
		
		//load images
		for (NSUInteger i = 0; i < [files count]; i++)
		{
			NSTimeInterval seconds = [self loadImageNamed:files[i]];
			double ms = ceil(seconds * 1000.0 / (double)NumberToLoad);
			[self performSelectorOnMainThread:@selector(setLabelText:)
								   withObject:@[[self.view viewWithTag:100 + (NSInteger)i], [NSString stringWithFormat:@"%1.2fs (%1.0fms each)", seconds, ms]]
								waitUntilDone:YES];
		}
		
		//enable button
		[self performSelectorOnMainThread:@selector(enableRefreshButton) withObject:nil waitUntilDone:YES];
	}
}

- (NSString *)nameFromFilename:(NSString *)filename
{
	NSString *name = [filename stringByDeletingPathExtension];
	name = ([name length] >= 5)? [name substringFromIndex:5]: @"";
	return [NSString stringWithFormat:@"%@ %@", [[filename pathExtension] uppercaseString], name];
}

- (IBAction)refresh
{
	[self performSelectorInBackground:@selector(loadImages) withObject:nil];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.ttlLabel.text = [NSString stringWithFormat:@"Time to load %i images", NumberToLoad];
	
	//files
	NSArray *files = [self files];
	self.filenameLabel.text = [self nameFromFilename:files[0]];
	self.timeLabel.tag = 100;
	self.timeLabel.text = @"Loading...";
	[self knockBackLabel:self.timeLabel];
	for (NSUInteger i = 1; i < [files count]; i++)
	{
		UILabel *label = [[UILabel alloc] initWithFrame:self.filenameLabel.frame];
		label.font = self.filenameLabel.font;
		label.textColor = self.filenameLabel.textColor;
		label.text = [self nameFromFilename:files[i]];
		label.center = CGPointMake(label.center.x, label.center.y + 25.0f * i);
		[self.view addSubview:label];
		
		label = [[UILabel alloc] initWithFrame:self.timeLabel.frame];
		label.textAlignment = self.timeLabel.textAlignment;
		label.font = self.timeLabel.font;
		label.textColor = self.timeLabel.textColor;
		label.text = @"Loading...";
		label.center = CGPointMake(label.center.x, label.center.y + 25.0f * i);
		label.tag = 100 + (signed)i;
		[self knockBackLabel:label];
		[self.view addSubview:label];
	}
	
	[self performSelectorInBackground:@selector(loadImages) withObject:nil];
}

@end
