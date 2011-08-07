//
//  WebContentViewExampleAppDelegate.m
//  WebContentViewExample
//
//  Created by Nick Lockwood on 27/07/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "WebContentViewExampleAppDelegate.h"
#import "WebContentViewExampleViewController.h"


@implementation WebContentViewExampleAppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc
{
    [window release];
    [viewController release];
    [super dealloc];
}

@end
