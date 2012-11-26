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
#import "MemorySpot.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self loadDataFile];
    [self createMemory];
    [self runBaseCase];
    [self runAlgorithm];
    return YES;
}


//loads the data file in from the data.plist and puts each sensor into the proper array. Sorts all targets by the x axis
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
    
    //convert the NSDictionary objects into actual objects
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
    
    //add the infinity sensors to the upper and lower sensor array
    [self addInfinitySensors];
    
}

//sorts all targets by the increasing x axis
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

//creates a 3-dimensional array sorted by targets, than upper sensors, than lower senors. It holds a MemorySpot object, which holds the weight and the sensors used to achieve such weight
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
    
    //fill in all double infinitys as infinity
    MemorySpot *infSpot = [[MemorySpot alloc] initWithWeight:INFINITY andSolution:nil];
    for (NSMutableArray *targetArray in self.memory) {
        NSMutableArray *upperInfMemory = targetArray.lastObject;
        //the last object will be the lower inf
        upperInfMemory[self.lowerSensors.count-1] = infSpot;
    }
}

//goes through every option for the first target. This "base case" fills in every location in the 3D memory array, so when the OPT method is called later, it will already have these values to fill in.
- (void)runBaseCase {
    Target *t = self.targets[0];
    int targetIndex = 0;
    
    NSMutableArray *targetMemory = self.memory[targetIndex];
    
    //we need to perform the base case for every sensor
    NSArray *upperSensors = self.upperSensors;
    NSArray *lowerSensors = self.lowerSensors;
    
    NSLog(@"Sensors in range of %@: U:%@ \n L: %@",t.name, [t upperSensorsInRange], [t lowerSensorsInRange]);
    
    //find the weight with every combination of upper/lower targets
    for (Sensor *upper in upperSensors) {
        NSMutableArray *upperMemory = targetMemory[upper.index];
        
        for (Sensor *lower in lowerSensors) {
            if (upper == self.upperInfinity && lower == self.lowerInfinity) {
                break;
            }
            
            float weight = upper.weight+lower.weight;
            
            //make sure at least one of the sensors covers the target
            MemorySpot *m = [[MemorySpot alloc] init];

            if ([self doSensorsUpper:upper lower:lower coverTarget:t]) {
                NSLog(@"Target: %@, Upper:%@, Lower:%@ weight %.2f", t.name, upper.name, lower.name, weight);
                m.weight = weight;
                m.solution = [NSSet setWithObjects:lower, upper, nil];
            } else {
                m.weight = INFINITY;
            }
            
            upperMemory[lower.index] = m;
        }
    }
}

//Looks through every possiblity of the last target. It then returns the one with the smallest cost.
- (void)runAlgorithm {
    float minCost = INFINITY;
    MemorySpot *finalAnswerSpot = nil;
    
    for (Sensor *upper in self.upperSensors) {
        for (Sensor *lower in self.lowerSensors) {
            MemorySpot *spot = [self OptForTarget:self.targets.lastObject upper:upper lower:lower];
            float cost = spot.weight;
            if (cost < minCost) {
                minCost = cost;
                finalAnswerSpot = spot;
            }
        }
    }
    
    //just in case, remove the inf and -inf sensors if they are still in the solution
    NSMutableSet *finalSet = [NSMutableSet setWithSet:finalAnswerSpot.solution];
    [finalSet removeObject:self.upperInfinity];
    [finalSet removeObject:self.lowerInfinity];

    NSLog(@"the minimum cost is: %.2f", minCost);
    NSLog(@"The final solution of Sensors is: %@", finalSet);
    
    //store these in properties, so we can display on the screen later
    self.finalSolution = finalSet;
    self.minCost = minCost;
}

//the main recursive call for the entire app. Given a target, upperSensor, and lowerSensor it will return the lowest weight and the sensors that cover it, providing that the upperSensor and lowerSensor are the dominating sensors.
//for more information, see the report
- (MemorySpot *)OptForTarget:(Target *)t upper:(Sensor *)upper lower:(Sensor *)lower {
    //first check if the answer is already stored
    MemorySpot *mem = [self spotForT:t upper:upper lower:lower];
    if (mem) {
        return mem;
    }
    
    //we currently do not have this stored, so lets go find it
    //get the previous target
    Target *prevTarget = [self targetBeforeTarget:t];
    float minCost = INFINITY;
    MemorySpot *minMemorySpot = nil; //the location to the previous spot in memory
    for (Sensor *anUpper in self.upperSensors) {
        if ([upper dominatesSensor:anUpper atTarget:t]) {
            for (Sensor *aLower in self.lowerSensors) {
                if ([lower dominatesSensor:aLower atTarget:t] && !(anUpper == self.upperInfinity && aLower == self.lowerInfinity)) {
                    //check to make sure at least one of these covers the sensor, not including infinity
                    if ([self doSensorsUpper:upper lower:lower coverTarget:t]) {
                        MemorySpot *spot = [self OptForTarget:prevTarget upper:anUpper lower:aLower];
                        
                        float cost = spot.weight;
                        if (cost != INFINITY) {
                            if (anUpper != upper) {
                                cost += upper.weight;
                            }
                            
                            if (aLower != lower) {
                                cost += lower.weight;
                            }
                            
                            if (cost < minCost) {
                                minCost = cost;
                                minMemorySpot = spot;
                            }
                        }
                    }
                }
            }
        }
    }

    
    //NSSet's will not allow duplicates, so we can just add the new ones and not have to worry about if they were already in there
    NSMutableSet *newSolution = [[NSMutableSet alloc] init];
    [newSolution addObjectsFromArray:[minMemorySpot.solution allObjects]];
    [newSolution addObject:upper];
    [newSolution addObject:lower];

    MemorySpot *newMemSpot = [[MemorySpot alloc] initWithWeight:minCost andSolution:newSolution];
    [self setSpot:newMemSpot forT:t upper:upper lower:lower];
    return newMemSpot;
    
}



#pragma mark - Helper Methods

//looks at the two sensors and target, and makes sure that at least one of them (not counting the infinity sensors) cover the sensor
- (BOOL)doSensorsUpper:(Sensor *)upper lower:(Sensor *)lower coverTarget:(Target *)t {
    BOOL sensorInRange = NO;
    
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
    
    return sensorInRange;
}

//sets the MemorySpot in the correct location in memory
- (void)setSpot:(MemorySpot *)mem forT:(Target *)t upper:(Sensor *)upper lower:(Sensor *)lower {
    int targetNum = [self.targets indexOfObject:t];
    self.memory[targetNum][upper.index][lower.index] = mem;
}

//retuns the MemorySpot given a target, upper and lower sensor
- (MemorySpot *)spotForT:(Target *)t upper:(Sensor *)upper lower:(Sensor *)lower {
    int tIndex = [self.targets indexOfObject:t];
    if (tIndex != NSNotFound) {
        MemorySpot *num = self.memory[tIndex][upper.index][lower.index];
        if (num && ![num isKindOfClass:[NSNull class]]) {
            return num;
        }
    }
    return nil;
}

//returns the target directly before t along the x axis. 
- (Target *)targetBeforeTarget:(Target *)t {
    int index = [self.targets indexOfObject:t];
    
    if (index == NSNotFound || index == 0) {
        return nil;
    } else {
        return self.targets[index-1];
    }
}

@end
