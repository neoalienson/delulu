//
//  HelperViewController.m
//  dhelper3
//
//  Created by Neo on 6/20/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import "HelperViewController.h"
#import <Parse/Parse.h>
#import "HelperNewExpenseViewController.h"

@interface HelperViewController ()

@end

@implementation HelperViewController

- (void)loadData {
    NSLog(@"loading data");
    self.arrayRecent = [NSMutableArray new];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Ledger"];
    [query whereKey:@"household" equalTo:[PFObject objectWithoutDataWithClassName:@"Household" objectId:@"rLooCSzCeV"]];
    [query orderByDescending:@"date"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // Do something with the found objects
            float balance = 0;
            for (PFObject *obj in objects) {
                [self.arrayRecent addObject:obj];
                if ([@"expense" compare:obj[@"type"]] == 0) {
                    balance -= [(NSNumber*) obj[@"amount"] floatValue];
                } else {
                    balance += [(NSNumber*) obj[@"amount"] floatValue];
                }
            }
            
            lblBalance.text = [NSString stringWithFormat:@"Balance: HKD %.2f", balance];
            lblBalance.textColor = (balance >= 0) ? [UIColor blackColor] : [UIColor redColor];
            [tableViewRecent reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    HelperNewExpenseViewController *viewController = (HelperNewExpenseViewController *)[segue destinationViewController];
    viewController.parent = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayRecent.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HelperViewRecentRow"];
    
    PFObject* obj = (PFObject*)[self.arrayRecent objectAtIndex:indexPath.row];
    NSDate* date = (NSDate*)obj[@"date"];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd-MM-yyyy"];

    // Configure Cell
    UIImageView *img = (UIImageView*)[cell.contentView viewWithTag:10];
    img.image = [UIImage imageNamed:([@"deposit" compare:obj[@"type"]] == 0) ?
                 @"transaction" : @"shopping"];
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:20];
    [label setText:[NSString stringWithFormat:@"%@",  [format stringFromDate:date]]];
    
    label = (UILabel *)[cell.contentView viewWithTag:40];
    [label setText:(NSString*)obj[@"description"]];
    
    label = (UILabel *)[cell.contentView viewWithTag:30];
    [label setText:[NSString stringWithFormat:@"HKD %.2f", [(NSNumber*)obj[@"amount"] floatValue]]];

    return cell;
}

@end
