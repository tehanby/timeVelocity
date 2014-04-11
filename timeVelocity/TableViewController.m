//
//  ViewController.m
//  timeVelocity
//
//  Created by Tim Hanby on 3/14/14.
//  Copyright (c) 2014 Timothy Hanby. All rights reserved.
//

#import "TableViewController.h"
#import "TimeViewController.h"
#import "ArrayDataSource.h"

static NSString * const NamesCellIdentifier = @"NameCell";

@interface TableViewController ()

@property (nonatomic, strong) ArrayDataSource *namesArrayDataSource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self buildNamesArray];
}

#pragma mark - Build Table View
- (void)buildTableView:(NSMutableArray *)namesArray
{
    TableViewCellConfigureBlock configureCell = ^(UITableViewCell *cell, NSString *name) {
        [cell.textLabel setText:name];
    };
    
    self.namesArrayDataSource = [[ArrayDataSource alloc] initWithArray:namesArray
                                                        cellIdentifier:NamesCellIdentifier
                                                    configureCellBlock:configureCell];
    
    self.tableView.dataSource = self.namesArrayDataSource;
    self.searchDisplayController.searchResultsDataSource = self.namesArrayDataSource;
    
    [self.tableView reloadData];
}

- (void)buildNamesArray
{
    NSMutableArray *namesArray = [[NSMutableArray alloc] init];
    //NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys: self.nameOfUserToBuildTableArray, nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    __weak typeof (self) weakSelf = self;
    [manager GET:@"http://localhost:8080/service/log/users/v1/60" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSDictionary *json = (NSDictionary*)responseObject;
        for (NSDictionary *employees in json) {
            [namesArray addObject:[employees objectForKey:@"ContactID"]];
        }
        [weakSelf buildTableView:namesArray];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    TimeViewController *tvc = [segue destinationViewController];
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
    [tvc setNameOfEmployee:[cell.textLabel.text mutableCopy]];
    
}

@end
