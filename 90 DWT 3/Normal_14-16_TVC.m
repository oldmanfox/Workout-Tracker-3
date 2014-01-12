//
//  Normal_14-16_TVC.m
//  90 DWT 3
//
//  Created by Jared Grant on 1/4/14.
//  Copyright (c) 2014 Grant, Jared. All rights reserved.
//

#import "Normal_14-16_TVC.h"

@interface Normal_14_16_TVC ()

@end

@implementation Normal_14_16_TVC

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
    
    NSArray *cellColor = @[@YES,
                           @YES,
                           @NO,
                           @NO,
                           @YES,
                           @YES,
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
    return 9;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedRoutine = ((DataNavController *)self.parentViewController).routine;
    NSString *week = ((DataNavController *)self.parentViewController).week;
    NSArray *workoutArray;
    
    workoutArray = @[@"Agility Upper",
                     @"Ab Workout",
                     @"Agility Lower",
                     @"Yoga",
                     @"Agility Upper",
                     @"Ab Workout",
                     @"Agility Lower",
                     @"Pilates",
                     @"Core D"];
    
    ((DataNavController *)self.parentViewController).workout = workoutArray[indexPath.row];
    
    // Normal routine
    if ([selectedRoutine isEqualToString:@"Normal"]) {
        
        // Week 14
        if ([week isEqualToString:@"Week 14"]) {
            
            if (indexPath.row == 0) {
                
                // Agility Upper D 3
                ((DataNavController *)self.parentViewController).index = @3;
            }
            
            else if (indexPath.row == 1) {
                
                // Ab Workout 1
                ((DataNavController *)self.parentViewController).index = @1;
            }
            
            else if (indexPath.row == 2) {
                
                // Agility Lower 3
                ((DataNavController *)self.parentViewController).index = @3;
            }
            
            else if (indexPath.row == 3) {
                
                // Yoga 12
                ((DataNavController *)self.parentViewController).index = @12;
            }
            
            else if (indexPath.row == 4) {
                
                // Agility Upper 4
                ((DataNavController *)self.parentViewController).index = @4;
            }
            
            else if (indexPath.row == 5) {
                
                // Ab Workout 2
                ((DataNavController *)self.parentViewController).index = @2;
            }
            
            else if (indexPath.row == 6) {
                
                // Agility Lower 4
                ((DataNavController *)self.parentViewController).index = @4;
            }
            
            else if (indexPath.row == 7) {
                
                // Pilates 6
                ((DataNavController *)self.parentViewController).index = @6;
            }
            
            else if (indexPath.row == 8) {
                
                // Core D 17
                ((DataNavController *)self.parentViewController).index = @17;
            }
        }
        
        // Week 15
        else if ([week isEqualToString:@"Week 15"]) {
            
            if (indexPath.row == 0) {
                
                // Agility Upper D 5
                ((DataNavController *)self.parentViewController).index = @5;
            }
            
            else if (indexPath.row == 1) {
                
                // Ab Workout 3
                ((DataNavController *)self.parentViewController).index = @3;
            }
            
            else if (indexPath.row == 2) {
                
                // Agility Lower 5
                ((DataNavController *)self.parentViewController).index = @5;
            }
            
            else if (indexPath.row == 3) {
                
                // Yoga 13
                ((DataNavController *)self.parentViewController).index = @13;
            }
            
            else if (indexPath.row == 4) {
                
                // Agility Upper 6
                ((DataNavController *)self.parentViewController).index = @6;
            }
            
            else if (indexPath.row == 5) {
                
                // Ab Workout 4
                ((DataNavController *)self.parentViewController).index = @4;
            }
            
            else if (indexPath.row == 6) {
                
                // Agility Lower 6
                ((DataNavController *)self.parentViewController).index = @6;
            }
            
            else if (indexPath.row == 7) {
                
                // Pilates 7
                ((DataNavController *)self.parentViewController).index = @7;
            }
            
            else if (indexPath.row == 8) {
                
                // Core D 18
                ((DataNavController *)self.parentViewController).index = @18;
            }
        }
        
        // Week 16
        else if ([week isEqualToString:@"Week 16"]) {
            
            if (indexPath.row == 0) {
                
                // Agility Upper D 7
                ((DataNavController *)self.parentViewController).index = @7;
            }
            
            else if (indexPath.row == 1) {
                
                // Ab Workout 5
                ((DataNavController *)self.parentViewController).index = @5;
            }
            
            else if (indexPath.row == 2) {
                
                // Agility Lower 7
                ((DataNavController *)self.parentViewController).index = @7;
            }
            
            else if (indexPath.row == 3) {
                
                // Yoga 14
                ((DataNavController *)self.parentViewController).index = @14;
            }
            
            else if (indexPath.row == 4) {
                
                // Agility Upper 8
                ((DataNavController *)self.parentViewController).index = @8;
            }
            
            else if (indexPath.row == 5) {
                
                // Ab Workout 6
                ((DataNavController *)self.parentViewController).index = @6;
            }
            
            else if (indexPath.row == 6) {
                
                // Agility Lower 8
                ((DataNavController *)self.parentViewController).index = @8;
            }
            
            else if (indexPath.row == 7) {
                
                // Pilates 8
                ((DataNavController *)self.parentViewController).index = @8;
            }
            
            else if (indexPath.row == 8) {
                
                // Core D 19
                ((DataNavController *)self.parentViewController).index = @19;
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
