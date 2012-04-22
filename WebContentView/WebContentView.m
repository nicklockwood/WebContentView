//
//  WebContentView.m
//
//  Version 1.1
//
//  Created by Nick Lockwood on 07/05/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//
//  Get the latest version of WebContentView from either of these locations:
//
//  http://charcoaldesign.co.uk/source/cocoa#webcontentview
//  https://github.com/nicklockwood/WebContentView
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

#import "WebContentView.h"


#define MAX_CACHED 10


NSString *const WebContentViewDefaultStylesUpdatedNotification = @"WebContentViewDefaultStylesUpdatedNotification";
static NSString *sharedStyles = nil;
static NSString *const defaultStyles = @"\
* { -webkit-text-size-adjust: none; -webkit-touch-callout: none; }\
body { font: 17px Helvetica; margin: 0; padding: 5px; }\
h1 { fonts-size: 19px; }\
h2 { fonts-size: 18px; }\
p, h1 { padding: 0; margin: 0 0 10px 0; }";


@interface WebContentView () <UIWebViewDelegate>

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, assign) CGSize frameSize;

@end


@implementation WebContentView

@synthesize scrollView;
@synthesize webView;
@synthesize headerView;
@synthesize footerView;
@synthesize content;
@synthesize scrollEnabled;
@synthesize delegate;
@synthesize frameSize;
@synthesize minimumContentHeight;


+ (void)load
{
	//ensure the we get initialized on app launch
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(initialize)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
}

+ (void)initialize
{
	//'warm up' webkit
	[[[UIWebView alloc] init] autorelease];
	
	//register for cache clearing
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearCache)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
}

+ (NSString *)defaultStyles
{
    return defaultStyles;
}

+ (NSString *)sharedStyles
{
    return sharedStyles;
}

+ (void)setSharedStyles:(NSString *)styles
{
    if (sharedStyles != styles)
    {
        [sharedStyles release];
        sharedStyles = [styles retain];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WebContentViewDefaultStylesUpdatedNotification object:nil];
    }
}

static NSMutableArray *cachedViews = nil;

+ (WebContentView *)cachedViewForContent:(NSString *)content
{
    if (cachedViews == nil)
    {
        cachedViews = [[NSMutableArray alloc] init];
    }
    for (WebContentView *view in cachedViews)
    {
        if ([view retainCount] == 1 && [view.content isEqualToString:content])
        {
            return view;
        }
    }
    return nil;
}

+ (void)preloadContent:(NSString *)content
{
    if (![self cachedViewForContent:content])
    {
        if ([cachedViews count] == MAX_CACHED)
        {
            [cachedViews removeObjectAtIndex:0];
        }
        WebContentView *view = [[WebContentView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        view.content = content;
        [cachedViews addObject:view];
        [view release];
    }
}

+ (void)clearCache
{
    [cachedViews removeAllObjects];
}

- (void)disableScroll:(UIView *)view
{
    if ([view isKindOfClass:[UIScrollView class]])
    {
        ((UIScrollView *)view).scrollEnabled = NO;
    }
    else
    {
        for (UIView *child in view.subviews)
        {
            [self disableScroll:child];
        }
    }
}

- (void)setWebView:(UIWebView *)_webView
{
    if (webView != _webView)
    {
        [webView removeFromSuperview];
        webView.delegate = nil;
        [webView release];
        webView = [_webView retain];
        webView.frame = self.bounds;
        webView.scalesPageToFit = NO;
        webView.backgroundColor = [UIColor clearColor];
        webView.opaque = NO;
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        webView.delegate = self;
        [scrollView addSubview:webView];
        [self disableScroll:webView];
    }
}

- (void)setup
{
	frameSize = CGSizeZero;
    if (CGRectEqualToRect(self.bounds, CGRectZero))
    {
        self.bounds = CGRectMake(0, 0, 1, 1);
    }
    
    //defaults
    scrollEnabled = YES;
	minimumContentHeight = 0.0f;
    
    scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.scrollEnabled = scrollEnabled;
    [self addSubview:scrollView];
    
    self.webView = [[[UIWebView alloc] initWithFrame:self.bounds] autorelease];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshStyles)
                                                 name:WebContentViewDefaultStylesUpdatedNotification
                                               object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setup];
    }
    return self;
}

- (BOOL)isLoading
{
    return webView.loading;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	if (!CGSizeEqualToSize(self.frame.size, frameSize))
	{
		frameSize = self.frame.size;
		[self sizeContentToFit];
		[self performSelector:@selector(sizeContentToFit) withObject:nil afterDelay:0.0f];
	}
}

- (void)refreshStyles
{
    self.content = content;
}

