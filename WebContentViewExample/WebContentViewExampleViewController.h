//
//  WebContentViewExampleViewController.h
//  WebContentViewExample
//
//  Created by Nick Lockwood on 27/07/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebContentView.h"

@interface WebContentViewExampleViewController : UIViewController <WebContentViewDelegate>

@property (nonatomic, retain) IBOutlet WebContentView *webContentView;

- (IBAction)toggleStyles:(UISegmentedControl *)sender;

@end
