//
//  BossHelperViewController.m
//  dhelper3
//
//  Created by Neo on 6/21/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import "BossHelperViewController.h"
#import <Parse/Parse.h>

@interface BossHelperViewController ()

@end

@implementation BossHelperViewController

-(void)updateBalance {
    lblBalance.text = [NSString stringWithFormat:@"Balance: HKD %.2f", self.balance];
    lblBalance.textColor = (self.balance > 0) ? [UIColor blackColor] : [UIColor redColor];
}

- (void)loadData {
    NSLog(@"loading data");
    self.arrayRecent = [NSMutableArray new];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Ledger"];
    [query whereKey:@"createdBy" equalTo:[PFObject objectWithoutDataWithClassName:@"Users" objectId:self.helperId]];
    [query orderByDescending:@"date"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"loaded %lu:", (unsigned long)objects.count);
            self.balance = 0;
            for (PFObject *obj in objects) {
                [self.arrayRecent addObject:obj];
                if ([@"expense" compare:obj[@"type"]] == 0) {
                    self.balance -= [(NSNumber*) obj[@"amount"] floatValue];
                } else {
                    self.balance += [(NSNumber*) obj[@"amount"] floatValue];
                }
            }
            
            [self updateBalance];
            [tableViewRecent reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    HelperNewExpenseViewController *viewController = (HelperNewExpenseViewController *)[segue destinationViewController];
//    viewController.parent = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayRecent.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HelperDetailsRecentRow"];
    
    PFObject* obj = (PFObject*)[self.arrayRecent objectAtIndex:indexPath.row];
    NSDate* date = (NSDate*)obj[@"date"];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd-MM-yyyy"];
    
    // Configure Cell
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:20];
    [label setText:[NSString stringWithFormat:@"%@",  [format stringFromDate:date]]];
    
    label = (UILabel *)[cell.contentView viewWithTag:40];
    [label setText:(NSString*)obj[@"description"]];
    
    label = (UILabel *)[cell.contentView viewWithTag:30];
    [label setText:[NSString stringWithFormat:@"HKD %.2f", [(NSNumber*)obj[@"amount"] floatValue]]];
    
    return cell;
}

-(IBAction)deposit:(id)sender {
    [self updateBalance];
}

@end
