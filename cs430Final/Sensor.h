//
//  Sensor.h
//  cs430Final
//
//  Created by Matthew Knippen on 11/20/12.
//  Copyright (c) 2012 Zwiffer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Target;

@interface Sensor : NSObject

@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;
@property (nonatomic, assign) float weight;
@property (nonatomic, assign) BOOL isUpper;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int index;

//convience method to turn the x,y properties to a CGPoint
- (CGPoint)point;

//given an NSDictionary, fill in the sensor with all the proper information
- (void)setWithDictionary:(NSDictionary *)dict;

//determines if the current target dominates another target.
//for more information, see the report
- (BOOL)dominatesSensor:(Sensor *)sensor atTarget:(Target *)target;

@end
