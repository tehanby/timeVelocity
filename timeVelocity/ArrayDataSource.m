//
//  ArrayDataSource.m
//  timeVelocity
//
//  Created by Tim Hanby on 3/14/14.
//  Copyright (c) 2014 Timothy Hanby. All rights reserved.
//

#import "ArrayDataSource.h"


@interface ArrayDataSource ()
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) TableViewCellConfigureBlock configureCellBlock;
@end

@implementation ArrayDataSource

- (id)initWithArray:(NSMutableArray *)aTableArray
     cellIdentifier:(NSString *)aCellIdentifier
 configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock
{
    self = [super init];
    if (self) {
        self.tableArray = aTableArray;
        self.cellIdentifier = aCellIdentifier;
        self.configureCellBlock = [aConfigureCellBlock copy];
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableArray count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
    }
    
    NSString *name = [self.tableArray objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:name];
    return cell;
}

@end

