//
//  AppDelegate.h
//  cs430Final
//
//  Created by Matthew Knippen on 11/17/12.
//  Copyright (c) 2012 Zwiffer Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Sensor;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NSMutableArray *targets;
@property (nonatomic, strong) NSMutableArray *upperSensors;
@property (nonatomic, strong) NSMutableArray *lowerSensors;
@property (nonatomic, strong) NSMutableArray *memory;

@property (nonatomic, strong) Sensor *upperInfinity;
@property (nonatomic, strong) Sensor *lowerInfinity;


@end
