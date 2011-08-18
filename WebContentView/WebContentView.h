//
//  WebContentView.h
//
//  Version 1.0.2
//
//  Created by Nick Lockwood on 07/05/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//
//  Get the latest version of WebContentView from either of these locations:
//
//  http://charcoaldesign.co.uk/source/cocoa#webcontentview
//  https://github.com/demosthenese/WebContentView
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import <UIKit/UIKit.h>


@class WebContentView;


@protocol WebContentViewDelegate <NSObject>

@optional

- (void)webContentViewDidFinishLoad:(WebContentView *)webContentView;
- (BOOL)webContentView:(WebContentView *)webContentView shouldOpenURL:(NSURL *)URL;

@end


@interface WebContentView : UIView

+ (NSString *)defaultStyles;

+ (NSString *)sharedStyles;
+ (void)setSharedStyles:(NSString *)styles;
+ (void)preloadContent:(NSString *)content;
+ (void)preloadContent:(NSString *)content withStyles:(NSString *)styles;

@property (nonatomic, retain, readonly) UIScrollView *scrollView;
@property (nonatomic, retain, readonly) UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIView *header;
@property (nonatomic, retain) IBOutlet UIView *footer;
@property (nonatomic, assign) IBOutlet id<WebContentViewDelegate> delegate;

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *styles;
@property (nonatomic, assign) BOOL scrollEnabled;
@property (nonatomic, readonly, getter = isLoading) BOOL loading;

- (void)flashScrollIndicators;
- (void)sizeContentToFit;

@end
