//
//  GLViewAppDelegate.m
//
//  Created by Nick Lockwood on 09/07/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "GLViewExampleAppDelegate.h"


@implementation GLViewExampleAppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    window.rootViewController = viewController;
    return YES;
}

- (void)dealloc
{
    [window release];
    [viewController release];
    [super dealloc];
}

@end
