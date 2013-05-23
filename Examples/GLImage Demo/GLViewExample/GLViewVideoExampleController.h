//
//  GLViewVideoExampleController.h
//  GLView
//
//  Created by Nick Lockwood on 19/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLImageView.h"


@interface GLViewVideoExampleController : UIViewController

@property (unsafe_unretained, nonatomic) IBOutlet GLImageView *videoView;

- (IBAction)play;
- (IBAction)stop;

@end
