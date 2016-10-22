//
//  mainViewController.m
//  lightBrowser
//
//  Created by Cheney on 12/27/15.
//  Copyright © 2015 Cheney. All rights reserved.
//

#import "mainViewController.h"

#define frame_width self.view.frame.size.width
#define frame_height self.view.frame.size.height
#define bounds_width self.view.bounds.size.width
#define bounds_height self.view.bounds.size.height
#define frame_original self.view.frame.origin

@interface mainViewController ()<UITextFieldDelegate>

@property (assign,nonatomic) UITextField *siteView;
@property (strong,nonatomic) UIToolbar * toolBar;
@property (strong,nonatomic) UIButton * GoBtn;
@property (assign,nonatomic) CGFloat keyboardHeight;

@end

@implementation mainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    self.title = @"lightBrowser";
    
    [self configSiteView];
    [self configNotification];
    [self configBookmarkItem];
    
    NSLog(@"----------------------");
    NSLog(@"view did load");
    NSLog(@"----------------------");
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self adjustWillAppearOrientation];
    
    NSLog(@"----------------------");
    NSLog(@"view will appear");
    NSLog(@"----------------------");
    
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"----------------------");
    NSLog(@"view did appear");
    NSLog(@"----------------------");
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"----------------------");
    NSLog(@"view will disappear");
    NSLog(@"----------------------");
}

- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"----------------------");
    NSLog(@"view did disappear");
    NSLog(@"----------------------");
}

#pragma mark - will appear 

