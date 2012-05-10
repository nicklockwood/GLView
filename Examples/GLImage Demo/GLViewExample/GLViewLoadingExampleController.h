//
//  GLViewLoadingExampleController.h
//  GLView
//
//  Created by Nick Lockwood on 21/07/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GLViewLoadingExampleController : UIViewController

@property (nonatomic, retain) IBOutlet UIButton *refreshButton;
@property (nonatomic, retain) IBOutlet UILabel *ttlLabel;
@property (nonatomic, retain) IBOutlet UILabel *filenameLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;

- (IBAction)refresh;

@end
