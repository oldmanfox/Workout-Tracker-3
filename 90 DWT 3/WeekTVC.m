//
//  WeekTVC.m
//  90 DWT 1
//
//  Created by Jared Grant on 7/11/12.
//  Copyright (c) 2012 g-rantsoftware.com. All rights reserved.
//

#import "WeekTVC.h"
#import "DWT3IAPHelper.h"

@interface WeekTVC ()

@end

@implementation WeekTVC

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
    
    [self findDefaultWorkout];
    
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
                            self.cell15,
                            self.cell16,
                            self.cell17];
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
                           @NO,
                           @NO,
                           @NO];

    [self configureTableView:tableCell :accessoryIcon :cellColor];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self findDefaultWorkout];
    
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //NSLog(@"Routine = %@", ((DataNavController *)self.parentViewController).routine);
    
    // Return the number of sections.
    if ([self.navigationItem.title isEqualToString:@"Bulk"]) {
        return 3;
    }
    
    else {
        return 4;
    }
}

- (void)findDefaultWorkout
{
    // Get path to documents directory
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *defaultWorkoutFile = nil;
    defaultWorkoutFile = [docDir stringByAppendingPathComponent:@"Default Workout.out"];
    
    if  ([[NSFileManager defaultManager] fileExistsAtPath:defaultWorkoutFile]) {
        
        // File has already been created. Get value of routine from it.
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:defaultWorkoutFile];
        self.navigationItem.title = [[NSString alloc] initWithData:[fileHandle availableData] encoding:NSUTF8StringEncoding];
        [fileHandle closeFile];
        
        ((DataNavController *)self.parentViewController).routine = self.navigationItem.title;
    }
    
    else {
        
        // File has not been created so this is the first time the app has been opened or user has not changed workout.
        ((DataNavController *)self.parentViewController).routine = @"Normal";
        self.navigationItem.title = ((DataNavController *)self.parentViewController).routine;
    }
    
    //NSLog(@"Routine = %@", ((DataNavController *)self.parentViewController).routine);
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedWeek = @"Week";
    NSString *workoutSegueName = self.navigationItem.title;
    
    // Month 1
    if (indexPath.section == 0) {
        
        ((DataNavController *)self.parentViewController).month = @"Month 1";
        
        // Segue to normal workout list if week 1-3 is selected.
        // Segue to recovery workout list if week 4 is selected.
        if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2) {
            
            workoutSegueName = [workoutSegueName stringByAppendingString:@" 1-3"];
        }
        
        else {
            
            workoutSegueName = [workoutSegueName stringByAppendingString:@"_4_Light"];
        }
        
        // Get current week
        for (int i = 0; i < 4; i++) {
                       
            if (indexPath.row == i) {
                
                selectedWeek = [selectedWeek stringByAppendingFormat:@" %d", i + 1];
            }
        }
    }
    
    // Month 2
    else if (indexPath.section == 1) {
        
        ((DataNavController *)self.parentViewController).month = @"Month 2";
        
        // Segue to normal workout list if week 5-7 is selected.
        // Segue to recovery workout list if week 8 is selected.
        if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2) {
            
            workoutSegueName = [workoutSegueName stringByAppendingString:@" 5-7"];
        }
        
        else {
            
            workoutSegueName = [workoutSegueName stringByAppendingString:@"_8_Light"];
        }

        // Get current week
        for (int i = 0; i < 4; i++) {
            
            if (indexPath.row == i) {
                
                selectedWeek = [selectedWeek stringByAppendingFormat:@" %d", i + 5];
            }
        }
    }
    
    // Month 3
    else if (indexPath.section == 2) {
        
        ((DataNavController *)self.parentViewController).month = @"Month 3";
        
        // Segue to workout 1 list if week 9 or 11 is selected.
        // Segue to workout 2 list if week 10 or 12 is selected.
        // Segue to recovery workout list if week 13 is selected.
        if (indexPath.row == 0 || indexPath.row == 2) {
            
            workoutSegueName = [workoutSegueName stringByAppendingString:@" 9+11"];
        }
        
        else if (indexPath.row == 1 || indexPath.row == 3) {
            
            workoutSegueName = [workoutSegueName stringByAppendingString:@" 10+12"];
        }
        
        else {
            
            workoutSegueName = [workoutSegueName stringByAppendingString:@"_13_Light"];
        }

        // Get current week
        for (int i = 0; i < 5; i++) {
            
            if (indexPath.row == i) {
                
                selectedWeek = [selectedWeek stringByAppendingFormat:@" %d", i + 9];
            }
        }
    }
    
    // Month 4
    else {
        
        ((DataNavController *)self.parentViewController).month = @"Month 4";
        
        // Segue to normal workout list if week 14-6 is selected.
        // Segue to recovery workout list if week 17 is selected.
        if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2) {
            
            workoutSegueName = [workoutSegueName stringByAppendingString:@" 14-16"];
        }
        
        else {
            
            workoutSegueName = [workoutSegueName stringByAppendingString:@"_17_Light"];
        }
        
        // Get current week
        for (int i = 0; i < 4; i++) {
            
            if (indexPath.row == i) {
                
                selectedWeek = [selectedWeek stringByAppendingFormat:@" %d", i + 14];
            }
        }
    }

    
    ((DataNavController *)self.parentViewController).week = selectedWeek;
    
    [self performSegueWithIdentifier:workoutSegueName sender:self];    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Show or Hide Ads
    if ([[DWT3IAPHelper sharedInstance] productPurchased:@"com.grantsoftware.90DWT3.removeads1"]) {
        
        // User purchased the Remove Ads in-app purchase so don't show any ads.
        
    } else {
        
        // Show the Interstitial Ad
        UIViewController *c = segue.destinationViewController;
        
        c.interstitialPresentationPolicy = ADInterstitialPresentationPolicyAutomatic;
    }
}
@end
