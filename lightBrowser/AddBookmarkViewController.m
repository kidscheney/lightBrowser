//
//  AddBookmarkViewController.m
//  lightBrowser
//
//  Created by Cheney on 1/7/16.
//  Copyright © 2016 Cheney. All rights reserved.
//

#import "AddBookmarkViewController.h"
#define frame_width (self.view.frame.size.width)
#define frame_height (self.view.frame.size.height)

@interface AddBookmarkViewController ()

@property (strong,nonatomic) UITextField * websiteNameField;
@property (strong,nonatomic) UITextField * websiteURLField;

@property (strong,nonatomic) NSURL * websiteURL;
@property (strong,nonatomic) NSString * websiteName;

@property (strong,nonatomic) NSUserDefaults * bookmarkInfo;
@property (strong,nonatomic) NSMutableArray * bookmarkArray;

@end

@implementation AddBookmarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Add Bookmark";
    
    [self configCancelBarItem];
    [self configSaveBarItem];
    [self configUI];
    [self configUserdefaults];

}

/////init method

- (void) setURL:(NSURL*) url websiteTitle:(NSString*) title {
    self.websiteURL = url;
    self.websiteName = title;
    
    NSLog(@"----------------------");
    NSLog(@"bookmark url - %@",url);
    NSLog(@"bookmark name - %@",title);
    NSLog(@"----------------------");
}

//////////////////////*******config view*******///////////////////
#pragma - config navigation bar item

- (void) configCancelBarItem {
    UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.leftBarButtonItem = cancelItem;
}

- (void) configSaveBarItem {
    UIBarButtonItem * saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction:)];
    self.navigationItem.rightBarButtonItem = saveItem;
}

#pragma - config UI

- (void) configUI {
    //website name textfield
    UITextField *websiteNameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 80, frame_width, 35)];
    
    websiteNameField.borderStyle = UITextBorderStyleRoundedRect;
    websiteNameField.backgroundColor = [UIColor whiteColor];
    websiteNameField.placeholder = @"Enter bookmark name";
    [websiteNameField becomeFirstResponder];
    websiteNameField.keyboardType = UIKeyboardTypeDefault;
    websiteNameField.layer.opacity = 0.75f;
    websiteNameField.borderStyle = UITextBorderStyleNone;
    
    [websiteNameField setText:self.websiteName];
    
    self.websiteNameField = websiteNameField;
    
    
    //website name textfield
    UITextField *websiteURLField = [[UITextField alloc] initWithFrame:CGRectMake(0, 117, frame_width, 35)];
    
    websiteURLField.borderStyle = UITextBorderStyleRoundedRect;
    websiteURLField.backgroundColor = [UIColor whiteColor];
    websiteURLField.userInteractionEnabled = NO;
    websiteURLField.layer.opacity = 0.6f;
    websiteURLField.borderStyle = UITextBorderStyleNone;
    websiteURLField.placeholder = @"URL is not ready";
    
    [websiteURLField setText:self.websiteURL.absoluteString];
    
    self.websiteURLField = websiteURLField;
    
    [self.view addSubview:websiteURLField];
    [self.view addSubview:websiteNameField];

}

#pragma - config userdefaults
- (void) configUserdefaults {
    NSUserDefaults *bookmarkInfo = [NSUserDefaults standardUserDefaults];
    self.bookmarkInfo = bookmarkInfo;
}


//////////////////////*******interaction******///////////////////

#pragma - Handel method ]

- (void) cancelAction:(id) sender {
    //change push direction
    CATransition* transition = [CATransition animation];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromTop;
    transition.duration = 0.5f;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (void) saveAction:(id) sender {
    //get text if text changed
    self.websiteName = self.websiteNameField.text;
    
    if ( [self.websiteName isEqualToString:@""] ) {
        UIAlertController* alertVC = [UIAlertController alertControllerWithTitle:@"Tips" message:@"Please enter bookmark name!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertVC addAction:alertAction];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
    else {
        //set user defaults
        NSDictionary* dic = [[NSDictionary alloc] initWithObjectsAndKeys:self.websiteURL.absoluteString,self.websiteName, nil];
        
        self.bookmarkArray = [[NSMutableArray alloc] init];
        [self.bookmarkArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"bookmark"]];
        [self.bookmarkArray addObject:dic];
    
        [self.bookmarkInfo setObject:self.bookmarkArray forKey:@"bookmark"];
        [self.bookmarkInfo synchronize];
    }
    
    //pop view controller after save bookmark
    CATransition* transition = [CATransition animation];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromTop;
    transition.duration = 0.5f;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    
    [self.navigationController popViewControllerAnimated:NO];
}

/////////////////////*Orientation*//////////////////////
//check the orientation
- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    switch ( toInterfaceOrientation ) {
        case UIInterfaceOrientationPortrait:
            [self.websiteNameField setFrame:CGRectMake(0, 80, frame_height, 35)];
            [self.websiteURLField setFrame:CGRectMake(0, 117, frame_height, 35)];
            
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [self.websiteNameField setFrame:CGRectMake(0, 80, frame_height, 35)];
            [self.websiteURLField setFrame:CGRectMake(0, 117, frame_height, 35)];

            break;
        case UIInterfaceOrientationLandscapeRight:
            [self.websiteNameField setFrame:CGRectMake(0, 80, frame_height, 35)];
            [self.websiteURLField setFrame:CGRectMake(0, 117, frame_height, 35)];
            
            break;
        case UIInterfaceOrientationPortraitUpsideDown:            
            break;
        default:
            break;
    }
}


@end
