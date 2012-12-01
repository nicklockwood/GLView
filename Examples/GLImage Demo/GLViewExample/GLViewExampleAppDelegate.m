//
//  GLViewAppDelegate.m
//
//  Created by Nick Lockwood on 09/07/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "GLViewExampleAppDelegate.h"


@implementation GLViewExampleAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _window.rootViewController = _viewController;
    return YES;
}

@end
