//
//  GLViewVideoExampleController.m
//  GLView
//
//  Created by Nick Lockwood on 19/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GLViewVideoExampleController.h"


static const int NumberOfFrames = 604;


@implementation GLViewVideoExampleController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	//create array of video frame names
	NSMutableArray *frames = [NSMutableArray arrayWithCapacity:NumberOfFrames];
	for (int i = 0; i < NumberOfFrames; i++)
	{
		[frames addObject:[NSString stringWithFormat:@"droplet%03i.pvr.gz", i + 1]]; 
	}
	
	//add frames to image view
    self.videoView.animationImages = frames;
	
	//auto-play
	[self.videoView startAnimating];
}

- (IBAction)play
{
	[self.videoView startAnimating];
}

- (IBAction)stop
{
	[self.videoView stopAnimating];
}

@end
