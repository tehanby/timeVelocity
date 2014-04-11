//
//  TimeViewController.m
//  timeVelocity
//
//  Created by Tim Hanby on 3/19/14.
//  Copyright (c) 2014 Timothy Hanby. All rights reserved.
//

#import "TimeViewController.h"
#import "JiraTableViewController.h"

@interface TimeViewController ()

@property (weak, nonatomic) IBOutlet UINavigationItem *employeeNameHeader;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextWeek;
@property (weak, nonatomic) IBOutlet UIButton *previousWeek;
@property (weak, nonatomic) IBOutlet UIView *subView;
@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (strong) NSDateFormatter *formatter;
@property (weak,nonatomic) NSDate *dateOfWeek;
@property (nonatomic, strong) CPTBarPlot *jiraPlot;
@property (nonatomic, strong) CPTBarPlot *timeTrackerPlot;
@property (nonatomic, strong) NSNumber  *totalTime;

@end

@implementation TimeViewController

#define SECS_PER_DAY (86400)
CGFloat const CPDBarWidth = 0.25f;
CGFloat const CPDBarInitialX = 0.25f;

- (IBAction)nextWeek:(id)sender {
    self.dateOfWeek = [self.dateOfWeek dateByAddingTimeInterval:((7) * SECS_PER_DAY)];
    [self buildLineTable];
    [self initPlot];
}

- (IBAction)previousWeek:(id)sender {
    self.dateOfWeek = [self.dateOfWeek dateByAddingTimeInterval:((-7) * SECS_PER_DAY)];
    [self buildLineTable];
    [self initPlot];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    {
        self.formatter = [[NSDateFormatter alloc] init];
        [self.formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"MM/dd/yyyy" options:0 locale:[NSLocale currentLocale]]];
    }
    
    self.employeeHours = [[NSMutableArray alloc] init];
    self.jiraHours = [[NSMutableArray alloc] init];
    self.employeeNameHeader.title = self.nameOfEmployee;
    self.dateOfWeek = [self getPreviousSaturday];
    [self buildLineTable];
    self.hostView = [[CPTGraphHostingView alloc] initWithFrame:self.subView.bounds];
    [self.subView addSubview:self.hostView];
}

