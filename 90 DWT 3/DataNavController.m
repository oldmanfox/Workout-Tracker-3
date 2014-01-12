//
//  DataNavController.m
//  90 DWT 1
//
//  Created by Jared Grant on 7/11/12.
//  Copyright (c) 2012 g-rantsoftware.com. All rights reserved.
//

#import "DataNavController.h"

@interface DataNavController ()

@end

@implementation DataNavController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (((MainTBC *)self.parentViewController).workoutChanged) {
        
        [self popToRootViewControllerAnimated:YES];
        ((MainTBC *)self.parentViewController).workoutChanged = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Populate the Arrays with their workouts.  Some workouts have more than one round (like chestBack).
    // I added the round at the end of each exercise to distinguish it from the previous round when storing.
    
    
    self.chestBack = @[@"Push-Ups Round 1",
                    @"Wide Pull-Ups Round 1",
                    @"Shoulder Width Push-Ups Round 1",
                    @"Underhand Pull-Ups Round 1",
                    @"Wide Push-Ups Round 1",
                    @"Narrow Pull-Ups Round 1",
                    @"Decline Push-Ups Round 1",
                    @"Bent Over Rows Round 1",
                    @"Diamonds Round 1",
                    @"Single Arm Bent Over Rows Round 1",
                    @"Under The Wall Round 1",
                    @"Seated Back Flys Round 1",

                    // Start Round 2
                    @"Wide Pull-Ups Round 2",
                    @"Push-Ups Round 2",
                    @"Underhand Pull-Ups Round 2",
                    @"Shoulder Width Push-Ups Round 2",
                    @"Narrow Pull-Ups Round 2",
                    @"Wide Push-Ups Round 2",
                    @"Bent Over Rows Round 2",
                    @"Decline Push-Ups Round 2",
                    @"Single Arm Bent Over Rows Round 2",
                    @"Diamonds Round 2",
                    @"Seated Back Flys Round 2",
                    @"Under The Wall Round 2",

                    // Ab Workout
                    @"Ab Workout Round 1"];

    self.shouldersArms = @[@"Shoulder Presses Round 1",
                        @"In & Out Bicep Curls Round 1",
                        @"Two-Arm Tricep Kickbacks Round 1",
    
                        // Round 2
                        @"Shoulder Presses Round 2",
                        @"In & Out Bicep Curls Round 2",
                        @"Two-Arm Tricep Kickbacks Round 2",

                        @"Curl/Shoulder Presses Round 1",
                        @"Single Concentration Bicep Curls Round 1",
                        @"Dips Round 1",
    
                        // Round 2
                        @"Curl/Shoulder Presses Round 2",
                        @"Single Concentration Bicep Curls Round 2",
                        @"Dips Round 2",

                        @"Chin Rows Round 1",
                        @"Parallel Bicep Curls Round 1",
                        @"Twisting Tricep Extentions Round 1",
    
                        // Round 2
                        @"Chin Rows Round 2",
                        @"Parallel Bicep Curls Round 2",
                        @"Twisting Tricep Extentions Round 2",

                        @"Seated Shoulder Flys Round 1",
                        @"Double Concentration Bicep Curls Round 1",
                        @"Overhead Tricep Extensions Round 1",
    
                        // Round 2
                        @"Seated Shoulder Flys Round 2",
                        @"Double Concentration Bicep Curls Round 2",
                        @"Overhead Tricep Extensions Round 2",

                        @"2-Way Shoulder Flys Round 1",
                        @"Hammer Bicep Curls Round 1",
                        @"Bodyweight Tricep Extensions Round 1",
    
                        // Round 2
                        @"2-Way Shoulder Flys Round 2",
                        @"Hammer Bicep Curls Round 2",
                        @"Bodyweight Tricep Extensions Round 2",
    
                        // Ab Workout
                        @"Ab Workout Round 1"];
    
    self.legsBack = @[@"Chair Lunges Round 1",
                    @"Squat to Calf Extensions Round 1",
                    @"Underhand Pull-Ups 1 Round 1",
                    @"Single Leg Lunges Round 1",
                    @"Hold Parallel Squats Round 1",
                    @"Wide Pull-Ups 1 Round 1",
                    @"Reverse Lunges Round 1",
                    @"Side Lunges Round 1",
                    @"Narrow Pull-Ups 1 Round 1",
                    @"1 Leg Hold Parallel Squats Round 1",
                    @"Deadlifts Round 1",
                    @"2-Way Pull-Ups 1 Round 1",

                    @"3-Way Lunges Round 1",
                    @"Toe Lunges Round 1",
                    @"Underhand Pull-Ups 2 Round 1", // 2
                    @"Chair Squats Round 1",
                    @"Lunge Calf Extensions Round 1",
                    @"Wide Pull-Ups 2 Round 1", // 2
                    @"Crouching Tiger Round 1",
                    @"Calf Raises Round 1",
                    @"Narrow Pull-Ups 2 Round 1",  // 2
                    @"1 Leg Squats Round 1",
                    @"2-Way Pull-Ups 2 Round 1",  // 2

                    // Ab Workout
                    @"Ab Workout Round 1"];
    
    self.coreFitness = @[@"Offset Push-Ups Round 1",
                    @"Back to Stomach 1 Round 1",
                    @"Side Lunges Round 1",
                    @"Runner Lunges Round 1",
                    @"Push-Ups Round 1",
                    @"Back to V Round 1",
                    @"Deep Side Lunges Round 1",
                    @"Top Shelf Round 1",
                    @"Burpees Round 1",
                    @"Side Sphinx Raises Round 1",
                    @"Squat Press Round 1",
                    @"Plank Crunches Round 1",
                    @"Plank Crawls Round 1",
                    @"Back to Stomach 2 Round 1",
                    @"Lunge to 3 Way Arms Round 1",
                    @"Line Jumps Round 1",
                    @"Half Plank Push-Ups Round 1",
                    @"Standing Crunches Round 1",
                    @"Squat Jumps Round 1",
                    @"Plank Push-Ups Round 1",
                    @"Tractor Tires Round 1",
                    @"Dips Round 1"];
    
   self.chestShouldersTri = @[@"3-Way Push-Ups Round 1",
                            @"2-Way Shoulder Flys Round 1",
                            @"Dips Round 1",
                            @"Push-Ups Round 1",
                            @"Upside Down Shoulder Presses Round 1",
                            @"Bodyweight Tricep Extensions Round 1",
                            @"Side Push-Ups Round 1",
                            @"Shoulder Rotations Round 1",
                            @"Tricep Extensions 1 Round 1",
                            @"2-Way Push-Ups Round 1",
                            @"Shoulder Presses Round 1",
                            @"Tricep Extensions 2 Round 1",
                            @"Lateral Push-Ups Round 1",
                            @"Lateral Shoulder Raises Round 1",
                            @"Tricep Extensions 3 Round 1",
                            @"1-Arm Push-Ups Round 1",
                            @"Side Shoulder Circles Round 1",
                            @"Footballs Round 1",
                            @"Plyometric Push-Ups Round 1",
                            @"Front Shoulder Raises Round 1",
                            @"Tricep Extensions 4 Round 1",
                            @"Side Plank Push-Ups Round 1",
                            @"3-Way Arms Round 1",
                            @"Chest Presses Round 1",

                            // Ab Workout
                            @"Ab Workout Round 1"];
    
    self.backBiceps = @[@"Wide Pull-Ups Round 1",
                    @"Single Arm Bent Over Rows 1 Round 1",
                    @"Bicep Curls 1 Round 1",
                    @"Bicep Curls 2 Round 1",
                    @"2-Way Pull-Ups Round 1",
                    @"Single Arm Bent Over Rows 2 Round 1",
                    @"Bicep Curls 3 Round 1",
                    @"Concentration Curls Round 1",
                    @"Side to Side Pull-Ups Round 1",
                    @"Bent Over Rows Round 1",
                    @"Wide Arm Curls Round 1",
                    @"Parallel Bicep Curls Round 1",
                    @"Uneven Pull-Ups Round 1",
                    @"Alternating Bent Over Rows Round 1",
                    @"Double Concentration Bicep Curls Round 1",
                    @"Bicep Curls 4 Round 1",
                    @"Underhand Pull-Ups Round 1",
                    @"Seated Back Flys Round 1",
                    @"Bicep Curls 5 Round 1",
                    @"Hammer Curls Round 1",
                    @"Pull-Ups Round 1",
                    @"Lower Back Raises Round 1",
                    @"2-Way Hammer Curls Round 1",
                    @"Burnout Bicep Curls 1 Round 1",
                    @"Burnout Bicep Curls 2 Round 1",
                    @"Burnout Bicep Curls 3 Round 1",
                    @"Burnout Bicep Curls 4 Round 1",

                    // Ab Workout
                    @"Ab Workout Round 1"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // This just says I only support the portriat mode orientation.  If I wanted to support landscape
    // I would put that here.
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
