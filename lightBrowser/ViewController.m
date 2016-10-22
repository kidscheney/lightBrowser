//
//  ViewController.m
//  lightBrowser
//
//  Created by Cheney on 12/27/15.
//  Copyright © 2015 Cheney. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#define IOS8x ([[UIDevice currentDevice].systemVersion floatValue] >=8.0)

@interface ViewController ()<UIWebViewDelegate,UIActionSheetDelegate,WKNavigationDelegate>

@property (assign,nonatomic) NSInteger loadCount;
@property (strong,nonatomic) UIProgressView *progressView;
@property (strong,nonatomic) UIWebView * webView;
@property (strong,nonatomic) WKWebView * wkWebView;
@property (strong,nonatomic) NSURL * homeURL;
@property (strong,nonatomic) NSString* urlString;
@property (strong,nonatomic) NSURL * bookmarkURL;
@property (strong,nonatomic) NSString * webviewTitle;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"lightBrowser";
    [self.navigationController setNavigationBarHidden:NO animated:YES];//init not show
    
    [self configUI];
    [self configHomeButton];
    [self configBackAndForward];
    [self configAddButton];
    [self configSwipeGestureRecognizer];
    [self configDoubleTapGestureRecognizer];//need two fingers
    [self configSingleTapGestureRecognizer];//need three fingers
}
////////////////////////////////////////////////////////////////////////////
#pragma init and set URL
- (ViewController*) initURL:(NSString*) url {
//    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.urlString = url;
    self.homeURL = [NSURL URLWithString:url];
    return self;
}

////////////////////////////////////////////////////////////////////////////
#pragma - customize view
- (void) configUI {
    //init progress view
    UIProgressView * progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    progressView.tintColor = [UIColor greenColor];
    progressView.trackTintColor = [UIColor whiteColor];
    [self.view addSubview:progressView];
    self.progressView = progressView;
    
    //init web view
    if (IOS8x) {
        WKWebView * wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        wkWebView.backgroundColor = [UIColor whiteColor];
        wkWebView.navigationDelegate = self;
        [self.view insertSubview:wkWebView belowSubview:progressView];
        
        [wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        NSURLRequest * request = [NSURLRequest requestWithURL:self.homeURL];
        [wkWebView loadRequest:request];
        self.wkWebView = wkWebView;
    }
    else {
        UIWebView * webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        webView.scalesPageToFit = YES;
        webView.backgroundColor = [UIColor whiteColor];
        webView.delegate = self;
        [self.view insertSubview:webView belowSubview:progressView];
        
        NSURLRequest * request = [NSURLRequest requestWithURL:self.homeURL];
        [webView loadRequest:request];
        self.webView = webView;
    }
}

- (void) configBackAndForward {
    //back item
    UIImage * backImage = [UIImage imageNamed:@"back.png"];
    backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 17)];
    [backButton setBackgroundImage:backImage forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor blueColor]];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //forward item
    UIImage * forwardImage = [UIImage imageNamed:@"forward.png"];
    forwardImage = [forwardImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton * forwardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 17)];
    [forwardButton setImage:forwardImage forState:UIControlStateNormal];
    [forwardButton setTintColor:[UIColor blueColor]];
    [forwardButton addTarget:self action:@selector(forwardAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //add bar items
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    UIBarButtonItem * forwardItem = [[UIBarButtonItem alloc] initWithCustomView:forwardButton];
    UIBarButtonItem * flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray * leftItems = [NSArray arrayWithObjects:backItem,flexibleItem,forwardItem, flexibleItem,flexibleItem,nil];
    self.navigationItem.leftBarButtonItems = leftItems;
}

- (void) configAddButton {
    UIBarButtonItem * addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(addActionItem:)];
    self.navigationItem.rightBarButtonItem = addItem;
}

- (void) configHomeButton {
    UIButton * homeButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 44, 20)];
    
    [homeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [homeButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [homeButton setTitle:@"lightBrowser" forState:UIControlStateNormal];
    
    [homeButton sizeToFit];
    [homeButton addTarget:self action:@selector(homeBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.titleView = homeButton;
}

- (void) configSwipeGestureRecognizer {
    UISwipeGestureRecognizer * swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeftGesture.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:swipeLeftGesture];
    
    UISwipeGestureRecognizer * swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRightGesture.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:swipeRightGesture];
}

- (void) configDoubleTapGestureRecognizer {
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:tapGesture];
}

- (void) configSingleTapGestureRecognizer {
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 3;
    [self.view addGestureRecognizer:tapGesture];
}

