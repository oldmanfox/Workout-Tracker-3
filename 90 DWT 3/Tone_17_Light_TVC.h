//
//  Tone_17_Light_TVC.h
//  90 DWT 3
//
//  Created by Jared Grant on 1/5/14.
//  Copyright (c) 2014 Grant, Jared. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataNavController.h"
#import "UITableViewController+Design.h"
#import "MPAdView.h"

@interface Tone_17_Light_TVC : UITableViewController <MPAdViewDelegate>

@property (nonatomic) MPAdView *adView;

@property (nonatomic, strong) UIView *headerView;

@property CGSize bannerSize;

@property (weak, nonatomic) IBOutlet UITableViewCell *cell1;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell2;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell3;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell4;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell5;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell6;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell7;

@end
