//
//  ViewController.h
//  cs430Final
//
//  Created by Matthew Knippen on 11/17/12.
//  Copyright (c) 2012 Zwiffer Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *numTargetsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numUpSensorsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLowSensorsLabel;
@property (weak, nonatomic) IBOutlet UILabel *minCostLabel;
@property (weak, nonatomic) IBOutlet UITextView *sensorListTextView;


@end