- (NSString *)allStyles
{
    NSArray *lines = [([defaultStyles stringByReplacingOccurrencesOfString:@"'" withString:@"\""] ?: @"")componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    lines = [lines arrayByAddingObjectsFromArray:[([sharedStyles stringByReplacingOccurrencesOfString:@"'" withString:@"\""] ?: @"") componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
    return [lines componentsJoinedByString:@" "];
}

- (void)setContent:(NSString *)_content
{
    if (content != _content)
    {
        [content release];
        content = [_content retain];
    }
    
    WebContentView *view = [[self class] cachedViewForContent:content];
    if (view)
    {
        [self setWebView:view.webView];
    }
    else
    {
        NSString *html = content ?: @"";
        NSString *style = [NSString stringWithFormat:@"<style type='text/css'>%@</style>", [self allStyles]];
        if ([html rangeOfString:@"</html>"].location == NSNotFound &&
            [html rangeOfString:@"</HTML>"].location == NSNotFound)
        {
            html = [NSString stringWithFormat:@"<!DOCTYPE html><html>\
                    <head>%@</head><body>%@</body></html>", style, html];
        }
        else
        {
            style = [style stringByAppendingString:@"</head>"];
            html = [html stringByReplacingOccurrencesOfString:@"</head>" withString:style];
            html = [html stringByReplacingOccurrencesOfString:@"</HEAD>" withString:style];
        }
        [webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
    }
}

- (void)setScrollEnabled:(BOOL)_scrollEnabled
{
    if (scrollEnabled != _scrollEnabled)
    {
        scrollEnabled = _scrollEnabled;
        scrollView.scrollEnabled = scrollEnabled;
    }
}

- (void)sizeContentToFit
{
	CGFloat headerHeight = 0;
	if (headerView)
	{
		headerHeight = headerView.frame.size.height;
		headerView.frame = CGRectMake(0, 0, self.bounds.size.width, headerHeight);
	}
	CGFloat footerHeight = 0;
	if (footerView)
	{
		footerHeight = footerView.frame.size.height;
	}
	
	CGFloat height = minimumContentHeight - headerHeight - footerHeight;
	webView.frame = CGRectMake(0, headerHeight, self.bounds.size.width, fmaxf(10.0f, height));
	[webView sizeToFit];
	
	if (footerView)
	{
		footerView.frame = CGRectMake(0, webView.frame.origin.y + webView.frame.size.height, self.bounds.size.width, footerHeight);
	}
	scrollView.contentSize = CGSizeMake(self.bounds.size.width, webView.frame.size.height + headerHeight + footerHeight);
}

- (void)flashScrollIndicatorsIfApplicable
{
	if (self.loading)
	{
		//try again in a bit
		[self performSelector:@selector(flashScrollIndicatorsIfApplicable)
				   withObject:nil afterDelay:0.1f];
	}
	else if (scrollView.contentSize.height > scrollView.bounds.size.height)
    {
        [scrollView flashScrollIndicators];
    }
}

- (void)flashScrollIndicators
{
	//delay in case view is still refreshing
    [self performSelector:@selector(flashScrollIndicatorsIfApplicable)
			   withObject:nil afterDelay:0.1f];
}

- (void)setHeaderView:(UIView *)_headerView
{
    if (headerView != _headerView)
    {
        [headerView removeFromSuperview];
        [headerView release];
        headerView = [_headerView retain];
		if (headerView)
		{
			[scrollView addSubview:headerView];
		}
    }
    [self sizeContentToFit];
}

- (void)setFooterView:(UIView *)_footerView
{
    if (footerView != _footerView)
    {
        [footerView removeFromSuperview];
        [footerView release];
        footerView = [_footerView retain];
		if (footerView)
		{
			[scrollView addSubview:footerView];
		}
    }
    [self sizeContentToFit];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [scrollView release];
    [webView release];
    [headerView release];
    [footerView release];
    [super dealloc];
}

#pragma mark -
#pragma mark UIWebview delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked ||
        navigationType == UIWebViewNavigationTypeFormSubmitted)
    {
        if ([delegate respondsToSelector:@selector(webContentView:shouldOpenURL:)])
        {
            if (![delegate webContentView:self shouldOpenURL:[request URL]])
            {
                return NO;
            }
        }
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)_webView
{
	[self sizeContentToFit];
	[self performSelector:@selector(sizeContentToFit) withObject:nil afterDelay:0.0f];
	
    if ([delegate respondsToSelector:@selector(webContentViewDidFinishLoad:)])
    {
        [(NSObject *)delegate performSelector:@selector(webContentViewDidFinishLoad:) withObject:self afterDelay:0.2];
    }
}

@end
