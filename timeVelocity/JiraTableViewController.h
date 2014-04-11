//
//  JiraTableViewController.h
//  timeVelocity
//
//  Created by Tim Hanby on 3/31/14.
//  Copyright (c) 2014 Timothy Hanby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>

@interface JiraTableViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *tableArray;
@property (strong, nonatomic) NSDate *dateOfWeek;
@property (strong, nonatomic) NSString *nameOfEmployee;

@end