- (void)buildJiraTimeArray
{
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
                NSDictionary *json = (NSDictionary*)responseObject;
                long timespent = 0;
                for (NSDictionary *worklog in [json objectForKey:@"worklogs"]) {
                    id name = [[worklog objectForKey:@"updateAuthor"] objectForKey:@"name"];
                    if (![name caseInsensitiveCompare:weakSelf.nameOfEmployee]) {
                        id timeSpentSeconds = [worklog objectForKey:@"timeSpentSeconds"];
                        timespent += [timeSpentSeconds longValue];
                    }
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)buildLineTable
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [self.dateLabel setText:[NSString stringWithFormat:@"Week of %@", [self.formatter stringFromDate:self.dateOfWeek]]];
    __weak typeof (self) weakSelf = self;
    
    LCLineChartData *d1x = [LCLineChartData new];
    {
        LCLineChartData *d1 = d1x;
        
        NSDate *endOfWeek = [weakSelf.dateOfWeek dateByAddingTimeInterval:((6) * SECS_PER_DAY)];
        d1.xMin = [weakSelf.dateOfWeek timeIntervalSinceDate:weakSelf.dateOfWeek];
        d1.xMax = [endOfWeek timeIntervalSinceDate:weakSelf.dateOfWeek];
        d1.title = @"Default Time Line";
        d1.color = [UIColor redColor];
        d1.itemCount = 7;
        NSMutableArray *arr = [weakSelf buildDatesArray:d1];
        
        
        NSMutableArray *arr2 = [NSMutableArray array];
        for(NSUInteger i = 0; i < 7; ++i) {
            if(i != 0){
                //Setting two zero's at the beginning of the week due to Saturday and Sunday.
                [arr2 addObject:@((i-1)*8)];
            }else{
                [arr2 addObject:@(0)];
            }
            
        }
        [weakSelf buildTableLine:weakSelf.dateOfWeek arr2:arr2 arr:arr d1:d1];
    }
    
    LCLineChartData *d2x = [LCLineChartData new];
    {
        LCLineChartData *d1 = d2x;
        NSDate *endOfWeek = [weakSelf.dateOfWeek dateByAddingTimeInterval:((6) * SECS_PER_DAY)];
        d1.xMin = [weakSelf.dateOfWeek timeIntervalSinceDate:weakSelf.dateOfWeek];
        d1.xMax = [endOfWeek timeIntervalSinceDate:weakSelf.dateOfWeek];
        d1.title = @"Actual Time Line";
        d1.color = [UIColor blueColor];
        d1.itemCount = 7;
        NSMutableArray *arr = [weakSelf buildDatesArray:d1];
        
        NSMutableArray *arr2 = [NSMutableArray array];
        
        [manager GET:@"http://localhost:8080/service/log/timetracker/v1/60" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            float total = 0.0;
            NSLog(@"JSON: %@", responseObject);
            NSDictionary *json = (NSDictionary*)responseObject;
            for (NSDictionary *employees in json) {
                NSString *employeeName = [employees objectForKey:@"ContactID"];
                if([employeeName isEqualToString:weakSelf.nameOfEmployee]){
                    NSDictionary *hours = [employees objectForKey:@"Hours"];
                    for( int i = 0; i < [hours count]; i++){
                        NSNumber *time = [hours valueForKey:[[NSNumber numberWithInt:i] stringValue]];
                        [weakSelf.employeeHours addObject:time];
                        total = total + [time floatValue];
                        [arr2 addObject:[NSNumber numberWithFloat:total]];
                    }
                    break;
                }
            }
            weakSelf.totalTime = [NSNumber numberWithFloat:total];
            [weakSelf buildTableLine:weakSelf.dateOfWeek arr2:arr2 arr:arr d1:d1];
            
            LCLineChartView *chartView = [[LCLineChartView alloc] initWithFrame:CGRectMake(200, 150, 500, 300)];
            chartView.yMin = 0;
            chartView.yMax = 56;
            chartView.ySteps = @[@"0",@"8",@"16",@"24",@"32",@"40",@"48",@"56"];
            chartView.xStepsCount = 7;
            chartView.data = @[d1x,d2x];
            
            [weakSelf.view addSubview:chartView];
            [weakSelf initPlot];
            [weakSelf drawCircleWithColorFill:[weakSelf getColorForStatusCircle]];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
}

- (NSMutableArray *)buildDatesArray:(LCLineChartData *)d1
{
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObject:@(d1.xMin)];
    for(NSUInteger i = 1; i < 6; ++i) {
        [arr addObject:@(d1.xMin + (SECS_PER_DAY*(i)))];
    }
    [arr addObject:@(d1.xMax)];
    return arr;
}

- (NSDate *)getPreviousSaturday
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    int weekday = [comps weekday];
    NSDate *lastSaturday = [[NSDate date] dateByAddingTimeInterval:-3600*24*(weekday)];
    return lastSaturday;
}

- (void)buildTableLine:(NSDate *)lastSaturday arr2:(NSMutableArray *)arr2 arr:(NSMutableArray *)arr d1:(LCLineChartData *)d1
{
    d1.getData = ^(NSUInteger item) {
        float x = [arr[item] floatValue];
        float y = [arr2[item] floatValue];
        NSString *label1 = [self.formatter stringFromDate:[lastSaturday dateByAddingTimeInterval:x]];
        NSString *label2 = [NSString stringWithFormat:@"%f", y];
        return [LCLineChartDataItem dataItemWithX:x y:y xLabel:label1 dataLabel:label2];
    };
}

