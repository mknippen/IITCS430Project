//
//  ViewController.m
//  cs430Final
//
//  Created by Matthew Knippen on 11/17/12.
//  Copyright (c) 2012 Zwiffer Inc. All rights reserved.
//

#import "ViewController.h"
#import "Target.h"
#import "Sensor.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *ad = [UIApplication sharedApplication].delegate;
    
    self.numTargetsLabel.text = [NSString stringWithFormat:@"Number of Targets: %i", ad.targets.count];
    self.numUpSensorsLabel.text = [NSString stringWithFormat:@"Number of Upper Sensors: %i", ad.upperSensors.count-1];
    self.numLowSensorsLabel.text = [NSString stringWithFormat:@"Number of Lower Sensors: %i", ad.lowerSensors.count-1];
    self.minCostLabel.text = [NSString stringWithFormat:@"Minimum Cost: %.0f", ad.minCost];
    self.sensorListTextView.text = [NSString stringWithFormat:@"%@", ad.finalSolution];
}

@end