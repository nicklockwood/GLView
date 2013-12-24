//
//  AppDelegate.m
//  GLModelExample
//
//  Created by Nick Lockwood on 20/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. 
//

#import "AppDelegate.h"
#import "ViewController.h"


@implementation AppDelegate

- (BOOL)application:(__unused UIApplication *)application didFinishLaunchingWithOptions:(__unused NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[ViewController alloc] init];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
