//
//  HMIAPHelper.m
//  90 DWT 3
//
//  Created by Grant, Jared on 5/10/13.
//  Copyright (c) 2013 Grant, Jared. All rights reserved.
//

#import "DWT3IAPHelper.h"

@implementation DWT3IAPHelper

+ (DWT3IAPHelper *)sharedInstance {
    
    static dispatch_once_t once;
    static DWT3IAPHelper * sharedInstance;
    
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects: @"com.grantsoftware.90DWT3.slidergraph", nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    
    return sharedInstance;
}

@end
