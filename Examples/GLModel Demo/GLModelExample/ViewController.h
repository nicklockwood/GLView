//
//  ViewController.h
//  GLModelExample
//
//  Created by Nick Lockwood on 20/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. 
//

#import <UIKit/UIKit.h>
#import "GLModelView.h"

@interface ViewController : UIViewController <UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) IBOutlet GLModelView *modelView;

- (IBAction)selectModel;

@end
