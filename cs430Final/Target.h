//
//  Target.h
//  cs430Final
//
//  Created by Matthew Knippen on 11/20/12.
//  Copyright (c) 2012 Zwiffer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Target : NSObject

@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;
@property (nonatomic, strong) NSString *name;

- (CGPoint)point;
- (void)setWithDictionary:(NSDictionary *)dict;

@end
