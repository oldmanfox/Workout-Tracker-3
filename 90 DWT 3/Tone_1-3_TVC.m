//
//  Tone_1-3_TVC.m
//  90 DWT 3
//
//  Created by Jared Grant on 1/5/14.
//  Copyright (c) 2014 Grant, Jared. All rights reserved.
//

#import "Tone_1-3_TVC.h"
#import "DWT3IAPHelper.h"

@interface Tone_1_3_TVC ()

@end

@implementation Tone_1_3_TVC

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
    NSString *selectedRoutine = ((DataNavController *)self.parentViewController).routine;
    NSString *week = ((DataNavController *)self.parentViewController).week;
    NSArray *workoutArray;
    
    workoutArray = @[@"Cardio Speed",
                     @"Gladiator",
                     @"Yoga",
                     @"Cardio Resistance",
                     @"Core I",
                     @"Dexterity",
                     @"Core D"];
    
    ((DataNavController *)self.parentViewController).workout = workoutArray[indexPath.row];
    
    // Normal routine
    if ([selectedRoutine isEqualToString:@"Tone"]) {
        
        // Week 1
        if ([week isEqualToString:@"Week 1"]) {
            
            if (indexPath.row == 0) {
                
                // Cardio Speed 1
                ((DataNavController *)self.parentViewController).index = @1;
            }
            
            else if (indexPath.row == 1) {
                
                // Gladiator 1
                ((DataNavController *)self.parentViewController).index = @1;
            }
            
            else if (indexPath.row == 2) {
                
                // Yoga 1
                ((DataNavController *)self.parentViewController).index = @1;
            }
            
            else if (indexPath.row == 3) {
                
                // Cardio Resistance 1
                ((DataNavController *)self.parentViewController).index = @1;
            }
            
            else if (indexPath.row == 4) {
                
                // Core I 1
                ((DataNavController *)self.parentViewController).index = @1;
            }
            
            else if (indexPath.row == 5) {
                
                // Dexterity 1
                ((DataNavController *)self.parentViewController).index = @1;
            }
            
            else if (indexPath.row == 6) {
                
                // Core D 1
                ((DataNavController *)self.parentViewController).index = @1;
            }
        }
        
        // Week 2
        else if ([week isEqualToString:@"Week 2"]) {
            
            if (indexPath.row == 0) {
                
                // Cardio Speed 2
                ((DataNavController *)self.parentViewController).index = @2;
            }
            
            else if (indexPath.row == 1) {
                
                // Gladiator 2
                ((DataNavController *)self.parentViewController).index = @2;
            }
            
            else if (indexPath.row == 2) {
                
                // Yoga 2
                ((DataNavController *)self.parentViewController).index = @2;
            }
            
            else if (indexPath.row == 3) {
                
                // Cardio Resistance 2
                ((DataNavController *)self.parentViewController).index = @2;
            }
            
            else if (indexPath.row == 4) {
                
                // Core I 2
                ((DataNavController *)self.parentViewController).index = @2;
            }
            
            else if (indexPath.row == 5) {
                
                // Dexterity 2
                ((DataNavController *)self.parentViewController).index = @2;
            }
            
            else if (indexPath.row == 6) {
                
                // Core D 2
                ((DataNavController *)self.parentViewController).index = @2;
            }
        }
        
        // Week 3
        else if ([week isEqualToString:@"Week 3"]) {
            
            if (indexPath.row == 0) {
                
                // Cardio Speed 3
                ((DataNavController *)self.parentViewController).index = @3;
            }
            
            else if (indexPath.row == 1) {
                
                // Gladiator 3
                ((DataNavController *)self.parentViewController).index = @3;
            }
            
            else if (indexPath.row == 2) {
                
                // Yoga 3
                ((DataNavController *)self.parentViewController).index = @3;
            }
            
            else if (indexPath.row == 3) {
                
                // Cardio Resistance 3
                ((DataNavController *)self.parentViewController).index = @3;
            }
            
            else if (indexPath.row == 4) {
                
                // Core I 3
                ((DataNavController *)self.parentViewController).index = @3;
            }
            
            else if (indexPath.row == 5) {
                
                // Dexterity 3
                ((DataNavController *)self.parentViewController).index = @3;
            }
            
            else if (indexPath.row == 6) {
                
                // Core D 3
                ((DataNavController *)self.parentViewController).index = @3;
            }
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
