//
//  Bulk_5-7_TVC.m
//  90 DWT 3
//
//  Created by Jared Grant on 1/5/14.
//  Copyright (c) 2014 Grant, Jared. All rights reserved.
//

#import "Bulk_5-7_TVC.h"

@interface Bulk_5_7_TVC ()

@end

@implementation Bulk_5_7_TVC

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
    // Navigation logic may go here. Create and push another view controller.
    /*
     *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    NSString *week = ((DataNavController *)self.parentViewController).week;
    NSArray *workoutArray;
    
    workoutArray = @[@"Negative Upper",
                     @"Negative Lower",
                     @"Yoga",
                     @"Negative Upper",
                     @"Negative Lower",
                     @"MMA",
                     @"Core D"];
    
    ((DataNavController *)self.parentViewController).workout = workoutArray[indexPath.row];
    
    // Week 5
    if ([week isEqualToString:@"Week 5"]) {
        
        if (indexPath.row == 0) {
            
            // Negative Upper 1
            ((DataNavController *)self.parentViewController).index = @1;
        }
        
        else if (indexPath.row == 1) {
            
            // Negative Lower 1
            ((DataNavController *)self.parentViewController).index = @1;
        }
        
        else if (indexPath.row == 2) {
            
            // Yoga 5
            ((DataNavController *)self.parentViewController).index = @5;
        }
        
        else if (indexPath.row == 3) {
            
            // Negative Upper 2
            ((DataNavController *)self.parentViewController).index = @2;
        }
        
        else if (indexPath.row == 4) {
            
            // Negative Lower 2
            ((DataNavController *)self.parentViewController).index = @2;
        }
        
        else if (indexPath.row == 5) {
            
            // MMA 1
            ((DataNavController *)self.parentViewController).index = @1;
        }
        
        else if (indexPath.row == 6) {
            
            // Core D 6
            ((DataNavController *)self.parentViewController).index = @6;
        }
    }
    
    // Week 6
    else if ([week isEqualToString:@"Week 6"]) {
        
        if (indexPath.row == 0) {
            
            // Negative Upper 3
            ((DataNavController *)self.parentViewController).index = @3;
        }
        
        else if (indexPath.row == 1) {
            
            // Negative Lower 3
            ((DataNavController *)self.parentViewController).index = @3;
        }
        
        else if (indexPath.row == 2) {
            
            // Yoga 6
            ((DataNavController *)self.parentViewController).index = @6;
        }
        
        else if (indexPath.row == 3) {
            
            // Negative Upper 4
            ((DataNavController *)self.parentViewController).index = @4;
        }
        
        else if (indexPath.row == 4) {
            
            // Negative Lower 4
            ((DataNavController *)self.parentViewController).index = @4;
        }
        
        else if (indexPath.row == 5) {
            
            // MMA 2
            ((DataNavController *)self.parentViewController).index = @2;
        }
        
        else if (indexPath.row == 6) {
            
            // Core D 7
            ((DataNavController *)self.parentViewController).index = @7;
        }
    }
    
    // Week 7
    else if ([week isEqualToString:@"Week 7"]) {
        
        if (indexPath.row == 0) {
            
            // Negative Upper 5
            ((DataNavController *)self.parentViewController).index = @5;
        }
        
        else if (indexPath.row == 1) {
            
            // Negative Lower 5
            ((DataNavController *)self.parentViewController).index = @5;
        }
        
        else if (indexPath.row == 2) {
            
            // Yoga 7
            ((DataNavController *)self.parentViewController).index = @7;
        }
        
        else if (indexPath.row == 3) {
            
            // Negative Upper 6
            ((DataNavController *)self.parentViewController).index = @6;
        }
        
        else if (indexPath.row == 4) {
            
            // Negative Lower 6
            ((DataNavController *)self.parentViewController).index = @6;
        }
        
        else if (indexPath.row == 5) {
            
            // MMA 3
            ((DataNavController *)self.parentViewController).index = @3;
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
