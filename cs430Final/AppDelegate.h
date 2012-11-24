//
//  AppDelegate.h
//  cs430Final
//
//  Created by Matthew Knippen on 11/17/12.
//  Copyright (c) 2012 Zwiffer Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NSMutableArray *targets;
@property (nonatomic, strong) NSMutableArray *upperSensors;
@property (nonatomic, strong) NSMutableArray *lowerSensors;
@property (nonatomic, strong) NSMutableArray *memory;

@end
