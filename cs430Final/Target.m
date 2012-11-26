//
//  Target.m
//  cs430Final
//
//  Created by Matthew Knippen on 11/20/12.
//  Copyright (c) 2012 Zwiffer Inc. All rights reserved.
//

#import "Target.h"
#import "Sensor.h"
#import "AppDelegate.h"

@implementation Target

- (CGPoint)point {
    return CGPointMake(self.x, self.y);
}

- (void)setWithDictionary:(NSDictionary *)dict {
    self.x = [dict[@"x"] floatValue];
    self.y = [dict[@"y"] floatValue];
    self.name = dict[@"name"];
}

- (NSArray *)upperSensorsInRange {
    AppDelegate *ad = [UIApplication sharedApplication].delegate;
    NSMutableArray *sensorsInRange = [[NSMutableArray alloc] initWithCapacity:ad.upperSensors.count];
    for (Sensor *s in ad.upperSensors) {
        if ([self isSensorInRange:s]) {
            [sensorsInRange addObject:s];
        }
    }
    
    return sensorsInRange;
}

- (NSArray *)lowerSensorsInRange {
    AppDelegate *ad = [UIApplication sharedApplication].delegate;
    NSMutableArray *sensorsInRange = [[NSMutableArray alloc] initWithCapacity:ad.lowerSensors.count];
    for (Sensor *s in ad.lowerSensors) {
        if ([self isSensorInRange:s]) {
            [sensorsInRange addObject:s];
        }
    }
    
    return sensorsInRange;
}

- (float)distanceBetweenPoints:(CGPoint)point1 second:(CGPoint)point2 {
    float dx = point2.x - point1.x;
    float dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy);
};

- (BOOL)isSensorInRange:(Sensor *)sensor {
    AppDelegate *ad = [UIApplication sharedApplication].delegate;
    //infinitys are always in range
    if (sensor == ad.upperInfinity || sensor == ad.lowerInfinity) {
        return YES;
    }
    
    float distance = [self distanceBetweenPoints:self.point second:sensor.point];
    if (distance <= 1) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)description {
    return self.name;
}

@end
