//
//  Bulk_10+12_TVC.m
//  90 DWT 3
//
//  Created by Jared Grant on 1/5/14.
//  Copyright (c) 2014 Grant, Jared. All rights reserved.
//

#import "Bulk_10+12_TVC.h"

@interface Bulk_10_12_TVC ()

@end

@implementation Bulk_10_12_TVC

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
    
    workoutArray = @[@"Complete Fitness",
                     @"Dexterity",
                     @"Yoga",
                     @"The Goal",
                     @"Pilates",
                     @"Devastator",
                     @"Core D"];
    
    ((DataNavController *)self.parentViewController).workout = workoutArray[indexPath.row];
    
    // Normal routine
    if ([selectedRoutine isEqualToString:@"Bulk"]) {
        
        // Week 10
        if ([week isEqualToString:@"Week 10"]) {
            
            if (indexPath.row == 0) {
                
                // Complete Fitness 4
                ((DataNavController *)self.parentViewController).index = @4;
            }
            
            else if (indexPath.row == 1) {
                
                // Dexterity 5
                ((DataNavController *)self.parentViewController).index = @5;
            }
            
            else if (indexPath.row == 2) {
                
                // Yoga 10
                ((DataNavController *)self.parentViewController).index = @10;
            }
            
            else if (indexPath.row == 3) {
                
                // The Goal 4
                ((DataNavController *)self.parentViewController).index = @4;
            }
            
            else if (indexPath.row == 4) {
                
                // Pilates 6
                ((DataNavController *)self.parentViewController).index = @6;
            }
            
            else if (indexPath.row == 5) {
                
                // Devastator 4
                ((DataNavController *)self.parentViewController).index = @4;
            }
            
            else if (indexPath.row == 6) {
                
                // Core D 12
                ((DataNavController *)self.parentViewController).index = @12;
            }
        }
        
        // Week 12
        else if ([week isEqualToString:@"Week 12"]) {
            
            if (indexPath.row == 0) {
                
                // Complete Fitness 5
                ((DataNavController *)self.parentViewController).index = @5;
            }
            
            else if (indexPath.row == 1) {
                
                // Dexterity 6
                ((DataNavController *)self.parentViewController).index = @6;
            }
            
            else if (indexPath.row == 2) {
                
                // Yoga 12
                ((DataNavController *)self.parentViewController).index = @12;
            }
            
            else if (indexPath.row == 3) {
                
                // The Goal 5
                ((DataNavController *)self.parentViewController).index = @5;
            }
            
            else if (indexPath.row == 4) {
                
                // Pilates 7
                ((DataNavController *)self.parentViewController).index = @7;
            }
            
            else if (indexPath.row == 5) {
                
                // Devastator 5
                ((DataNavController *)self.parentViewController).index = @5;
            }
            
            else if (indexPath.row == 6) {
                
                // Core D 14
                ((DataNavController *)self.parentViewController).index = @14;
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
