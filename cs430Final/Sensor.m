//
//  Sensor.m
//  cs430Final
//
//  Created by Matthew Knippen on 11/20/12.
//  Copyright (c) 2012 Zwiffer Inc. All rights reserved.
//

#import "Sensor.h"
#import "Target.h"

@implementation Sensor

//convience method to turn the x,y properties to a CGPoint
- (CGPoint)point {
    return CGPointMake(self.x, self.y);
}

//given an NSDictionary, fill in the sensor with all the proper information
- (void)setWithDictionary:(NSDictionary *)dict {
    self.x = [dict[@"x"] floatValue];
    self.y = [dict[@"y"] floatValue];
    self.weight = [dict[@"weight"] floatValue];
    self.name = dict[@"name"];
}

//uses the distance formula to determine the distance between two points
- (float)distanceBetweenPoints:(CGPoint)point1 second:(CGPoint)point2 {
    float dx = point2.x - point1.x;
    float dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy);
};

//determines if the current target dominates another target.
//for more information, see the report
- (BOOL)dominatesSensor:(Sensor *)s atTarget:(Target *)t {
    //dont worry about the point, just the x axis of the target
    
    //first, find out if the sensor crosses x
    //we do not have to check if the current sensor is in range, because this method was called because it was found from targetsInRange method
    if (abs(s.x - t.x) > 1) {
        //the sensor does not cross the line, so it dominates
        return YES;
    }
    
    //second case: whichever is lower/higher on the line (depending on if it is an upper/lower sensor)
    
    //first get the equation of the circles and line
    //our goal is to get a,b,c for the quad eqn
    //a = 1 for all
    //b = 2(y1)
    //c = (y1)^2+(t.x-x1)^2 - 1
    //(x-x1)+(y-y1)=1 x=target.x
    float b1 = self.y * 2;
    float c1 = (self.y*self.y)+((t.x-self.x)*(t.x-self.x))-1;
    float b2 = s.y * 2;
    float c2 = (s.y*s.y)+((t.x-s.x)*(t.x-s.x))-1;
    int currentLowHighPoint = [self quadraticEqnForA:1 b:b1 c:c1 upper:!self.isUpper];
    int sensorLowHighPoint = [self quadraticEqnForA:1 b:b2 c:c2 upper:!self.isUpper];
    
    if (self.isUpper) {
        //we care about the lower low point
        if (currentLowHighPoint < sensorLowHighPoint) {
            return YES;
        } else if (currentLowHighPoint > sensorLowHighPoint) {
            return NO;
        }
    } else {
        //we care about the higher high point
        if (currentLowHighPoint > sensorLowHighPoint) {
            return YES;
        } else if (currentLowHighPoint < sensorLowHighPoint) {
            return NO;
        }
    }

    //third case: they are tied, return the one on the left (less further along the x axis)
    if (self.x - s.x > 0) {
        return NO;
    } else {
        return YES;
    }
}

//retuns either the higher or lower number based on the upper BOOL
-(float)quadraticEqnForA:(float)a b:(float)b c:(float)c upper:(BOOL)upper {
    int answer1 = (-b + sqrt((b*b)-4*(a*c)))/2*a;
    int answer2 = (-b - sqrt((b*b)-4*(a*c)))/2*a;
    
    if (upper) {
        if (answer1 <= answer2) {
            return answer2;
        } else {
            return answer1;
        }
    } else {
        if (answer1 <= answer2) {
            return answer1;
        } else {
            return answer2;
        }
    }
}

//describes the object in debugging as well as the final solution
- (NSString *)description {
    return self.name;
}

@end
