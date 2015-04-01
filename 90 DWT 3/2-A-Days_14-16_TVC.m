//
//  2-A-Days_14-16_TVC.m
//  90 DWT 3
//
//  Created by Jared Grant on 1/12/14.
//  Copyright (c) 2014 Grant, Jared. All rights reserved.
//

#import "2-A-Days_14-16_TVC.h"

@interface __A_Days_14_16_TVC ()

@end

@implementation __A_Days_14_16_TVC

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
                           self.cell9,
                           self.cell10,
                           self.cell11,
                           self.cell12,
                           self.cell13,
                           self.cell14,
                           self.cell15];
    
    NSArray *accessoryIcon = @[@YES,
                               @YES,
                               @YES,
                               @YES,
                               @YES,
                               @YES,
                               @YES,
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
        
        return 3;
    }
    
    else if (section == 1) {
        
        return 2;
    }
    
    else if (section == 2) {
        
        return 2;
    }
    
    else if (section == 3) {
        
        return 3;
    }
    
    else if (section == 4) {
        
        return 2;
    }
    
    else if (section == 5) {
        
        return 2;
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
    
    workoutArray = @[@"Agility Upper",
                     @"Ab Workout",
                     @"Cardio Speed",
                     @"Agility Lower",
                     @"Core I",
                     @"Yoga",
                     @"Pilates",
                     @"Agility Upper",
                     @"Ab Workout",
                     @"Cardio Resistance",
                     @"Agility Lower",
                     @"MMA",
                     @"Yoga",
                     @"Pilates",
                     @"Core D"];
    
    // Normal routine
    if ([selectedRoutine isEqualToString:@"2-A-Days"]) {
        
        // Week 14
        if ([week isEqualToString:@"Week 14"]) {
            
            if (indexPath.section == 0) {
                
                if (indexPath.row == 0) {
                    
                    // Agility Upper 3
                    ((DataNavController *)self.parentViewController).index = @3;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[0];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Ab Workout 5
                    ((DataNavController *)self.parentViewController).index = @5;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[1];
                }
                
                else if (indexPath.row == 2) {
                    
                    // Cardio Speed 11
                    ((DataNavController *)self.parentViewController).index = @11;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[2];
                }
            }
            
            if (indexPath.section == 1) {
                
                if (indexPath.row == 0) {
                    
                    // Agility Lower 3
                    ((DataNavController *)self.parentViewController).index = @3;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[3];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Core I 11
                    ((DataNavController *)self.parentViewController).index = @11;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[4];
                }
            }
            
            if (indexPath.section == 2) {
                
                if (indexPath.row == 0) {
                    
                    // Yoga 14
                    ((DataNavController *)self.parentViewController).index = @14;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[5];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Pilates 8
                    ((DataNavController *)self.parentViewController).index = @8;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[6];
                }
            }
            
            if (indexPath.section == 3) {
                
                if (indexPath.row == 0) {
                    
                    // Agility Upper 4
                    ((DataNavController *)self.parentViewController).index = @4;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[7];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Ab Workout 6
                    ((DataNavController *)self.parentViewController).index = @6;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[8];
                }
                
                else if (indexPath.row == 2) {
                    
                    // Cardio Resistance 11
                    ((DataNavController *)self.parentViewController).index = @11;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[9];
                }
            }
            
            if (indexPath.section == 4) {
                
                if (indexPath.row == 0) {
                    
                    // Agility Lower 4
                    ((DataNavController *)self.parentViewController).index = @4;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[10];
                }
                
                else if (indexPath.row == 1) {
                    
                    // MMA 8
                    ((DataNavController *)self.parentViewController).index = @8;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[11];
                }
            }
            
            if (indexPath.section == 5) {
                
                if (indexPath.row == 0) {
                    
                    // Yoga 15
                    ((DataNavController *)self.parentViewController).index = @15;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[12];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Pilates 9
                    ((DataNavController *)self.parentViewController).index = @9;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[13];
                }
            }
            
            if (indexPath.section == 6) {
                
                if (indexPath.row == 0) {
                    
                    // Core D 36
                    ((DataNavController *)self.parentViewController).index = @36;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[14];
                }
            }
        }
        
        // Week 15
        else if ([week isEqualToString:@"Week 15"]) {
            
            if (indexPath.section == 0) {
                
                if (indexPath.row == 0) {
                    
                    // Agility Upper 5
                    ((DataNavController *)self.parentViewController).index = @5;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[0];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Ab Workout 7
                    ((DataNavController *)self.parentViewController).index = @7;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[1];
                }
                
                else if (indexPath.row == 2) {
                    
                    // Cardio Speed 12
                    ((DataNavController *)self.parentViewController).index = @12;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[2];
                }
            }
            
            if (indexPath.section == 1) {
                
                if (indexPath.row == 0) {
                    
                    // Agility Lower 5
                    ((DataNavController *)self.parentViewController).index = @5;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[3];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Core I 12
                    ((DataNavController *)self.parentViewController).index = @12;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[4];
                }
            }
            
            if (indexPath.section == 2) {
                
                if (indexPath.row == 0) {
                    
                    // Yoga 16
                    ((DataNavController *)self.parentViewController).index = @16;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[5];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Pilates 10
                    ((DataNavController *)self.parentViewController).index = @10;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[6];
                }
            }
            
            if (indexPath.section == 3) {
                
                if (indexPath.row == 0) {
                    
                    // Agility Upper 6
                    ((DataNavController *)self.parentViewController).index = @6;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[7];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Ab Workout 8
                    ((DataNavController *)self.parentViewController).index = @8;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[8];
                }
                
                else if (indexPath.row == 2) {
                    
                    // Cardio Resistance 12
                    ((DataNavController *)self.parentViewController).index = @12;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[9];
                }
            }
            
            if (indexPath.section == 4) {
                
                if (indexPath.row == 0) {
                    
                    // Agility Lower 6
                    ((DataNavController *)self.parentViewController).index = @6;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[10];
                }
                
                else if (indexPath.row == 1) {
                    
                    // MMA 9
                    ((DataNavController *)self.parentViewController).index = @9;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[11];
                }
            }
            
            if (indexPath.section == 5) {
                
                if (indexPath.row == 0) {
                    
                    // Yoga 17
                    ((DataNavController *)self.parentViewController).index = @17;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[12];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Pilates 11
                    ((DataNavController *)self.parentViewController).index = @11;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[13];
                }
            }
            
            if (indexPath.section == 6) {
                
                if (indexPath.row == 0) {
                    
                    // Core D 37
                    ((DataNavController *)self.parentViewController).index = @37;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[14];
                }
            }
        }
        
        // Week 16
        else if ([week isEqualToString:@"Week 16"]) {
            
            if (indexPath.section == 0) {
                
                if (indexPath.row == 0) {
                    
                    // Agility Upper 7
                    ((DataNavController *)self.parentViewController).index = @7;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[0];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Ab Workout 9
                    ((DataNavController *)self.parentViewController).index = @9;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[1];
                }
                
                else if (indexPath.row == 2) {
                    
                    // Cardio Speed 13
                    ((DataNavController *)self.parentViewController).index = @13;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[2];
                }
            }
            
            if (indexPath.section == 1) {
                
                if (indexPath.row == 0) {
                    
                    // Agility Lower 7
                    ((DataNavController *)self.parentViewController).index = @7;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[3];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Core I 13
                    ((DataNavController *)self.parentViewController).index = @13;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[4];
                }
            }
            
            if (indexPath.section == 2) {
                
                if (indexPath.row == 0) {
                    
                    // Yoga 18
                    ((DataNavController *)self.parentViewController).index = @18;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[5];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Pilates 12
                    ((DataNavController *)self.parentViewController).index = @12;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[6];
                }
            }
            
            if (indexPath.section == 3) {
                
                if (indexPath.row == 0) {
                    
                    // Agility Upper 8
                    ((DataNavController *)self.parentViewController).index = @8;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[7];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Ab Workout 10
                    ((DataNavController *)self.parentViewController).index = @10;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[8];
                }
                
                else if (indexPath.row == 2) {
                    
                    // Cardio Resistance 13
                    ((DataNavController *)self.parentViewController).index = @13;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[9];
                }
            }
            
            if (indexPath.section == 4) {
                
                if (indexPath.row == 0) {
                    
                    // Agility Lower 8
                    ((DataNavController *)self.parentViewController).index = @8;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[10];
                }
                
                else if (indexPath.row == 1) {
                    
                    // MMA 10
                    ((DataNavController *)self.parentViewController).index = @10;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[11];
                }
            }
            
            if (indexPath.section == 5) {
                
                if (indexPath.row == 0) {
                    
                    // Yoga 19
                    ((DataNavController *)self.parentViewController).index = @19;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[12];
                }
                
                else if (indexPath.row == 1) {
                    
                    // Pilates 13
                    ((DataNavController *)self.parentViewController).index = @13;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[13];
                }
            }
            
            if (indexPath.section == 6) {
                
                if (indexPath.row == 0) {
                    
                    // Core D 38
                    ((DataNavController *)self.parentViewController).index = @38;
                    ((DataNavController *)self.parentViewController).workout = workoutArray[14];
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
