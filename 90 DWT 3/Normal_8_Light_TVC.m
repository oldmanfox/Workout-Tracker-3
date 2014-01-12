//
//  Normal_8_Light_TVC.m
//  90 DWT 3
//
//  Created by Jared Grant on 1/4/14.
//  Copyright (c) 2014 Grant, Jared. All rights reserved.
//

#import "Normal_8_Light_TVC.h"

@interface Normal_8_Light_TVC ()

@end

@implementation Normal_8_Light_TVC

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
    
    [self configureTableView:tableCell :accessoryIcon :cellColor];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
                            @"Core D",
                            @"Cardio Speed",
                            @"Pilates",
                            @"Cardio Resistance",
                            @"Yoga",
                            @"Core D"];
    
    ((DataNavController *)self.parentViewController).workout = workoutArray[indexPath.row];
    
    // Normal routine
    if ([selectedRoutine isEqualToString:@"Normal"]) {
        
        // Week 8
        if ([week isEqualToString:@"Week 8"]) {
            
            if (indexPath.row == 0) {
                
                // Core I 2
                ((DataNavController *)self.parentViewController).index = @2;
            }
            
            else if (indexPath.row == 1) {
                
                // Core D 9
                ((DataNavController *)self.parentViewController).index = @9;
            }
            
            else if (indexPath.row == 2) {
                
                // Cardio Speed 2
                ((DataNavController *)self.parentViewController).index = @2;
            }
            
            else if (indexPath.row == 3) {
                
                // Pilates 2
                ((DataNavController *)self.parentViewController).index = @2;
            }
            
            else if (indexPath.row == 4) {
                
                // Cardio Resistance 5
                ((DataNavController *)self.parentViewController).index = @5;
            }
            
            else if (indexPath.row == 5) {
                
                // Yoga 8
                ((DataNavController *)self.parentViewController).index = @8;
            }
            
            else if (indexPath.row == 6) {
                
                // Core D 10
                ((DataNavController *)self.parentViewController).index = @10;
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