////////////////////////////////////////////////////////////////////////////
#pragma handle method
- (void) homeBtnPressed {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void) backAction:(id) sender {
    if ( IOS8x ) {
        if ( self.wkWebView.canGoBack ) {
            [self.wkWebView goBack];
        }
        else {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    else {
        if ( self.webView.canGoBack ) {
            [self.webView goBack];
        }
        else {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (void) forwardAction:(id) sender {
    if ( IOS8x ) {
        if ( self.wkWebView.canGoForward ) {
            [self.wkWebView goForward];
        }
    }
    else {
        if ( self.webView.canGoForward ) {
            [self.webView goForward];
        }
    }
}

- (void) addActionItem:(id) sender {
    UIAlertController * bookmarkActionSheet = [UIAlertController alertControllerWithTitle:@"Add Bookmark" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    bookmarkActionSheet.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    
    UIAlertAction * bookmarkAction = [UIAlertAction actionWithTitle:@"Add to Bookmark List" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        
        NSLog(@"bookURL - %@",self.bookmarkURL);
        
        //Bookmark VC
        AddBookmarkViewController * addBookmarkVC = [[AddBookmarkViewController alloc] init];
        [addBookmarkVC setURL:self.bookmarkURL websiteTitle:self.webviewTitle];
        
        //change push direction
        CATransition* transition = [CATransition animation];
        transition.type = kCATransitionReveal;
        transition.subtype = kCATransitionFromBottom;
        transition.duration = 0.6f;
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        
        [self.navigationController pushViewController:addBookmarkVC animated:NO];
        
    }];
    UIAlertAction * bookmarkCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [bookmarkActionSheet addAction:bookmarkAction];
    [bookmarkActionSheet addAction:bookmarkCancel];
    
    [self presentViewController:bookmarkActionSheet animated:YES completion:nil];
}

//loading pregress with observer (system version >=8.0)
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ( self.wkWebView == object && [keyPath isEqualToString:@"estimatedProgress"] ) {
        CGFloat newProgress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if ( newProgress == 1 ) {
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        }
        else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newProgress animated:YES];
        }
    }
}

//loading pregress with observer (system version < 8.0)
- (void) setLoadCount:(NSInteger)loadCount {
    _loadCount = loadCount;
    if ( loadCount == 0 ) {
        self.progressView.hidden = YES;
        [self.progressView setProgress:0 animated:NO];
    }
    else {
        self.progressView.hidden = NO;
        CGFloat oldP = self.progressView.progress;
        CGFloat newP = oldP + (1-oldP)/(loadCount + 1);
        if ( newP > 0.95 ) {
            newP = 0.95;
        }
        [self.progressView setProgress:newP animated:YES];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.loadCount ++;
    NSLog(@"-----------------------------");
    NSLog(@"did start load");
    NSLog(@"-----------------------------");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.loadCount --;
    NSLog(@"-----------------------------");
    NSLog(@"did finish load");
    NSLog(@"-----------------------------");

}

- (void)webView:(WKWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    self.loadCount --;
    NSLog(@"-----------------------------");
    NSLog(@"did fail load with error");
    NSLog(@"-----------------------------");
}

///Gesture Recognize method
- (void) handleSwipeGesture:(UISwipeGestureRecognizer*) swipGestureRecognizer {
    if ( swipGestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        
        if ( IOS8x ) {
            if ( self.wkWebView.canGoBack ) {
                [self.wkWebView goBack];
            }
            else {
                [self.navigationController setNavigationBarHidden:NO animated:NO];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
        else {
            if ( self.webView.canGoBack ) {
                [self.webView goBack];
            }
            else {
                [self.navigationController setNavigationBarHidden:NO animated:NO];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    
        NSLog(@"swipe left gesture");
    }
    
    else if ( swipGestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft ) {
        
        if ( IOS8x ) {
            if ( self.wkWebView.canGoForward ) {
                [self.wkWebView goForward];
            }
        }
        else {
            if ( self.webView.canGoForward ) {
                [self.webView goForward];
            }
        }
        
        NSLog(@"swip right gesture");
    }

}

- (void) handleDoubleTapGesture:(UITapGestureRecognizer *)TabGestureRecognizer {
    if ( [self.navigationController isNavigationBarHidden] == YES) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    else if ( [self.navigationController isNavigationBarHidden] == NO ) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
    NSLog(@"double tap gesture");
}

- (void) handleSingleTapGesture:(UITapGestureRecognizer *)TabGestureRecognizer {
    if ( IOS8x ) {
        [self.wkWebView reload];
    }
    else {
        [self.webView reload];
    }
    NSLog(@"single tap gesture");
}

/******************
 
 webview delegate
 
*******************/
- (void) webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"did fail provision,will search with baidu");
    
    if ( [self.urlString hasPrefix:@"http://"] ) {
        self.urlString = [self.urlString substringFromIndex:7];
    }
    else if ( [self.urlString hasPrefix:@"https:// "] ) {
        self.urlString = [self.urlString substringFromIndex:8];
    }
    
    NSString* searchStr = @"http://www.baidu.com/s?word=";
    self.homeURL = [NSURL URLWithString:[searchStr stringByAppendingString:self.urlString]];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:self.homeURL];
    [self.wkWebView loadRequest:request];
}

- (void) webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"-----------------------------");
    NSLog(@"did start provisional");
    NSLog(@"%@",navigation);
    NSLog(@"-----------------------------");
}

- (void) webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
    NSLog(@"-----------------------------");
    NSLog(@"did commint navigation");
    NSLog(@"%@",navigation);
    NSLog(@"-----------------------------");
    //estimated progress of load web
    NSLog(@"-----------------------------");
    NSLog(@"%f",self.wkWebView.estimatedProgress);
    NSLog(@"-----------------------------");
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"-----------------------------");
    NSLog(@"reponse URL -  %@",navigationResponse.response.URL);
    NSLog(@"reponse MIME- %@",navigationResponse.response.MIMEType);
    NSLog(@"reponse suggestedName - %@",navigationResponse.response.suggestedFilename);
    NSLog(@"wkWebView title - %@",self.wkWebView.title);
    NSLog(@"-----------------------------");
    
    //self.bookmarkURL = navigationResponse.response.URL;//book mark
    //get bookmark
    self.bookmarkURL = self.wkWebView.URL;
    
    if ( IOS8x ) {
        self.webviewTitle = self.wkWebView.title;
    }
    else {
        self.webviewTitle = @"";
    }
    
    
    decisionHandler(WKNavigationResponsePolicyAllow);
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"-----------------------------");
    NSLog(@"action -  %@",navigationAction.request);
    NSLog(@"-----------------------------");
    
    if ([webView.URL.absoluteString hasPrefix:@"https://itunes.apple.com"]) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    
    //load the action
    if ( !navigationAction.targetFrame ) {
        [self.wkWebView loadRequest:navigationAction.request];
        NSLog(@"targetFrame - %@",navigationAction.targetFrame);
    }
    
