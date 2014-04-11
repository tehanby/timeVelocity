//
//  JiraTableViewController.m
//  timeVelocity
//
//  Created by Tim Hanby on 3/31/14.
//  Copyright (c) 2014 Timothy Hanby. All rights reserved.
//

#import "JiraTableViewController.h"
#import "ArrayDataSource.h"

static NSString * const JiraCellIdentifier = @"JiraCell";
#define SECS_PER_DAY (86400)

@interface JiraTableViewController ()

@property (nonatomic, strong) ArrayDataSource *dataSource;
@property (strong) NSDateFormatter *formatter;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationItem *jiraTicketsHeader;

@end

@implementation JiraTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    {
        self.formatter = [[NSDateFormatter alloc] init];
        [self.formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"MM/dd/yyyy" options:0 locale:[NSLocale currentLocale]]];
    }
    
    self.jiraTicketsHeader.title = [NSString stringWithFormat:@"Jira Tickets for the week of %@", [self.formatter stringFromDate:self.dateOfWeek]];
    
    [self buildTicketsArray];
}

#pragma mark - Build Table View
- (void)buildTableView:(NSMutableArray *)ticketsArray
{
    TableViewCellConfigureBlock configureCell = ^(UITableViewCell *cell, NSString *name) {
        [cell.textLabel setText:name];
    };
    
    self.dataSource = [[ArrayDataSource alloc] initWithArray:ticketsArray
                                                        cellIdentifier:JiraCellIdentifier
                                                    configureCellBlock:configureCell];
    
    self.tableView.dataSource = self.dataSource;
    
    [self.tableView reloadData];
}

- (void)buildTicketsArray
{
    NSMutableArray *ticketsArray = [[NSMutableArray alloc] init];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    NSDateFormatter *tmpFormatter = [[NSDateFormatter alloc] init];
    [tmpFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *startDateForSearch = [tmpFormatter stringFromDate:self.dateOfWeek];
    NSString *endDateForSearch = [tmpFormatter stringFromDate: [self.dateOfWeek dateByAddingTimeInterval:((7) * SECS_PER_DAY)]];
    NSString *searchURL = [NSString stringWithFormat:@"http://jira.trifecta.com/rest/api/2/search?jql=(assignee in ('%@') OR developer in ('%@'))AND updatedDate >= '%@' AND updatedDate <= '%@' ORDER BY updatedDate ASC", self.nameOfEmployee, self.nameOfEmployee, startDateForSearch, endDateForSearch];
    
    __weak typeof (self) weakSelf = self;
    [manager POST:[searchURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSDictionary *json = (NSDictionary*)responseObject;
        for (NSDictionary *tickets in [json objectForKey:@"issues"]) {
            id key = [tickets objectForKey:@"key"];
            NSString *worklogURL = [NSString stringWithFormat:@"http://jira.trifecta.com/rest/api/2/issue/%@/worklog", key];
            [manager POST:[worklogURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                //NSLog(@"JSON: %@", responseObject);
                NSDictionary *json = (NSDictionary*)responseObject;
                long timespent = 0;
                for (NSDictionary *worklog in [json objectForKey:@"worklogs"]) {
                    id name = [[worklog objectForKey:@"updateAuthor"] objectForKey:@"name"];
                    if (![name caseInsensitiveCompare:weakSelf.nameOfEmployee]) {
                        id timeSpentSeconds = [worklog objectForKey:@"timeSpentSeconds"];
                        timespent += [timeSpentSeconds longValue];
                    }
                }
                NSString *ticket = [NSString stringWithFormat:@"%@ Timespent = %ld minutes", key, (timespent/60)];
                [ticketsArray addObject:ticket];
                [weakSelf buildTableView:ticketsArray];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
