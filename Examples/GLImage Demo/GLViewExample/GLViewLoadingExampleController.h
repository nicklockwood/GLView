//
//  GLViewLoadingExampleController.h
//  GLView
//
//  Created by Nick Lockwood on 21/07/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GLViewLoadingExampleController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *refreshButton;
@property (nonatomic, strong) IBOutlet UILabel *ttlLabel;
@property (nonatomic, strong) IBOutlet UILabel *filenameLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;

- (IBAction)refresh;

@end
