//
//  Tone_5-7_TVC.m
//  90 DWT 3
//
//  Created by Jared Grant on 1/5/14.
//  Copyright (c) 2014 Grant, Jared. All rights reserved.
//

#import "Tone_5-7_TVC.h"

@interface Tone_5_7_TVC ()

@end

@implementation Tone_5_7_TVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Show or Hide Ads
    if ([[DWT3IAPHelper sharedInstance] productPurchased:@"com.grantsoftware.90DWT3.removeads1"]) {
        
        // User purchased the Remove Ads in-app purchase so don't show any ads.
        self.canDisplayBannerAds = NO;
        
    } else {
        
        // Show the Banner Ad
        self.canDisplayBannerAds = YES;
    }

    // Configure tableview.
    NSArray *tableCell = @[self.cell1,
                           self.cell2,
                           self.cell3,
                           self.cell4,
                           self.cell5,
                           self.cell6,
                           self.cell7];
    
    NSArray *accessoryIcon = @[@YES,
                               @YES,
                               @YES,
                               @YES,
                               @YES,
                               @YES,
                               @YES];
    
    NSArray *cellColor = @[@NO,
                           @NO,
                           @NO,
                           @NO,
                           @NO,
                           @NO,
                           @NO];
    [self configureTableView:tableCell :accessoryIcon: cellColor];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    // Show or Hide Ads
    if ([[DWT3IAPHelper sharedInstance] productPurchased:@"com.grantsoftware.90DWT3.removeads1"]) {
        
        // User purchased the Remove Ads in-app purchase so don't show any ads.
        self.canDisplayBannerAds = NO;
        
    } else {
        
        // Show the Banner Ad
        self.canDisplayBannerAds = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 7;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    NSString *week = ((DataNavController *)self.parentViewController).week;
    NSArray *workoutArray;
    
    workoutArray = @[@"Plyometrics T",
                     @"Gladiator",
                     @"Yoga",
                     @"MMA",
                     @"Devastator",
                     @"Cardio Resistance",
                     @"Core D"];
    
    ((DataNavController *)self.parentViewController).workout = workoutArray[indexPath.row];
    
    // Week 5
    if ([week isEqualToString:@"Week 5"]) {
        
        if (indexPath.row == 0) {
            
            // Plyometrics T 1
            ((DataNavController *)self.parentViewController).index = @1;
        }
        
        else if (indexPath.row == 1) {
            
            // Gladiator 4
            ((DataNavController *)self.parentViewController).index = @4;
        }
        
        else if (indexPath.row == 2) {
            
            // Yoga 5
            ((DataNavController *)self.parentViewController).index = @5;
        }
        
        else if (indexPath.row == 3) {
            
            // MMA 1
            ((DataNavController *)self.parentViewController).index = @1;
        }
        
        else if (indexPath.row == 4) {
            
            // Devastator 1
            ((DataNavController *)self.parentViewController).index = @1;
        }
        
        else if (indexPath.row == 5) {
            
            // Cardio Resistance 4
            ((DataNavController *)self.parentViewController).index = @4;
        }
        
        else if (indexPath.row == 6) {
            
            // Core D 6
            ((DataNavController *)self.parentViewController).index = @6;
        }
    }
    
    // Week 6
    else if ([week isEqualToString:@"Week 6"]) {
        
        if (indexPath.row == 0) {
            
            // Plyometrics T 2
            ((DataNavController *)self.parentViewController).index = @2;
        }
        
        else if (indexPath.row == 1) {
            
            // Gladiator 5
            ((DataNavController *)self.parentViewController).index = @5;
        }
        
        else if (indexPath.row == 2) {
            
            // Yoga 6
            ((DataNavController *)self.parentViewController).index = @6;
        }
        
        else if (indexPath.row == 3) {
            
            // MMA 2
            ((DataNavController *)self.parentViewController).index = @2;
        }
        
        else if (indexPath.row == 4) {
            
            // Devastator 2
            ((DataNavController *)self.parentViewController).index = @2;
        }
        
        else if (indexPath.row == 5) {
            
            // Cardio Resistance 5
            ((DataNavController *)self.parentViewController).index = @5;
        }
        
        else if (indexPath.row == 6) {
            
            // Core D 7
            ((DataNavController *)self.parentViewController).index = @7;
        }
    }
    
    // Week 7
    else if ([week isEqualToString:@"Week 7"]) {
        
        if (indexPath.row == 0) {
            
            // Plyometrics T 3
            ((DataNavController *)self.parentViewController).index = @3;
        }
        
        else if (indexPath.row == 1) {
            
            // Gladiator 6
            ((DataNavController *)self.parentViewController).index = @6;
        }
        
        else if (indexPath.row == 2) {
            
            // Yoga 7
            ((DataNavController *)self.parentViewController).index = @7;
        }
        
        else if (indexPath.row == 3) {
            
            // MMA 3
            ((DataNavController *)self.parentViewController).index = @3;
        }
        
        else if (indexPath.row == 4) {
            
            // Devastator 3
            ((DataNavController *)self.parentViewController).index = @3;
        }
        
        else if (indexPath.row == 5) {
            
            // Cardio Resistance 6
            ((DataNavController *)self.parentViewController).index = @6;
        }
        
        else if (indexPath.row == 6) {
            
            // Core D 8
            ((DataNavController *)self.parentViewController).index = @8;
        }
    }
    
    //NSLog(@"%@ index = %@", ((DataNavController *)self.parentViewController).workout, ((DataNavController *)self.parentViewController).index);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section ==0) {
        
        NSString *routineWeek = [((DataNavController *)self.parentViewController).routine stringByAppendingFormat:@" - %@", ((DataNavController *)self.parentViewController).week];
        return routineWeek;
    }
    
    else {
        
        return @"";
    }
}
@end
