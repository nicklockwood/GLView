//
//  GLViewLoadingExampleController.h
//  GLView
//
//  Created by Nick Lockwood on 21/07/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GLViewLoadingExampleController : UIViewController

@property (nonatomic, retain) IBOutlet UILabel *ttlLabel;
@property (nonatomic, retain) IBOutlet UILabel *label1;
@property (nonatomic, retain) IBOutlet UILabel *label2;
@property (nonatomic, retain) IBOutlet UILabel *label3;
@property (nonatomic, retain) IBOutlet UILabel *label4;
@property (nonatomic, retain) IBOutlet UILabel *label5;

- (IBAction)refresh;

@end
