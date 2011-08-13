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

- (BOOL)webContentView:(WebContentView *)webContentView shouldOpenURL:(NSURL *)URL
{
    if ([[URL scheme] isEqualToString:@"custom"])
    {
        //custom scheme
        [[[[UIAlertView alloc] initWithTitle:@"You clicked a link"
                                     message:@"We intercepted it"
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil] autorelease] show];
        return NO;
    }
    else
    {
        //ordinary link
        return YES;
    }
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
