//
//  SettingsTVC.h
//  90 DWT 1
//
//  Created by Jared Grant on 7/11/12.
//  Copyright (c) 2012 g-rantsoftware.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsNavController.h"
#import "DataNavController.h"
#import "MainTBC.h"
#import "EmailViewController.h"
#import "UITableViewController+Design.h"

@interface SettingsTVC : UITableViewController
@property (weak, nonatomic) IBOutlet UITableViewCell *cell1; // Email.  Default is youremail@abc.com.
@property (weak, nonatomic) IBOutlet UITableViewCell *cell2; // Version
@property (weak, nonatomic) IBOutlet UITableViewCell *cell3; // Author
@property (weak, nonatomic) IBOutlet UITableViewCell *cell4; // Website
@property (weak, nonatomic) IBOutlet UITableViewCell *cell5; // Bands
@property (weak, nonatomic) IBOutlet UITableViewCell *cell6; // Workout level
@property (weak, nonatomic) IBOutlet UILabel *emailDetail;
@property (weak, nonatomic) IBOutlet UISegmentedControl *defaultWorkout; // Normal, Tone, Bulk, or 2-A-Days.  Default is Normal.
- (IBAction)selectDefaultWorkout:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *bandsSwitch; // Using bands instead of free weights?

- (IBAction)toggleBands:(id)sender;

@end
