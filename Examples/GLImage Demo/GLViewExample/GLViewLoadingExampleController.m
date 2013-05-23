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

- (NSTimeInterval)loadImageNamed:(NSString *)name
{
	@autoreleasepool
    {
        NSTimeInterval startTime = CACurrentMediaTime();
        for (int i = 0; i < NUMBER_TO_LOAD; i++)
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
	_refreshButton.enabled = NO;
	_refreshButton.alpha = 0.25f;
}

- (void)enableRefreshButton
{
	_refreshButton.enabled = YES;
	_refreshButton.alpha = 1.0f;
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
		for (int i = 0; i < [files count]; i++)
		{
			[self performSelectorOnMainThread:@selector(knockBackLabel:)
								   withObject:[self.view viewWithTag:100 + i]
								waitUntilDone:YES];
		}
		
		//load images
		for (int i = 0; i < [files count]; i++)
		{
			NSTimeInterval seconds = [self loadImageNamed:files[i]];
			int ms = ceil(seconds * 1000.0 / (double)NUMBER_TO_LOAD);
			[self performSelectorOnMainThread:@selector(setLabelText:)
								   withObject:@[[self.view viewWithTag:100 + i], [NSString stringWithFormat:@"%1.2fs (%ims each)", seconds, ms]]
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
    
	_ttlLabel.text = [NSString stringWithFormat:@"Time to load %i images", NUMBER_TO_LOAD];
	
	//files
	NSArray *files = [self files];
	_filenameLabel.text = [self nameFromFilename:files[0]];
	_timeLabel.tag = 100;
	_timeLabel.text = @"Loading...";
	[self knockBackLabel:_timeLabel];
	for (int i = 1; i < [files count]; i++)
	{
		UILabel *label = [[UILabel alloc] initWithFrame:_filenameLabel.frame];
		label.font = _filenameLabel.font;
		label.textColor = _filenameLabel.textColor;
		label.text = [self nameFromFilename:files[i]];
		label.center = CGPointMake(label.center.x, label.center.y + 25.0f * i);
		[self.view addSubview:label];
		
		label = [[UILabel alloc] initWithFrame:_timeLabel.frame];
		label.textAlignment = _timeLabel.textAlignment;
		label.font = _timeLabel.font;
		label.textColor = _timeLabel.textColor;
		label.text = @"Loading...";
		label.center = CGPointMake(label.center.x, label.center.y + 25.0f * i);
		label.tag = 100 + i;
		[self knockBackLabel:label];
		[self.view addSubview:label];
	}
	
	[self performSelectorInBackground:@selector(loadImages) withObject:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
	self.refreshButton = nil;
	self.ttlLabel = nil;
	self.filenameLabel = nil;
	self.timeLabel = nil;
}

@end
