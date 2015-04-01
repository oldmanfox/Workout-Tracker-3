//
//  2-A-Days_17_Light_TVC.m
//  90 DWT 3
//
//  Created by Jared Grant on 1/12/14.
//  Copyright (c) 2014 Grant, Jared. All rights reserved.
//

#import "2-A-Days_17_Light_TVC.h"

@interface __A_Days_17_Light_TVC ()

@end

@implementation __A_Days_17_Light_TVC

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
                               @NO];
    
    NSArray *cellColor = @[@NO,
                           @NO,
                           @NO,
                           @NO,
                           @NO,
                           @NO,
                           @NO];
    
    [self configureTableView:tableCell :accessoryIcon :cellColor];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedRoutine = ((DataNavController *)self.parentViewController).routine;
    NSString *week = ((DataNavController *)self.parentViewController).week;
    
    NSArray *workoutArray = @[@"Dexterity",
                              @"Yoga",
                              @"Cardio Resistance",
                              @"Pilates",
                              @"Core I",
                              @"Core D",
                              @"Finished"];
    
    ((DataNavController *)self.parentViewController).workout = workoutArray[indexPath.row];
    
    // Normal routine
    if ([selectedRoutine isEqualToString:@"2-A-Days"]) {
        
        // Week 17
        if ([week isEqualToString:@"Week 17"]) {
            
            if (indexPath.row == 0) {
                
                // Dexterity 8
                ((DataNavController *)self.parentViewController).index = @8;
            }
            
            else if (indexPath.row == 1) {
                
                // Yoga 20
                ((DataNavController *)self.parentViewController).index = @20;
            }
            
            else if (indexPath.row == 2) {
                
                // Cardio Resistance 14
                ((DataNavController *)self.parentViewController).index = @14;
            }
            
            else if (indexPath.row == 3) {
                
                // Pilates 14
                ((DataNavController *)self.parentViewController).index = @14;
            }
            
            else if (indexPath.row == 4) {
                
                // Core I 14
                ((DataNavController *)self.parentViewController).index = @14;
            }
            
            else if (indexPath.row == 5) {
                
                // Core D 39
                ((DataNavController *)self.parentViewController).index = @39;
            }
            
            else if (indexPath.row == 6) {
                
                // Finished 4th Month
                ((DataNavController *)self.parentViewController).index = @2;
            }
        }
    }
    
    NSLog(@"%@ index = %@", ((DataNavController *)self.parentViewController).workout, ((DataNavController *)self.parentViewController).index);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *routineWeek;
    
    if (section == 0) {
        
        if ([((DataNavController *)self.parentViewController).week isEqualToString:@"Week 4"] ||
            [((DataNavController *)self.parentViewController).week isEqualToString:@"Week 8"] ||
            [((DataNavController *)self.parentViewController).week isEqualToString:@"Week 13"] ||
            [((DataNavController *)self.parentViewController).week isEqualToString:@"Week 17"]) {
            
            routineWeek = [((DataNavController *)self.parentViewController).routine stringByAppendingFormat:@" - %@ - Light", ((DataNavController *)self.parentViewController).week];
        }
    }
    
    return routineWeek;
}
@end
