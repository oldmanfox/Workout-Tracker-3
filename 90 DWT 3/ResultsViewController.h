//
//  ResultsViewController.h
//  90 DWT 1
//
//  Created by Jared Grant on 7/17/12.
//  Copyright (c) 2012 g-rantsoftware.com. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <iAd/iAd.h>
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"
#import "DataNavController.h"
#import "AppDelegate.h"
#import "UIViewController+Social.h"
#import "MPAdView.h"

@interface ResultsViewController : UIViewController <MFMailComposeViewControllerDelegate, UIActionSheetDelegate, MPAdViewDelegate>

@property (nonatomic) MPAdView *adView;

@property CGSize bannerSize;

@property (weak, nonatomic) IBOutlet UITextView *workoutSummary;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareActionButton;
@property (strong, nonatomic) NSArray *exerciseNames;

- (IBAction)shareActionSheet:(UIBarButtonItem *)sender;
@end