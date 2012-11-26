//
//  MemorySpot.h
//  cs430Final
//
//  Created by Matthew Knippen on 11/26/12.
//  Copyright (c) 2012 Zwiffer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemorySpot : NSObject

@property (nonatomic, assign) float weight;
@property (nonatomic, strong) NSSet *solution;

//convenience methods
- (id)initWithWeight:(float)weight andSolution:(NSSet *)solution;
- (id)initWithWeight:(float)weight;

@end
