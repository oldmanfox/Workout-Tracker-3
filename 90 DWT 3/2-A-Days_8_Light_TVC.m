//
//  2-A-Days_8_Light_TVC.m
//  90 DWT 3
//
//  Created by Jared Grant on 1/12/14.
//  Copyright (c) 2014 Grant, Jared. All rights reserved.
//

#import "2-A-Days_8_Light_TVC.h"

@interface __A_Days_8_Light_TVC ()

@end

@implementation __A_Days_8_Light_TVC

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
                           self.cell7,
                           self.cell8];
    
    NSArray *accessoryIcon = @[@YES,
                               @YES,
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
                           @NO,
                           @NO];
    
    [self configureTableView:tableCell :accessoryIcon: cellColor];
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
    return 7;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        
        return 1;
    }
    
    else if (section == 1) {
        
        return 1;
    }
    
    else if (section == 2) {
        
        return 1;
    }
    
    else if (section == 3) {
        
        return 1;
    }
    
    else if (section == 4) {
        
        return 2;
    }
    
    else if (section == 5) {
        
        return 1;
    }
    
    else {
        return 1;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedRoutine = ((DataNavController *)self.parentViewController).routine;
    NSString *week = ((DataNavController *)self.parentViewController).week;
    NSArray *workoutArray;
    
    workoutArray = @[@"Core I",
                     @"Core D",
                     @"Cardio Speed",
                     @"Pilates",
                     @"Dexterity",
                     @"Core D",
                     @"Yoga",
                     @"Core D"];
    
    // Normal routine
    if ([selectedRoutine isEqualToString:@"2-A-Days"]) {
        
        // Week 5
        if ([week isEqualToString:@"Week 8"]) {
            
            if (indexPath.section == 0) {
                
                if (indexPath.row == 0) {
                    
                    // Core I 5
                    ((DataNavController *)self.parentViewController).index = @5;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[0];
                }
            }
            
            if (indexPath.section == 1) {
                
                if (indexPath.row == 0) {
                    
                    // Core D 21
                    ((DataNavController *)self.parentViewController).index = @21;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[1];
                }
            }
            
            if (indexPath.section == 2) {
                
                if (indexPath.row == 0) {
                    
                    // Cardio Speed 5
                    ((DataNavController *)self.parentViewController).index = @5;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[2];
                }
            }
            
            if (indexPath.section == 3) {
                
                if (indexPath.row == 0) {
                    
                    // Pilates 2
                    ((DataNavController *)self.parentViewController).index = @2;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[3];
                }
            }
            
            if (indexPath.section == 4) {
                
                if (indexPath.row == 0) {
                    
                    // Dexterity 5
                    ((DataNavController *)self.parentViewController).index = @5;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[4];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Core D 22
                    ((DataNavController *)self.parentViewController).index = @22;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[5];
                }
            }
            
            if (indexPath.section == 5) {
                
                if (indexPath.row == 0) {
                    
                    // Yoga 8
                    ((DataNavController *)self.parentViewController).index = @8;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[6];
                }
            }
            
            if (indexPath.section == 6) {
                
                if (indexPath.row == 0) {
                    
                    // Core D 23
                    ((DataNavController *)self.parentViewController).index = @23;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[7];
                }
            }
        }
    }
    
    //NSLog(@"%@ index = %@", ((DataNavController *)self.parentViewController).workout, ((DataNavController *)self.parentViewController).index);
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
