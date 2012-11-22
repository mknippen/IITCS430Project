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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadDataFile];
    [self createMemory];
    
}

- (void)loadDataFile {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"];
    NSDictionary *dataDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    //get the bounds
    NSArray *bounds = dataDict[@"bounds"];
    float upperBound;
    if (bounds.count == 2) {
        NSNumber *bound1 = bounds[0];
        NSNumber *bound2 = bounds[1];
        if (bound1.floatValue > bound2.floatValue) {
            upperBound = bound1.floatValue;
        } else {
            upperBound = bound2.floatValue;
        }
    } else {
        NSLog(@"Error: There should be TWO bounds");
    }
    
    //get the targets, than sort them by X
    NSArray *targetDicts = dataDict[@"targets"];
    self.targets = [[NSMutableArray alloc] initWithCapacity:targetDicts.count];
    for (NSDictionary *dict in targetDicts) {
        Target *t = [[Target alloc] init];
        [t setWithDictionary:dict];
        [self.targets addObject:t];
    }
    [self sortTargets];
        
    //get the sensors, then separate them into lower and upper targets
    NSArray *sensorDicts = dataDict[@"sensors"];
    self.upperSensors = [[NSMutableArray alloc] initWithCapacity:(targetDicts.count/2)]; //capacities for NSMutableArrays are estimates
    self.lowerSensors = [[NSMutableArray alloc] initWithCapacity:(targetDicts.count/2)];

    for (NSDictionary *dict in sensorDicts) {
        Sensor *s = [[Sensor alloc] init];
        [s setWithDictionary:dict];
        if (s.y < upperBound) {
            s.isUpper = NO;
            [self.lowerSensors addObject:s];
        } else {
            s.isUpper = YES;
            [self.upperSensors addObject:s];
        }
    }
}

- (void)sortTargets {
    [self.targets sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Target *t1 = (Target *)obj1;
        Target *t2 = (Target *)obj2;
        
        if (t1.x == t2.x) {
            return NSOrderedSame;
        } else if (t1.x < t2.x) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
}

- (void)createMemory {
    int targetCount = self.targets.count;
    self.memory = [[NSMutableArray alloc] initWithCapacity:targetCount];
}


@end