- (void) adjustWillAppearOrientation {
    //revise the tool bar frame after pop controller with change orientation
    if ([UIDevice currentDevice].orientation == UIInterfaceOrientationPortrait ) {
        NSLog(@"UIInterfaceOrientationPortrait");
        if ( frame_width>frame_height ) {
            [self.toolBar setFrame:CGRectMake(0,frame_height-44 ,frame_height, 44)];
        }
        else {
            [self.toolBar setFrame:CGRectMake(0,frame_height-44 ,frame_width, 44)];
        }
        NSLog(@"%f,%f,%f,%f",frame_width,frame_height,bounds_width,bounds_height);
    }
    else if ( [UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeLeft ) {
        NSLog(@"UIInterfaceOrientationLandscapeLeft");
        if ( frame_height>frame_width ) {
            [self.toolBar setFrame:CGRectMake(0,frame_height-44 ,frame_height, 44)];
        }
        else {
            [self.toolBar setFrame:CGRectMake(0,frame_height-44 ,frame_width, 44)];
        }
        NSLog(@"%f,%f,%f,%f",frame_width,frame_height,bounds_width,bounds_height);
    }
    else if ( [UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeRight ) {
        NSLog(@"UIInterfaceOrientationLandscapeRight ");
        if ( frame_height>frame_width ) {
            [self.toolBar setFrame:CGRectMake(0,frame_height-44 ,frame_height, 44)];
        }
        else {
            [self.toolBar setFrame:CGRectMake(0,frame_height-44 ,frame_width, 44)];
        }
        NSLog(@"%f,%f,%f,%f",frame_width,frame_height,bounds_width,bounds_height);
    }
    else if ( [UIDevice currentDevice].orientation == UIDeviceOrientationUnknown ) {
        NSLog(@"UIDeviceOrientationUnknown");
        
    }
}

#pragma - config site view
- (void) configSiteView {
    //text field
    CGFloat siteTextWidth = (self.view.frame.size.width/3)*2;
    CGFloat siteTextHeigh = 28;
    
    UITextField * siteView = [[UITextField alloc] initWithFrame:CGRectMake(0,0, siteTextWidth, siteTextHeigh)];

    siteView.backgroundColor = [UIColor whiteColor];
    siteView.placeholder = @"Enter website name";
    siteView.textAlignment = NSTextAlignmentCenter;
    siteView.borderStyle = UITextBorderStyleRoundedRect;
    siteView.keyboardType = UIKeyboardTypeASCIICapable;
    siteView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    siteView.delegate = self;
    
    [self.view addSubview:siteView];
    self.siteView = siteView;
    
    //Go button
    UIButton* goBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 25, siteTextHeigh)];
    [goBtn setTitle:@"Go" forState:UIControlStateNormal];
    [goBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [goBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [goBtn addTarget:self action:@selector(goBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:goBtn];
    self.GoBtn = goBtn;
    
    //add the text field and Go button to the tool bar
    UIBarButtonItem * URLItem = [[UIBarButtonItem alloc] initWithCustomView:siteView];
    UIBarButtonItem * GoItem = [[UIBarButtonItem alloc] initWithCustomView:goBtn];
    UIBarButtonItem * spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray * toolItems = [NSArray arrayWithObjects: spaceItem,spaceItem,URLItem,GoItem,spaceItem,spaceItem,nil];
    UIToolbar * toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height-44 , self.view.frame.size.width, 44)];
    
    toolBar.items = toolItems;
    [toolBar setBarStyle:UIBarStyleDefault];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    [self.view addSubview:toolBar];
    self.toolBar = toolBar;
}

- (void) configNotification {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma - bookmark item 
- (void) configBookmarkItem {
    UIBarButtonItem * bookmarkItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(bookmarkItemAction:)];
    self.navigationItem.rightBarButtonItem = bookmarkItem;
}

#pragma - handle method

- (void) goBtnPressed {
    //get rid of space
    self.siteView.text = [self.siteView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString * site = self.siteView.text;
    NSString * sitePrefix = @"http://";
    
    if ( [site isEqual: @""] ) {
        site = @"https://m.baidu.com/";
        ViewController * browserVC = [[ViewController alloc] initURL:site];
        [self.navigationController pushViewController:browserVC animated:YES];
    }
    else if ( ![site containsString:@"."] ) {
        for ( int i = 0; i < self.siteView.text.length; i++ ) {
            unichar c = [site characterAtIndex:i];
            if  ( c >=0x4E00 && c <=0x9FFF ) {//check if string is chinese
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Tips" message:@"Please do not enter Chinese!" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:alertAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }

        NSString * searchStr = @"http://m.baidu.com/s?word=";
        site = [searchStr stringByAppendingString:site];
        
        ViewController * browserVC = [[ViewController alloc] initURL:site];
        [self.navigationController pushViewController:browserVC animated:YES];
    }
    else {
        for ( int i = 0; i < self.siteView.text.length; i++ ) {
            unichar c = [site characterAtIndex:i];
            if  ( c >=0x4E00 && c <=0x9FFF ) {//check if string is chinese
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Tips" message:@"Please do not enter Chinese!" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:alertAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
        
        if ( [site hasPrefix:@"http://"] | [site hasPrefix:@"https://"] ) {
            ViewController * browserVC = [[ViewController alloc] initURL:site];
            [self.navigationController pushViewController:browserVC animated:YES];

        }
        else {
            ViewController * browserVC = [[ViewController alloc] initURL:[sitePrefix stringByAppendingString:site]];
            [self.navigationController pushViewController:browserVC animated:YES];
        }
    }
    
    [self.siteView resignFirstResponder];
}

- (void) bookmarkItemAction:(id) sender {
    bookmarkListViewController * bookmarkVC = [[bookmarkListViewController alloc] init];
    
    //resige the tool bar responder
    [self.siteView resignFirstResponder];
    
    //change the push direction
    CATransition * transition = [CATransition animation];
    transition.type = kCATransitionFade;
    transition.duration = 0.6f;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    
    [self.navigationController pushViewController:bookmarkVC animated:NO];
}

//resign the keyboard
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    UIView * view = touch.view;
    if ( view == self.view ) {
        [self.siteView resignFirstResponder];
    }
}

//check the orientation
- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    switch ( toInterfaceOrientation ) {
        case UIInterfaceOrientationPortrait:
            NSLog(@"UIInterfaceOrientationPortrait");
            [self.toolBar setFrame:CGRectMake(0,frame_height-44 ,frame_height, 44)];
            NSLog(@"%f,%f,%f,%f",frame_width,frame_height,bounds_width,bounds_height);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            NSLog(@"UIInterfaceOrientationLandscapeLeft");
            if ( frame_height>frame_width ) {
                [self.toolBar setFrame:CGRectMake(0,frame_height-44 ,frame_height, 44)];
            }
            else {
                [self.toolBar setFrame:CGRectMake(0,frame_height-44 ,frame_width, 44)];
            }
        NSLog(@"%f,%f,%f,%f",frame_width,frame_height,bounds_width,bounds_height);
            break;
        case UIInterfaceOrientationLandscapeRight:
            NSLog(@"UIInterfaceOrientationLandscapeRight");
            if ( frame_height>frame_width ) {
                [self.toolBar setFrame:CGRectMake(0,frame_height-44 ,frame_height, 44)];
            }
            else {
                [self.toolBar setFrame:CGRectMake(0,frame_height-44 ,frame_width, 44)];
            }
            NSLog(@"%f,%f,%f,%f",frame_width,frame_height,bounds_width,bounds_height);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            NSLog(@" UIInterfaceOrientationPortraitUpsideDown");
            NSLog(@"%f,%f,%f,%f",frame_width,frame_height,bounds_width,bounds_height);
            break;
        default:
            break;
    }
}

//rise up the textfield when enter the URL
- (void) keyboardWillShow:(NSNotification*) aNotification {
    NSDictionary * keyboardDic = [aNotification userInfo];
    NSValue *keyboardValue = [keyboardDic objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [keyboardValue CGRectValue];
    self.keyboardHeight = keyboardRect.size.height;
    
    //rise up the text field
    if ( self.view.frame.size.height == [[UIScreen mainScreen] bounds].size.height ) {
        self.view.frame = [[UIScreen mainScreen] bounds];
        self.view.frame = CGRectOffset(self.view.frame, 0, -(self.keyboardHeight));
    }
    
    NSLog(@"keyboard show");
    NSLog(@"keyboardHeight: %f",self.keyboardHeight);
}

- (void) keyboardWillHide:(NSNotification*) aNotification {
    //put down the text field
    
    [UIView beginAnimations:@"textFieldUp" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0];

    self.view.frame = [[UIScreen mainScreen] bounds];
    
    [UIView commitAnimations];

    NSLog(@"keyboard hide");
    
    /*only touch began and press go button ,will trigger out the resign the first responder*/
}

#pragma mark - dealloc

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIKeyboardWillHideNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIKeyboardWillShowNotification];
    NSLog(@"main view dealloc");
}

@end
