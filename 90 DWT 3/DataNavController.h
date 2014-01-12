//
//  DataNavController.h
//  90 DWT 1
//
//  Created by Jared Grant on 7/11/12.
//  Copyright (c) 2012 g-rantsoftware.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainTBC.h"

@interface DataNavController : UINavigationController
@property (strong, nonatomic) NSString *month;    // Current month.
@property (strong, nonatomic) NSString *routine;  // Current workout routine (Normal, 2-A-Days, or Tone).
@property (strong, nonatomic) NSString *week;     // Current week of workout.
@property (strong, nonatomic) NSString *workout;  // Full name of an individual workout.
@property (strong, nonatomic) NSNumber *index;    // The number of times this workout has been done.

@property (strong, nonatomic) NSArray *chestBack;    // List of exercises for this workout with round added to it.
@property (strong, nonatomic) NSArray *shouldersArms;  // List of exercises for this workout with round added to it.
@property (strong, nonatomic) NSArray *legsBack;  // List of exercises for this workout with round added to it.
@property (strong, nonatomic) NSArray *coreFitness;  // List of exercises for this workout with round added to it.
@property (strong, nonatomic) NSArray *chestShouldersTri;  // List of exercises for this workout with round added to it.
@property (strong, nonatomic) NSArray *backBiceps;  // List of exercises for this workout with round added to it.
@property (strong, nonatomic) NSString *lightCell5;  // ((Week 8 or 13) AND routine = Lean) = Full on Cardio.  Else = Core Fitness.
@end
