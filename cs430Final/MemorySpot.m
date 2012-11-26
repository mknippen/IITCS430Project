//
//  MemorySpot.m
//  cs430Final
//
//  Created by Matthew Knippen on 11/26/12.
//  Copyright (c) 2012 Zwiffer Inc. All rights reserved.
//

#import "MemorySpot.h"

@implementation MemorySpot

-(id)initWithWeight:(float)weight {
    self = [super init];
    if (self) {
        self.weight = weight;
    }
    return self;
}


-(id)initWithWeight:(float)weight andSolution:(NSSet *)solution {
    self = [super init];
    if (self) {
        self.weight = weight;
        self.solution = solution;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Weight: %f, Solutions: %i", self.weight, self.solution.count];
}

@end
