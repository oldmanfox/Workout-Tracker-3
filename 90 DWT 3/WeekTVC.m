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

#define debug 0

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
    
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    // Respond to changes in underlying store
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUI)
                                                 name:@"SomethingChanged"
                                               object:nil];

    self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"weight_lifting_selected"];
    
    // Show or Hide Ads
    if ([[DWT3IAPHelper sharedInstance] productPurchased:@"com.grantsoftware.90DWT3.removeads1"]) {
        
        // User purchased the Remove Ads in-app purchase so don't show any ads.
        //self.canDisplayBannerAds = NO;
        
    } else {
        
        // Show the Banner Ad
        //self.canDisplayBannerAds = YES;
        
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            
            // iPhone
            self.adView = [[MPAdView alloc] initWithAdUnitId:@"ec3e53b6f4b14bca87772951a23139f8"
                                                        size:MOPUB_BANNER_SIZE];
            self.bannerSize = MOPUB_BANNER_SIZE;
            
        } else {
            
            // iPad
            self.adView = [[MPAdView alloc] initWithAdUnitId:@"9041ef410d53400bbcaa965b3cd4ab86"
                                                        size:MOPUB_LEADERBOARD_SIZE];
            self.bannerSize = MOPUB_LEADERBOARD_SIZE;
            
        }
        
        self.adView.delegate = self;
        self.adView.frame = CGRectMake((self.view.bounds.size.width - self.bannerSize.width) / 2,
                                       self.bannerSize.height - self.bannerSize.height,
                                       self.bannerSize.width, self.bannerSize.height);
        
        [self.headerView addSubview:self.adView];
        
        [self.adView loadAd];
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
    
    [self convertPhotosToCoreData];
    [self convertMeasurementsToCoreData];
    [self convertSettingsToCoreData];
    [self addSession1ToExistingCoreDataObjects];
    [self findAutoLockSetting];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    // Show or Hide Ads
    if ([[DWT3IAPHelper sharedInstance] productPurchased:@"com.grantsoftware.90DWT3.removeads1"]) {
        
        // Don't show ads.
        self.tableView.tableHeaderView = nil;
        self.adView.delegate = nil;
        self.adView = nil;
        
    } else {
        
        // Show ads
        self.adView.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self findDefaultRoutine];
    
    [self.tableView reloadData];
    
    // Show or Hide Ads
    if ([[DWT3IAPHelper sharedInstance] productPurchased:@"com.grantsoftware.90DWT3.removeads1"]) {
        
        // Don't show ads.
        self.tableView.tableHeaderView = nil;
        self.adView.delegate = nil;
        self.adView = nil;
        
    } else {
        
        // Show ads
        self.adView.frame = CGRectMake((self.view.bounds.size.width - self.bannerSize.width) / 2,
                                       self.bannerSize.height - self.bannerSize.height,
                                       self.bannerSize.width, self.bannerSize.height);
        self.adView.hidden = NO;
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
    //NSLog(@"Routine = %@", ((DataNavController *)self.parentViewController).routine);
    
    // Return the number of sections.
    if ([self.navigationItem.title isEqualToString:@"Bulk"]) {
        return 3;
    }
    
    else {
        return 4;
    }
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
        //UIViewController *c = segue.destinationViewController;
        
        //c.interstitialPresentationPolicy = ADInterstitialPresentationPolicyAutomatic;
    }
}

#pragma mark - <MPAdViewDelegate>
- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
    CGSize size = [view adContentViewSize];
    CGFloat centeredX = (self.view.bounds.size.width - size.width) / 2;
    CGFloat bottomAlignedY = self.bannerSize.height - size.height;
    view.frame = CGRectMake(centeredX, bottomAlignedY, size.width, size.height);
    
    if (self.headerView.frame.size.height == 0) {
        
        // No ads shown yet.  Animate showing the ad.
        CGRect headerViewFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.bannerSize.height);
        
        [UIView animateWithDuration:0.25 animations:^{ self.headerView.frame = headerViewFrame;
            self.tableView.tableHeaderView = self.headerView;
            self.adView.hidden = YES;}
         
                         completion:^(BOOL finished) {self.adView.hidden = NO;
                         }];
        
    } else {
        
        // Ad is already showing.
        self.tableView.tableHeaderView = self.headerView;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    
    self.adView.hidden = YES;
    [self.adView rotateToOrientation:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    CGSize size = [self.adView adContentViewSize];
    CGFloat centeredX = (self.view.bounds.size.width - size.width) / 2;
    CGFloat bottomAlignedY = self.headerView.bounds.size.height - size.height;
    self.adView.frame = CGRectMake(centeredX, bottomAlignedY, size.width, size.height);
    
    self.adView.hidden = NO;
}

- (void)updateUI {
    
    if ([CoreDataHelper sharedHelper].iCloudStore) {
        
        [self performSelector:@selector(findDefaultRoutine) withObject:nil afterDelay:5.0 ];
    }
    else {
        [self findDefaultRoutine];
        [self findAutoLockSetting];
    }
}

- (void)findDefaultRoutine {
    
    // Fetch defaultRoutine objects
    NSManagedObjectContext *context = [[CoreDataHelper sharedHelper] context];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Routine" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSManagedObject *matches = nil;
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if ([objects count] != 0) {
        
        // Object has already been created. Get value of routine from it.
        matches = objects[[objects count] - 1];
        self.navigationItem.title = [matches valueForKey:@"defaultRoutine"];
        ((DataNavController *)self.parentViewController).routine = self.navigationItem.title;
    }
    else {
        
        // Object has not been created so this is the first time the app has been opened.
        ((DataNavController *)self.parentViewController).routine = @"Normal";
        self.navigationItem.title = ((DataNavController *)self.parentViewController).routine;
    }
}

- (void)findAutoLockSetting {
    
    // Fetch useBands objects
    NSManagedObjectContext *context = [[CoreDataHelper sharedHelper] context];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"AutoLock" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSManagedObject *matches = nil;
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    NSString *coredataAutoLockSetting;
    
    if ([objects count] != 0) {
        
        // Object has already been created. Get value of autolock from it.
        matches = objects[[objects count] - 1];
        
        coredataAutoLockSetting = [matches valueForKey:@"useAutoLock"];
    }
    
    else {
        
        // No matches.
        if (debug==1) {
            NSLog(@"No match found");
        }
        
        // Default setting is OFF
        coredataAutoLockSetting = @"OFF";
    }
    
    if ([coredataAutoLockSetting isEqualToString:@"ON"]) {
        
        // User wants to disable the autolock timer.
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
    
    else {
        // User doesn't want to disable the autolock timer.
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
}
@end