//    if (!navigationAction.targetFrame.isMainFrame) {
//        [webView evaluateJavaScript:@"var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" completionHandler:nil];
//    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"-----------------------------");
    NSLog(@"did start load with request");
    NSLog(@"-----------------------------");
    return YES;
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"-----------------------------");
    NSLog(@"did receive server redirect");
    NSLog(@"-----------------------------");
    
}

//webview delegate about js

-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame) {
        [self.wkWebView loadRequest:navigationAction.request];
        NSLog(@"targetFrame in create new - %@",navigationAction.targetFrame);
    }
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"Tips" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * alertOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:alertOK];
    [self presentViewController:alertVC animated:YES completion: nil];
    
    NSLog(@"-----------------------------");
    NSLog(@"runJavaScriptAlertPanelWithMessage");
    NSLog(@"-----------------------------");

}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"Tips" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * alertOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:alertOK];
    [self presentViewController:alertVC animated:YES completion: nil];
    
    NSLog(@"-----------------------------");
    NSLog(@"runJavaScriptAlertConfirmWithMessage");
    NSLog(@"-----------------------------");

}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"Tips" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * alertOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:alertOK];
    [self presentViewController:alertVC animated:YES completion: nil];
    
    NSLog(@"-----------------------------");
    NSLog(@"runJavaScriptAlertTextInputWithMessage");
    NSLog(@"-----------------------------");


}

//js
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    NSLog(@"==================");
    NSLog(@"get js");
    NSLog(@"==================");
    
    WKUserScript *script = [[WKUserScript alloc] initWithSource:message.body injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    // 根据生成的WKUserScript对象，初始化WKWebViewConfiguration
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [config.userContentController addUserScript:script];
    
    NSURL * url = self.wkWebView.URL;
    self.wkWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:config];
    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:url]];

}





////////////////////////////////////////////////////////////////////////////

#pragma dealloc
- (void) dealloc {
    if ( IOS8x ) {
        [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
    NSLog(@"webview contorller dealloc");
}


@end
