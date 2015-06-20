//
//  HelperSignUpViewController.m
//  dhelper3
//
//  Created by Neo on 6/20/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import "HelperSignUpViewController.h"
#import <Parse/Parse.h>

@interface HelperSignUpViewController ()

@end

@implementation HelperSignUpViewController


-(IBAction) signUp:(id) sender {
    
    [actIndicatorViewMain startAnimating];
    
    PFObject *row = [PFObject objectWithClassName:@"User"];
    row[@"username"] = self->txtFldUsername;
    row[@"password"] = self->txtFldPassword;
    row[@"type"] = @"helper";
    
    [row saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [actIndicatorViewMain stopAnimating];
        if (succeeded) {
            [self performSegueWithIdentifier:@"Login" sender:nil];
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