-(void)drawCircleWithColorFill:(UIColor *)color
{
    CAShapeLayer *shapeView = [[CAShapeLayer alloc] init];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(60, 180, 100, 100)];
    shapeView.strokeColor = color.CGColor;
    shapeView.fillColor =   color.CGColor;
    [shapeView setPath:path.CGPath];
    [[self.view layer] addSublayer:shapeView];
    
}

-(UIColor *)getColorForStatusCircle
{
    UIColor *backgroundColor = [[UIColor alloc] init];
    if([self.totalTime longValue] < 40){
        backgroundColor = [UIColor redColor];
    }else{
        backgroundColor = [UIColor greenColor];
    }
    return backgroundColor;
}


#pragma mark - Chart behavior
-(void)initPlot {
    self.hostView.allowPinchScaling = NO;
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureGraph {
	// 1 - Create the graph
	CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
	graph.plotAreaFrame.masksToBorder = NO;
	self.hostView.hostedGraph = graph;
	// 2 - Configure the graph
	[graph applyTheme:[CPTTheme themeNamed:kCPTPlainBlackTheme]];
    graph.paddingBottom = 80.0f;
	graph.paddingLeft  = 40.0f;
	graph.paddingTop    = -1.0f;
	graph.paddingRight  = -5.0f;

	// 3 - Set up styles
	CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
	titleStyle.color = [CPTColor whiteColor];
	titleStyle.fontName = @"Helvetica-Bold";
	titleStyle.fontSize = 16.0f;
	// 4 - Set up title
	NSString *title = [NSString stringWithFormat:@"Time for the week of: %@", [self.formatter stringFromDate:self.dateOfWeek]];
	graph.title = title;
	graph.titleTextStyle = titleStyle;
	graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	graph.titleDisplacement = CGPointMake(0.0f, -16.0f);
	// 5 - Set up plot space
	CGFloat xMin = 0.0f;
	CGFloat xMax = 7.0f;
	CGFloat yMin = 0.0f;
	CGFloat yMax = 16.0f;
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];
}

-(void)configurePlots {
	// 1 - Set up the three plots
	self.timeTrackerPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor greenColor] horizontalBars:NO];
	self.timeTrackerPlot.identifier = @"time";
    self.timeTrackerPlot.title = @"TimeTracker";
    self.jiraPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
	self.jiraPlot.identifier = @"jira";
    self.jiraPlot.title = @"Jira";
	// 2 - Set up line style
	CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
	barLineStyle.lineColor = [CPTColor lightGrayColor];
	barLineStyle.lineWidth = 0.5;
	// 3 - Add plots to graph
	CPTGraph *graph = self.hostView.hostedGraph;
	CGFloat barX = CPDBarInitialX;
	NSArray *plots = [NSArray arrayWithObjects:self.timeTrackerPlot, self.jiraPlot, nil];
	for (CPTBarPlot *plot in plots) {
		plot.dataSource = self;
		plot.delegate = self;
		plot.barWidth = CPTDecimalFromDouble(CPDBarWidth);
		plot.barOffset = CPTDecimalFromDouble(barX);
		plot.lineStyle = barLineStyle;
        if([plot.identifier isEqual:@"time"]){
            plot.title = @"TimeTracker";
        }else{
            plot.title = @"Jira";
        }
        

		[graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
		barX += CPDBarWidth;
	}
    
    CPTMutableTextStyle *legendTextStyle = [CPTTextStyle textStyle];
    legendTextStyle.color = [CPTColor whiteColor];
    
    CPTLegend *legend = [CPTLegend legendWithGraph:graph];

    legend.numberOfRows    = 1;
    legend.numberOfColumns = 2;
    legend.fill  = [CPTFill fillWithColor:[CPTColor colorWithGenericGray:0.15]];
    legend.textStyle = legendTextStyle;
    
    legend.cornerRadius    = 10.0;
    legend.swatchSize      = CGSizeMake(15, 15);
    legend.rowMargin       = 10.0;
    legend.paddingLeft     = 10.0;
    legend.paddingTop      = 10.0;
    legend.paddingRight    = 10.0;
    legend.paddingBottom   = 10.0;
    legend.delegate = self;
    
    graph.legend = legend;
}

