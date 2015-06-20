//
//  MainViewController.m
//  dhelper3
//
//  Created by Neo on 6/20/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import "MainViewController.h"
#import <Parse/Parse.h>

@interface MainViewController ()

@end

@implementation MainViewController

-(void)viewDidLoad {
    /*
    PFQuery *q1 = [PFQuery queryWithClassName:@"Household"];
    [q1 getObjectInBackgroundWithId:@"rLooCSzCeV" block:^(PFObject *gameScore, NSError *error) {
        // Do something with the returned PFObject in the gameScore variable.
        NSLog(@"%@", gameScore);
    }];
     */

    /*
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query getObjectInBackgroundWithId:@"2QOgczQtHp" block:^(PFObject *gameScore, NSError *error) {
    }];
     */
    PFQuery *query = [PFQuery queryWithClassName:@"Users"];
    [query whereKey:@"parent" equalTo:[PFObject objectWithoutDataWithClassName:@"Household" objectId:@"rLooCSzCeV"]];
    [query whereKey:@"type" equalTo:@"helper"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    [txtFldUsername addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [txtFldPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    txtFldUsername.placeholder = @"  Username";
    txtFldPassword.placeholder = @"  Password";
    
    imgWelcome.alpha = 0;
    imgOut1.alpha = 0;
    imgOut2.alpha = 0;
    imgPaper.alpha = 0;
    imgPaper.transform = CGAffineTransformMakeTranslation(0, -95);
    viewLogin.transform = CGAffineTransformMakeTranslation(412, 0);
}

-(void)viewDidAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden  = true;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    imgWelcome.alpha = 1;
    
    imgOut1.alpha = 1;
    imgOut2.alpha = 1;
    imgPaper.alpha = 1;

    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay: 1.0];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
    imgPaper.transform = CGAffineTransformMakeTranslation(0, 0);

    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay: 1.5];
    viewLogin.transform = CGAffineTransformMakeTranslation(0, 0);
    [UIView commitAnimations];

}


-(IBAction) login:(id) sender {
    [actIndicatorViewMain startAnimating];

    // validation
    [self performSegueWithIdentifier:@"Login" sender:nil];
    
}

-(void)textFieldDidChange:(UITextField *)textField {
    btnLogin.enabled = ([txtFldUsername.text length] > 0 && [txtFldPassword.text length] > 0);
}

@end
