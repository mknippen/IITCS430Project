//
//  Target.h
//  cs430Final
//
//  Created by Matthew Knippen on 11/20/12.
//  Copyright (c) 2012 Zwiffer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Sensor;

@interface Target : NSObject

@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;
@property (nonatomic, strong) NSString *name;

//convience method to turn the x,y properties to a CGPoint
- (CGPoint)point;

//given an NSDictionary, fill in the target with all the proper information
- (void)setWithDictionary:(NSDictionary *)dict;

//returns all of the upper/lower sensors in range to cover the target
- (NSArray *)upperSensorsInRange;
- (NSArray *)lowerSensorsInRange;

//given a sensor, determines if the sensor is in range to cover the target
- (BOOL)isSensorInRange:(Sensor *)sensor;

@end
