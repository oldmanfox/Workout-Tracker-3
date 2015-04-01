//
//  2-A-Days_1-3_TVC.m
//  90 DWT 3
//
//  Created by Jared Grant on 1/12/14.
//  Copyright (c) 2014 Grant, Jared. All rights reserved.
//

#import "2-A-Days_1-3_TVC.h"

@interface __A_Days_1_3_TVC ()

@end

@implementation __A_Days_1_3_TVC

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
                           self.cell8,
                           self.cell9];
    
    NSArray *accessoryIcon = @[@YES,
                               @YES,
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
        
        return 2;
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
    
    workoutArray = @[@"Complete Fitness",
                     @"Dexterity",
                     @"Core D",
                     @"Yoga",
                     @"The Goal",
                     @"Cardio Resistance",
                     @"Core D",
                     @"Gladiator",
                     @"Core D"];
    
    // Normal routine
    if ([selectedRoutine isEqualToString:@"2-A-Days"]) {
        
        // Week 1
        if ([week isEqualToString:@"Week 1"]) {
            
            if (indexPath.section == 0) {
                
                if (indexPath.row == 0) {
                    
                    // Complete Fitness 1
                    ((DataNavController *)self.parentViewController).index = @1;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[0];
                }
            }
            
            if (indexPath.section == 1) {
                
                if (indexPath.row == 0) {
                    
                    // Dexterity 1
                    ((DataNavController *)self.parentViewController).index = @1;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[1];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Core D 1
                    ((DataNavController *)self.parentViewController).index = @1;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[2];
                }
            }

            if (indexPath.section == 2) {
                
                if (indexPath.row == 0) {
                    
                    // Yoga 1
                    ((DataNavController *)self.parentViewController).index = @1;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[3];
                }
            }

            if (indexPath.section == 3) {
                
                if (indexPath.row == 0) {
                    
                    // The Goal 1
                    ((DataNavController *)self.parentViewController).index = @1;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[4];
                }
            }

            if (indexPath.section == 4) {
                
                if (indexPath.row == 0) {
                    
                    // Cardio Resistance 1
                    ((DataNavController *)self.parentViewController).index = @1;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[5];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Core D 2
                    ((DataNavController *)self.parentViewController).index = @2;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[6];
                }
            }

            if (indexPath.section == 5) {
                
                if (indexPath.row == 0) {
                    
                    // Gladiator 1
                    ((DataNavController *)self.parentViewController).index = @1;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[7];
                }
            }

            if (indexPath.section == 6) {
                
                if (indexPath.row == 0) {
                    
                    // Core D 3
                    ((DataNavController *)self.parentViewController).index = @3;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[8];
                }
            }
        }
        
        // Week 2
        else if ([week isEqualToString:@"Week 2"]) {
            
            if (indexPath.section == 0) {
                
                if (indexPath.row == 0) {
                    
                    // Complete Fitness 2
                    ((DataNavController *)self.parentViewController).index = @2;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[0];
                }
            }
            
            if (indexPath.section == 1) {
                
                if (indexPath.row == 0) {
                    
                    // Dexterity 2
                    ((DataNavController *)self.parentViewController).index = @2;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[1];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Core D 4
                    ((DataNavController *)self.parentViewController).index = @4;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[2];
                }
            }
            
            if (indexPath.section == 2) {
                
                if (indexPath.row == 0) {
                    
                    // Yoga 2
                    ((DataNavController *)self.parentViewController).index = @2;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[3];
                }
            }
            
            if (indexPath.section == 3) {
                
                if (indexPath.row == 0) {
                    
                    // The Goal 2
                    ((DataNavController *)self.parentViewController).index = @2;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[4];
                }
            }
            
            if (indexPath.section == 4) {
                
                if (indexPath.row == 0) {
                    
                    // Cardio Resistance 2
                    ((DataNavController *)self.parentViewController).index = @2;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[5];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Core D 5
                    ((DataNavController *)self.parentViewController).index = @5;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[6];
                }
            }
            
            if (indexPath.section == 5) {
                
                if (indexPath.row == 0) {
                    
                    // Gladiator 2
                    ((DataNavController *)self.parentViewController).index = @2;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[7];
                }
            }
            
            if (indexPath.section == 6) {
                
                if (indexPath.row == 0) {
                    
                    // Core D 6
                    ((DataNavController *)self.parentViewController).index = @6;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[8];
                }
            }
        }
        
        // Week 3
        else if ([week isEqualToString:@"Week 3"]) {
            
            if (indexPath.section == 0) {
                
                if (indexPath.row == 0) {
                    
                    // Complete Fitness 3
                    ((DataNavController *)self.parentViewController).index = @3;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[0];
                }
            }
            
            if (indexPath.section == 1) {
                
                if (indexPath.row == 0) {
                    
                    // Dexterity 3
                    ((DataNavController *)self.parentViewController).index = @3;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[1];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Core D 7
                    ((DataNavController *)self.parentViewController).index = @7;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[2];
                }
            }
            
            if (indexPath.section == 2) {
                
                if (indexPath.row == 0) {
                    
                    // Yoga 3
                    ((DataNavController *)self.parentViewController).index = @3;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[3];
                }
            }
            
            if (indexPath.section == 3) {
                
                if (indexPath.row == 0) {
                    
                    // The Goal 3
                    ((DataNavController *)self.parentViewController).index = @3;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[4];
                }
            }
            
            if (indexPath.section == 4) {
                
                if (indexPath.row == 0) {
                    
                    // Cardio Resistance 3
                    ((DataNavController *)self.parentViewController).index = @3;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[5];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Core D 8
                    ((DataNavController *)self.parentViewController).index = @8;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[6];
                }
            }
            
            if (indexPath.section == 5) {
                
                if (indexPath.row == 0) {
                    
                    // Gladiator 3
                    ((DataNavController *)self.parentViewController).index = @3;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[7];
                }
            }
            
            if (indexPath.section == 6) {
                
                if (indexPath.row == 0) {
                    
                    // Core D 9
                    ((DataNavController *)self.parentViewController).index = @9;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[8];
                }
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
