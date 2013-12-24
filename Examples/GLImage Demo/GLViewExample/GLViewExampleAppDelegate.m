//
//  GLViewAppDelegate.m
//
//  Created by Nick Lockwood on 09/07/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "GLViewExampleAppDelegate.h"


@implementation GLViewExampleAppDelegate

- (BOOL)application:(__unused UIApplication *)application didFinishLaunchingWithOptions:(__unused NSDictionary *)launchOptions
{
    self.window.rootViewController = self.viewController;
    return YES;
}

@end
