//
//  HelperViewController.m
//  dhelper3
//
//  Created by Neo on 6/20/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import "HelperViewController.h"
#import <Parse/Parse.h>

@interface HelperViewController ()

@end

@implementation HelperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrayRecent = [NSMutableArray new];

    PFQuery *query = [PFQuery queryWithClassName:@"Ledger"];
    [query whereKey:@"household" equalTo:[PFObject objectWithoutDataWithClassName:@"Household" objectId:@"rLooCSzCeV"]];
    [query whereKey:@"type" equalTo:@"expense"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // Do something with the found objects
            for (PFObject *object in objects) {
                [self.arrayRecent addObject:object];
            }
            [tableViewRecent reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayRecent.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HelperViewRecentRow"];
    
    PFObject* obj = (PFObject*)[self.arrayRecent objectAtIndex:indexPath.row];
    NSDate* date = (NSDate*)obj[@"date"];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd-MM-yyyy HH:mm"];

    // Configure Cell
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:20];
    [label setText:[NSString stringWithFormat:@"%@",  [format stringFromDate:date]]];
    
    return cell;
}

@end
