//
//  WebContentViewExampleViewController.m
//  WebContentViewExample
//
//  Created by Nick Lockwood on 27/07/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "WebContentViewExampleViewController.h"

@implementation WebContentViewExampleViewController

@synthesize webContentView;

- (IBAction)toggleStyles:(UISegmentedControl *)sender
{
    //set styles
    NSString *styles = [[NSArray arrayWithObjects:@"", @"styles1", @"styles2", nil] objectAtIndex:sender.selectedSegmentIndex];
    if ([styles length])
    {
        webContentView.styles = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:styles ofType:@"css"]
                                                          encoding:NSUTF8StringEncoding error:NULL];
    }
    else
    {
        webContentView.styles = @"";
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set content
    webContentView.content = [NSString stringWithContentsOfFile:
                              [[NSBundle mainBundle] pathForResource:@"content" ofType:@"html"]
                                                       encoding:NSUTF8StringEncoding error:NULL];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webContentView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)dealloc
{
    [webContentView release];
    [super dealloc];
}

@end
