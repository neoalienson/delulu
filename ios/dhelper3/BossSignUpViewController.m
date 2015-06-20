//
//  SignUpViewController.m
//  dhelper3
//
//  Created by Neo on 6/20/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import "BossSignUpViewController.h"
#import <Parse/Parse.h>

@interface BossSignUpViewController ()

@end

@implementation BossSignUpViewController

-(IBAction) signUp:(id) sender {

    [actIndicatorViewMain startAnimating];

    PFObject *row = [PFObject objectWithClassName:@"Household"];
    row[@"name"] = self->txtFldUsername;
    
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

//    [self.navigationController popViewControllerAnimated:true];
}

@end
