//
//  BossViewController.m
//  dhelper3
//
//  Created by Neo on 6/20/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import "BossViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "BossHelperViewController.h"

@interface BossViewController ()

@end

@implementation BossViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self->viewHelpers.alpha = 0;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.arrayHelper = [NSMutableArray new];

    PFQuery *query = [PFQuery queryWithClassName:@"Users"];
    [query whereKey:@"parent" equalTo:[PFObject objectWithoutDataWithClassName:@"Household" objectId:appDelegate.householdId]];
    [query whereKey:@"type" equalTo:@"helper"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                [self.arrayHelper addObject:object];
            }
            
            [self->tableViewRecent reloadData];
            
            if (objects.count > 0) {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                viewHelpers.alpha = 1;
                [UIView commitAnimations];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BossRowCell"];
    
    PFObject* obj = (PFObject*)[self.arrayHelper objectAtIndex:indexPath.row];

    cell.restorationIdentifier = obj.objectId;

    UILabel *label = (UILabel *)[cell.contentView viewWithTag:10];
    [label setText:(NSString*)obj[@"name"]];

    label = (UILabel *)[cell.contentView viewWithTag:20];
    [label setText:[NSString stringWithFormat:@"HKD %.2f", [(NSNumber*)obj[@"balance"] floatValue]]];
        
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"BossHelperView"]) {
        BossHelperViewController *vc = (BossHelperViewController *)[segue destinationViewController];
        NSIndexPath* idx = [tableViewRecent indexPathForSelectedRow];
        PFObject* obj = (PFObject*)[self.arrayHelper objectAtIndex:idx.row];
        vc.helperId = obj.objectId;
        vc.name = obj[@"name"];
        NSLog(@"%@", vc.helperId);
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"BossHelperView" sender:nil];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.arrayHelper.count;
}

@end
