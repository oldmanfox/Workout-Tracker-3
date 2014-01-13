//
//  2-A-Days_13_Light_TVC.m
//  90 DWT 3
//
//  Created by Jared Grant on 1/12/14.
//  Copyright (c) 2014 Grant, Jared. All rights reserved.
//

#import "2-A-Days_13_Light_TVC.h"

@interface __A_Days_13_Light_TVC ()

@end

@implementation __A_Days_13_Light_TVC

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
    
    NSArray *workoutArray = @[@"Core I",
                              @"Cardio Speed",
                              @"Pilates",
                              @"Yoga",
                              @"Core D",
                              @"Core D",
                              @"Finished"];
    
    ((DataNavController *)self.parentViewController).workout = workoutArray[indexPath.row];
    
    // Normal routine
    if ([selectedRoutine isEqualToString:@"2-A-Days"]) {
        
        // Week 13
        if ([week isEqualToString:@"Week 13"]) {
            
            if (indexPath.row == 0) {
                
                // Core I 10
                ((DataNavController *)self.parentViewController).index = @10;
            }
            
            else if (indexPath.row == 1) {
                
                // Cardio Speed 10
                ((DataNavController *)self.parentViewController).index = @10;
            }
            
            else if (indexPath.row == 2) {
                
                // Pilates 7
                ((DataNavController *)self.parentViewController).index = @7;
            }
            
            else if (indexPath.row == 3) {
                
                // Yoga 13
                ((DataNavController *)self.parentViewController).index = @13;
            }
            
            else if (indexPath.row == 4) {
                
                // Core D 34
                ((DataNavController *)self.parentViewController).index = @34;
            }
            
            else if (indexPath.row == 5) {
                
                // Core D 35
                ((DataNavController *)self.parentViewController).index = @35;
            }
            
            else if (indexPath.row == 6) {
                
                // Finished 3rd Month
                ((DataNavController *)self.parentViewController).index = @1;
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
