//
//  WebContentView.m
//
//  Version 1.0
//
//  Created by Nick Lockwood on 07/05/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//
//  Get the latest version of BaseModel from either of these locations:
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

#import "WebContentView.h"


#define STYLE_TAG @"WCVStyles"
#define MAX_CACHED 10


@interface WebContentView () <UIWebViewDelegate>

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIWebView *webView;

@end


@implementation WebContentView

@synthesize scrollView;
@synthesize webView;
@synthesize header;
@synthesize footer;
@synthesize content;
@synthesize styles;
@synthesize scrollEnabled;
@synthesize delegate;


NSString *const WebContentViewDefaultStylesUpdatedNotification = @"WebContentViewDefaultStylesUpdatedNotification";
static NSString *defaultStyles = nil;

+ (void)initialize
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearCache)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
}

+ (NSString *)defaultStyles
{
    if (defaultStyles == nil)
    {
        defaultStyles = [@"body { font: 17px Helvetica; color: #000; margin: 0; padding: 5px }\
                         h1 { fonts-size: 19px; }\
                         h2 { fonts-size: 18px; }\
                         p, h1 { padding: 0; margin: 0 0 10px 0 }\
                         a { color: #00f }" retain];
    }
    return defaultStyles;
}

+ (void)setDefaultStyles:(NSString *)styles
{
    if (defaultStyles != styles)
    {
        [defaultStyles release];
        defaultStyles = [styles retain];
        
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
    [self preloadContent:content withStyles:nil];
}

+ (void)preloadContent:(NSString *)content withStyles:(NSString *)styles
{
    if (![self cachedViewForContent:content])
    {
        if ([cachedViews count] == MAX_CACHED)
        {
            [cachedViews removeObjectAtIndex:0];
        }
        WebContentView *view = [[WebContentView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        view.styles = styles;
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
    if (CGRectEqualToRect(self.bounds, CGRectZero))
    {
        self.bounds = CGRectMake(0, 0, 1, 1);
    }
    
    //defaults
    scrollEnabled = YES;
    
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
    [self sizeContentToFit];
}

- (void)refreshStyles
{
    self.styles = styles;
}

- (NSString *)allStyles
{
    NSArray *lines = [([[[self class] defaultStyles] stringByReplacingOccurrencesOfString:@"'" withString:@"\""] ?: @"")componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    lines = [lines arrayByAddingObjectsFromArray:[([styles stringByReplacingOccurrencesOfString:@"'" withString:@"\""] ?: @"")componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
    return [lines componentsJoinedByString:@" "];
}

- (void)setStyles:(NSString *)_styles
{
    if (styles != _styles)
    {
        [styles release];
        styles = [_styles retain];
    }
    
    if (webView.loading)
    {
        //abort and reload
        [webView stopLoading];
        self.content = content;
    }
    else
    {
        //update styles using javascript
        NSString *script = [NSString stringWithFormat:
                            @"var head = document.getElementsByTagName('head')[0];\
                            var style = document.getElementById('%@');\
                            if (style) { head.removeChild(style); }\
                            style = document.createElement('style');\
                            style.id = '%@';\
                            var text = document.createTextNode('%@');\
                            style.appendChild(text);\
                            head.appendChild(style);", STYLE_TAG, STYLE_TAG, [self allStyles]];
        [webView stringByEvaluatingJavaScriptFromString:script];
        [self performSelector:@selector(sizeContentToFit) withObject:nil afterDelay:0.1];
    }
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
        self.styles = styles;
    }
    else
    {
        NSString *html = content ?: @"";
        NSString *style = [NSString stringWithFormat:
                           @"<style id='%@' type='text/css'>%@</style>",
                           STYLE_TAG, [self allStyles]];
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
        [webView loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
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
	if (header)
	{
		headerHeight = header.frame.size.height;
		header.frame = CGRectMake(0, 0, self.bounds.size.width, headerHeight);
	}
	CGFloat footerHeight = 0;
	if (footer)
	{
		footerHeight = footer.frame.size.height;
	}
    webView.frame = CGRectMake(0, headerHeight, self.bounds.size.width,
                               self.bounds.size.height - headerHeight - footerHeight);
    [webView sizeToFit];
	if (footer)
	{
		footer.frame = CGRectMake(0, webView.frame.origin.y + webView.frame.size.height, self.bounds.size.width, footerHeight);
	}
    scrollView.contentSize = CGSizeMake(self.bounds.size.width, webView.frame.size.height + headerHeight + footerHeight);
}

- (void)flashScrollIndicators
{
    if (scrollView.contentSize.height > scrollView.bounds.size.height)
    {
        [scrollView flashScrollIndicators];
    }
}

- (void)setHeader:(UIView *)_header
{
    if (header != _header)
    {
        [header removeFromSuperview];
        [header release];
        header = [_header retain];
		if (header)
		{
			[scrollView addSubview:header];
		}
    }
    [self sizeContentToFit];
}

- (void)setFooter:(UIView *)_footer
{
    if (footer != _footer)
    {
        [footer removeFromSuperview];
        [footer release];
        footer = [_footer retain];
		if (footer)
		{
			[scrollView addSubview:footer];
		}
    }
    [self sizeContentToFit];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [scrollView release];
    [webView release];
    [header release];
    [footer release];
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
    [self performSelector:@selector(sizeContentToFit) withObject:nil afterDelay:0.1];
    
    if ([delegate respondsToSelector:@selector(webContentViewDidFinishLoad:)])
    {
        [(NSObject *)delegate performSelector:@selector(webContentViewDidFinishLoad:) withObject:self afterDelay:0.2];
    }
}

@end
