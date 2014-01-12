//
//  PhotoTVC.m
//  90 DWT 1
//
//  Created by Jared Grant on 7/14/12.
//  Copyright (c) 2012 g-rantsoftware.com. All rights reserved.
//

#import "PhotoTVC.h"

@interface PhotoTVC ()

@end

@implementation PhotoTVC

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
                            self.cellFinal,
                            self.cellAll,
                            self.cellFront,
                            self.cellSide,
                            self.cellBack];
    
    NSArray *accessoryIcon = @[@YES,
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
                           @NO];

    [self configureTableView:tableCell :accessoryIcon: cellColor];
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
        return 4;
    }
    else {
        return 4;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Set navigation bar title
    ((PhotoNavController *)self.parentViewController).month = segue.identifier;
    PhotoScrollerViewController *psvc = (PhotoScrollerViewController *)segue.destinationViewController;
    PresentPhotosViewController *ppvc = (PresentPhotosViewController *)segue.destinationViewController;
    psvc.navigationItem.title = segue.identifier;
    ppvc.navigationItem.title = segue.identifier;
    
    
    // View Photos
    PhotoNavController *photoNC = [[PhotoNavController alloc] init];
    NSMutableArray *monthPhotoAngle = [[NSMutableArray alloc] init];
    NSArray *tempMonthPhotoAngle = [[NSArray alloc] init];
    
    // ALL
    if ([segue.identifier isEqualToString:@"All"]) {
        
        tempMonthPhotoAngle = @[@"Start Month 1 Front",
        @"Start Month 1 Side",
        @"Start Month 1 Back",
        @"Start Month 2 Front",
        @"Start Month 2 Side",
        @"Start Month 2 Back",
        @"Start Month 3 Front",
        @"Start Month 3 Side",
        @"Start Month 3 Back",
        @"Final Front",
        @"Final Side",
        @"Final Back"];
    }
    
    // FRONT
    else if ([segue.identifier isEqualToString:@"Front"]) {
        
        tempMonthPhotoAngle = @[@"Start Month 1 Front",
        @"Start Month 2 Front",
        @"Start Month 3 Front",
        @"Final Front"];
    }
    
    // SIDE
    else if ([segue.identifier isEqualToString:@"Side"]) {
        
        tempMonthPhotoAngle = @[@"Start Month 1 Side",
        @"Start Month 2 Side",
        @"Start Month 3 Side",
        @"Final Side"];
    }
    
    // BACK
    else if ([segue.identifier isEqualToString:@"Back"]) {
        
        tempMonthPhotoAngle = @[@"Start Month 1 Back",
        @"Start Month 2 Back",
        @"Start Month 3 Back",
        @"Final Back"];
    }
    
    if (tempMonthPhotoAngle.count != 0) {
    
        for (int i = 0; i < tempMonthPhotoAngle.count; i++) {
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:[photoNC fileLocation:tempMonthPhotoAngle[i] ]]) {
                
                [monthPhotoAngle addObject:[photoNC loadImage:tempMonthPhotoAngle[i] ]];
            }
        }
    
        // Convert the mutable array to a normal unmutable array.
        ppvc.arrayOfImages = [monthPhotoAngle copy];
        ppvc.arrayOfImageTitles = tempMonthPhotoAngle;
    }
}
@end
