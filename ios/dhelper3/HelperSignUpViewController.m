//
//  HelperSignUpViewController.m
//  dhelper3
//
//  Created by Neo on 6/20/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import "HelperSignUpViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface HelperSignUpViewController ()

@end

@implementation HelperSignUpViewController

-(void)viewDidLoad {
    txtFldName.placeholder = @"  Your name";
    txtFldUsername.placeholder = @"  Username";
    txtFldPassword.placeholder = @"  Password";

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Household"];
    
    appDelegate.householdId = @"adoCJNucQR";
    
    [query getObjectInBackgroundWithId:appDelegate.householdId block:^(PFObject *household, NSError *error) {
        self->lblWelcome.text = [NSString stringWithFormat:@"Welcome to %@", household[@"name"]];
    }];
    
}

-(void)viewDidAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden  = false;
}

-(IBAction) signUp:(id) sender {
    
    [actIndicatorViewMain startAnimating];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    PFObject *row = [PFObject objectWithClassName:@"Users"];
    row[@"username"] = self->txtFldUsername.text;
    row[@"password"] = self->txtFldPassword.text;
    row[@"name"] = self->txtFldName.text;
    row[@"type"] = @"helper";
    row[@"parent"] = [PFObject objectWithoutDataWithClassName:@"Household" objectId:appDelegate.householdId];
    
    [row saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [actIndicatorViewMain stopAnimating];
        if (succeeded) {
            [appDelegate setIsBoss:FALSE];

            appDelegate.userId = row.objectId;
            [self performSegueWithIdentifier:@"SignUpComplete" sender:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Fail to create user"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        NSLog(@"login result: %i", succeeded);
    }];
}


@end