-(void)configureAxes {
	// 1 - Configure styles
	CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
	axisTitleStyle.color = [CPTColor whiteColor];
	axisTitleStyle.fontName = @"Helvetica-Bold";
	axisTitleStyle.fontSize = 12.0f;
	CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
	axisLineStyle.lineWidth = 2.0f;
	axisLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:1];
	// 2 - Get the graph's axis set
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
	// 3 - Configure the x-axis
	axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;

    NSArray *customTickLocations = [NSArray arrayWithObjects:[NSDecimalNumber numberWithFloat:.4],
                                    [NSDecimalNumber numberWithFloat:1.4],
                                    [NSDecimalNumber numberWithFloat:2.4],
                                    [NSDecimalNumber numberWithFloat:3.4],
                                    [NSDecimalNumber numberWithFloat:4.4],
                                    [NSDecimalNumber numberWithFloat:5.4],
                                    [NSDecimalNumber numberWithFloat:6.4],
                                    nil];
    NSArray *xAxisLabels = [NSArray arrayWithObjects:@"Sat", @"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", nil];
    NSUInteger labelLocation = 0;
    NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[xAxisLabels count]];
    for (NSNumber *tickLocation in customTickLocations) {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText: [xAxisLabels objectAtIndex:labelLocation++] textStyle:axisSet.xAxis.labelTextStyle];
        newLabel.tickLocation = [tickLocation decimalValue];
        [customLabels addObject:newLabel];
    }
    
    axisSet.xAxis.axisLabels =  [NSSet setWithArray:customLabels];
	axisSet.xAxis.axisLineStyle = axisLineStyle;
	// 4 - Configure the y-axis
	axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
	axisSet.yAxis.title = @"Hours";
	axisSet.yAxis.titleTextStyle = axisTitleStyle;
	axisSet.yAxis.titleOffset = 5.0f;
	axisSet.yAxis.axisLineStyle = axisLineStyle;
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
	return 7;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	if ((fieldEnum == CPTBarPlotFieldBarTip) && (index < 7)) {
        if ([plot.identifier isEqual:@"time"]) {
            //for 0 time: set time to .1 to display a small section of the bar.
            return ([[self.employeeHours objectAtIndex:index] integerValue] > 0 ? [self.employeeHours objectAtIndex:index] : [NSNumber numberWithFloat:0.1]);
        }
        else{
            return ([[self.employeeHours objectAtIndex:index] integerValue] > 0 ? [NSNumber numberWithInt:([[self.employeeHours objectAtIndex:index] integerValue]-2)] : [NSNumber numberWithFloat:0.1]);
        }
	}
	return [NSDecimalNumber numberWithUnsignedInteger:index];
}

#pragma mark - CPTBarPlotDelegate methods
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index {

	if (plot.isHidden == YES) {
		return;
	}

	static CPTMutableTextStyle *style = nil;
	if (!style) {
		style = [CPTMutableTextStyle textStyle];
		style.color= [CPTColor yellowColor];
		style.fontSize = 16.0f;
		style.fontName = @"Helvetica-Bold";
	}

	static NSNumberFormatter *formatter = nil;
	if (!formatter) {
		formatter = [[NSNumberFormatter alloc] init];
		[formatter setMaximumFractionDigits:2];
	}

}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    JiraTableViewController *jtvc = [segue destinationViewController];
    [jtvc setNameOfEmployee:[self.nameOfEmployee stringByReplacingOccurrencesOfString:@" " withString:@"."]];
    [jtvc setDateOfWeek:self.dateOfWeek];
}


@end
