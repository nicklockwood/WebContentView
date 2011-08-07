//
//  WebContentViewExampleAppDelegate.h
//  WebContentViewExample
//
//  Created by Nick Lockwood on 27/07/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WebContentViewExampleViewController;

@interface WebContentViewExampleAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet WebContentViewExampleViewController *viewController;

@end
