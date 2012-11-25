//
//  AppDelegate.m
//  cs430Final
//
//  Created by Matthew Knippen on 11/17/12.
//  Copyright (c) 2012 Zwiffer Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "Target.h"
#import "Sensor.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self loadDataFile];
    [self createMemory];
    [self runAlgorithm];
    return YES;
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
            s.index = self.lowerSensors.count;
            [self.lowerSensors addObject:s];
        } else {
            s.isUpper = YES;
            s.index = self.upperSensors.count;
            [self.upperSensors addObject:s];
        }
    }
    
    //add the infinity sensors
    [self addInfinitySensors];
    
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

- (void)addInfinitySensors {
    //place them off into INFINITY so by default they are not in range. We do this because we are automatically adding them, and we do not want to have a duplicate
    
    self.upperInfinity = [[Sensor alloc] init];
    self.upperInfinity.x = -INFINITY; //either INFINITY or -INFINITY would work here
    self.upperInfinity.y = INFINITY;
    self.upperInfinity.weight = 0;
    self.upperInfinity.name = @"inf";
    self.upperInfinity.isUpper = YES;
    self.upperInfinity.index = self.upperSensors.count;
    [self.upperSensors addObject:self.upperInfinity];
    
    self.lowerInfinity = [[Sensor alloc] init];
    self.lowerInfinity.x = -INFINITY;
    self.lowerInfinity.y = -INFINITY;
    self.lowerInfinity.weight = 0;
    self.lowerInfinity.name = @"-inf";
    self.lowerInfinity.isUpper = NO;
    self.lowerInfinity.index = self.lowerSensors.count;
    [self.lowerSensors addObject:self.lowerInfinity];
}

- (void)createMemory {
    int targetCount = self.targets.count;
    int upperCount = self.upperSensors.count;
    int lowerCount = self.lowerSensors.count;
    
    self.memory = [[NSMutableArray alloc] initWithCapacity:targetCount];
    for (int i=0; i<targetCount; i++) {
        //3D array, make the upper Sensors now
        NSMutableArray *aUpperArray = [[NSMutableArray alloc] initWithCapacity:upperCount];
        for (int i=0; i<upperCount; i++) {
            //now the lower sensors
            NSMutableArray *aLowerArray = [[NSMutableArray alloc] initWithCapacity:lowerCount];
            for (int i=0; i<lowerCount; i++) {
                //now the lower sensors
                //fill the arrays with NULLs
                [aLowerArray addObject:[NSNull null]];
            }
            [aUpperArray addObject:aLowerArray];
        }
        [self.memory addObject:aUpperArray];
    }
}

- (void)setWeight:(float)weight forT:(int)targetNum upper:(int)upper lower:(int)lower {
    self.memory[targetNum][upper][lower] = @(weight);
}

- (float)weightForT:(int)targetNum upper:(int)upper lower:(int)lower {
    return [self.memory[targetNum][upper][lower] floatValue];
}

- (void)runAlgorithm {
    
    for (Target *t in self.targets) {
        int targetIndex = [self.targets indexOfObject:t];
        BOOL sensorInRange = YES;
        
        NSMutableArray *targetMemory = self.memory[targetIndex];
        
        NSArray *upperSensors = self.upperSensors; //[t upperSensorsInRange];
        NSArray *lowerSensors = self.lowerSensors; //[t lowerSensorsInRange];
        
        NSLog(@"Sensors in range of %@: U:%@ \n L: %@",t.name, [t upperSensorsInRange], [t lowerSensorsInRange]);
        
        //find the weight with every combination of upper/lower targets
        for (Sensor *upper in upperSensors) {
            NSMutableArray *upperMemory = targetMemory[upper.index];
            
            for (Sensor *lower in lowerSensors) {
                if (upper == self.upperInfinity && lower == self.lowerInfinity) {
                    break;
                }
                
                float weight = upper.weight+lower.weight;
                
                if (targetIndex != 0) { //skip for the first target
                    //get the memory of the previous target
                    int lowestPossibleWeight = INFINITY;
                    NSArray *prevTargetMemory = self.memory[targetIndex-1];
                    int prevUpperIndex = 0;
                    for (NSArray *prevUpperMemory in prevTargetMemory) {
                        int prevLowerIndex = 0;
                        for (NSNumber *prevLowerMemory in prevUpperMemory) {
                            if (![prevLowerMemory isEqual:[NSNull null]]) {
                                int weightToTestAgainst = prevLowerMemory.floatValue;
                                
                                if (prevUpperIndex != upper.index) {
                                    weightToTestAgainst += upper.weight;
                                }
                                
                                if (prevLowerIndex != lower.index) {
                                    weightToTestAgainst += lower.weight;
                                }
                                
                                if (weightToTestAgainst < lowestPossibleWeight) {
                                    lowestPossibleWeight = weightToTestAgainst;
                                }
                            }
                            prevLowerIndex++;
                        }
                        prevUpperIndex++;
                    }
                    
                    weight = lowestPossibleWeight;
                } else {
                    //make sure at least one of the sensors covers the target
                    sensorInRange = NO;
                    
                    if (upper == self.upperInfinity) {
                        if ([t isSensorInRange:lower]) {
                            sensorInRange = YES;
                        }
                    } else if (lower == self.lowerInfinity) {
                        if ([t isSensorInRange:upper]) {
                            sensorInRange = YES;
                        }
                    } else {
                        //neither are infinity, just make sure one is in range
                        if ([t isSensorInRange:upper] || [t isSensorInRange:lower]) {
                            //at least one is in range, we're all good.
                            sensorInRange = YES;
                        }
                    }
                }
                
                if (sensorInRange) {
                    NSLog(@"Target: %@, Upper:%@, Lower:%@ weight %.2f", t.name, upper.name, lower.name, weight);
                    upperMemory[lower.index] = @(weight);
                }
            }
            
        }
    }
}




@end
