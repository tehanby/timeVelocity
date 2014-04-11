//
//  TimeViewController.h
//  timeVelocity
//
//  Created by Tim Hanby on 3/19/14.
//  Copyright (c) 2014 Timothy Hanby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import <CorePlot/CorePlot-CocoaTouch.h>
#import "LineChart.h"

@interface TimeViewController : UIViewController <CPTBarPlotDataSource, CPTBarPlotDelegate, CPTLegendDelegate>

@property (strong, nonatomic) NSMutableString *nameOfEmployee;
@property (strong, nonatomic) NSMutableArray *employeeHours;
@property (strong, nonatomic) NSMutableArray *jiraHours;

@end
