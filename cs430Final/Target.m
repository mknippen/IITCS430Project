//
//  Target.m
//  cs430Final
//
//  Created by Matthew Knippen on 11/20/12.
//  Copyright (c) 2012 Zwiffer Inc. All rights reserved.
//

#import "Target.h"

@implementation Target

- (CGPoint)point {
    return CGPointMake(self.x, self.y);
}

- (void)setWithDictionary:(NSDictionary *)dict {
    self.x = [dict[@"x"] floatValue];
    self.y = [dict[@"y"] floatValue];
    self.name = dict[@"name"];
}

@end
