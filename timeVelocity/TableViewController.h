//
//  ViewController.h
//  timeVelocity
//
//  Created by Tim Hanby on 3/14/14.
//  Copyright (c) 2014 Timothy Hanby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>

@interface TableViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *tableArray;
@property (strong, nonatomic) NSString *nameOfUserToBuildTableArray;

@end
