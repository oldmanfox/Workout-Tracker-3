//
//  SettingsTVC.m
//  90 DWT 1
//
//  Created by Jared Grant on 7/11/12.
//  Copyright (c) 2012 g-rantsoftware.com. All rights reserved.
//

#import "SettingsTVC.h"

@interface SettingsTVC ()

@end

@implementation SettingsTVC

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
    NSArray *tableCell = @[self.cell1,  // email
                           self.cell2,  // version
                           self.cell3,  // author
                           self.cell4,  // website
                           self.cell5,  // bands
                           self.cell6]; // workout level
    
    NSArray *accessoryIcon = @[@YES,
                               @NO,
                               @NO,
                               @YES,
                               @NO,
                               @NO];
    
    NSArray *cellColor = @[@NO,
                           @NO,
                           @NO,
                           @NO,
                           @NO,
                           @NO];
    
    [self configureTableView:tableCell :accessoryIcon: cellColor];

    // Get path to documents directory
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    // Email File
    NSString *defaultEmailFile = nil;
    defaultEmailFile = [docDir stringByAppendingPathComponent:@"Default Email.out"];
    
    if  ([[NSFileManager defaultManager] fileExistsAtPath:defaultEmailFile]) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:defaultEmailFile];
        ((SettingsNavController *)self.parentViewController).emailAddress = [[NSString alloc] initWithData:[fileHandle availableData] encoding:NSUTF8StringEncoding];
        [fileHandle closeFile];
    }
    else {
        ((SettingsNavController *)self.parentViewController).emailAddress = @"";
    }
    
    // Workout File
    NSString *defaultWorkoutFile = nil;
    defaultWorkoutFile = [docDir stringByAppendingPathComponent:@"Default Workout.out"];
    
    if  ([[NSFileManager defaultManager] fileExistsAtPath:defaultWorkoutFile]) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:defaultWorkoutFile];
        NSString *workoutTitle = [[NSString alloc] initWithData:[fileHandle availableData] encoding:NSUTF8StringEncoding];
        [fileHandle closeFile];
        
        for (int i = 0; i < 4; i++) {
            if ([[self.defaultWorkout titleForSegmentAtIndex:i] isEqualToString:workoutTitle]) {
                self.defaultWorkout.selectedSegmentIndex = i;
            }
        }
    }
    
    // BandSetting
    if ([((MainTBC *)self.parentViewController.parentViewController).bandSetting isEqualToString:@"ON"]) {
        [self.bandsSwitch setOn:YES animated:NO];
    }
    else {
        [self.bandsSwitch setOn:NO animated:NO];
    }
}
  
- (void)viewDidAppear:(BOOL)animated {
    if ([((SettingsNavController *)self.parentViewController).emailAddress isEqualToString:@""]) {
        self.emailDetail.text = @"youremail@abc.com";
    }
    else {
        self.emailDetail.text = ((SettingsNavController *)self.parentViewController).emailAddress;
    }
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
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 3;
    }
    else {
        return 3;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...*/
     // Pass the selected object to the new view controller.
     //[self.navigationController pushViewController:emailviewcontroller animated:YES];
     
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"email"]) {
        ((SettingsNavController *)self.parentViewController).emailAddress = self.emailDetail.text;
    }
}

- (IBAction)selectDefaultWorkout:(id)sender {
    // Get path to documents directory
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *defaultWorkoutFile = nil;
    defaultWorkoutFile = [docDir stringByAppendingPathComponent:@"Default Workout.out"];
    
    // Create the file
    [[NSFileManager defaultManager] createFileAtPath:defaultWorkoutFile contents:nil attributes:nil];
    
    // Write file to documents directory
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:defaultWorkoutFile];
    [fileHandle writeData:[[self.defaultWorkout titleForSegmentAtIndex:self.defaultWorkout.selectedSegmentIndex] dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
    
    // Save default workout to SettingsNavController
    ((SettingsNavController *)self.parentViewController).defaultWorkout = [self.defaultWorkout titleForSegmentAtIndex:self.defaultWorkout.selectedSegmentIndex];
    
    ((MainTBC *)self.parentViewController.parentViewController).workoutChanged = YES;
}

- (IBAction)toggleBands:(id)sender {
    // Get path to documents directory
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *defaultBandSetting = nil;
    defaultBandSetting = [docDir stringByAppendingPathComponent:@"Band Setting.out"];
    
    // Create the file
    [[NSFileManager defaultManager] createFileAtPath:defaultBandSetting contents:nil attributes:nil];
    
    NSString *localBandSetting;
    
    if ([sender isOn]) {
        // User wants to use bands so turn on alphanumeric keyboard for weight fields.
        localBandSetting = @"ON";
    }
    
    else {
        // User doesn't want to use bands so turn on numberpad keyboard for weight fields.
        localBandSetting = @"OFF";
    }
    
    // Write file to documents directory
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:defaultBandSetting];
    [fileHandle writeData:[localBandSetting dataUsingEncoding:NSUTF8StringEncoding]];
    ((MainTBC *)self.parentViewController.parentViewController).bandSetting = localBandSetting;
    
    //NSLog(@"BandSetting = %@", ((MainTBC *)self.parentViewController.parentViewController).bandSetting);
}
@end
