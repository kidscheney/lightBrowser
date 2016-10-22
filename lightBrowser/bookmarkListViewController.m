//
//  bookmarkListViewController.m
//  lightBrowser
//
//  Created by Cheney on 1/9/16.
//  Copyright © 2016 Cheney. All rights reserved.
//

#import "bookmarkListViewController.h"

@interface bookmarkListViewController ()

@property (strong,nonatomic) NSUserDefaults * bookmarkInfo;
@property (strong,nonatomic) NSMutableArray * bookmarkArray;

@end

@implementation bookmarkListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Bookmarks";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configBarbuttonItem];
    [self configUserdefaults];
}

- (void)viewWillAppear:(BOOL)animated {
    self.bookmarkArray = [self.bookmarkInfo objectForKey:@"bookmark"];
    
    [self.tableView reloadData];
}

#pragma mark - config bar item

- (void) configBarbuttonItem {
    //back item
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backItemAction:)];
    self.navigationItem.leftBarButtonItem = backItem;
}

#pragma mark - config user defaults
- (void) configUserdefaults {
    self.bookmarkInfo = [NSUserDefaults standardUserDefaults];
}

#pragma mark - item action 
- (void) backItemAction:(id) sender {
    //push from top to bottom
    CATransition* transition = [CATransition animation];
    transition.type = kCATransitionFade;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bookmarkArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    
    // Configure the cell...
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    
    cell.textLabel.text = [[[self.bookmarkArray objectAtIndex:[indexPath row]] allKeys] objectAtIndex:0];
    cell.textLabel.layer.opacity = 0.74f;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    
        //delete user defaults
        NSMutableArray * bookmarkArray = [[NSMutableArray alloc] init];
        [bookmarkArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"bookmark"]];
        [bookmarkArray removeObjectAtIndex:[indexPath row]];
        [[NSUserDefaults standardUserDefaults] setObject:bookmarkArray forKey:@"bookmark"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //update the rows
        self.bookmarkArray = [self.bookmarkInfo objectForKey:@"bookmark"];
        
        //delete the data source row
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //get userdefaults info
    NSMutableArray * bookmarkArray = [[NSMutableArray alloc] init];
    [bookmarkArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"bookmark"]];
    
    //get selected URL
    NSString* keySelected = [[[bookmarkArray objectAtIndex:[indexPath row]] allKeys] objectAtIndex:0];
    NSString * urlStrSelected = [[bookmarkArray objectAtIndex:[indexPath row]] objectForKey:keySelected];
    NSLog(@"bookmark str -  %@",urlStrSelected);
    
    //go net with URL selceted
    ViewController * browserVC = [[ViewController alloc] initURL:urlStrSelected];
    [self.navigationController pushViewController:browserVC animated:YES];
}

@end
