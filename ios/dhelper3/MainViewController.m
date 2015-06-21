//
//  MainViewController.m
//  dhelper3
//
//  Created by Neo on 6/20/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import "MainViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface MainViewController ()

@end

@implementation MainViewController

-(void)showError:(NSString*) error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                message:error
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)viewDidLoad {
    
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

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Users"];
    [query whereKey:@"username" equalTo:txtFldUsername.text];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count == 0) {
                [self showError:@"User not found"];
            } else {
                PFObject* obj = (PFObject*)[objects objectAtIndex:0];
                appDelegate.userId = obj.objectId;
                appDelegate.householdId = ((PFObject*)obj[@"parent"]).objectId;
                appDelegate.isBoss = [@"employer" compare:obj[@"type"]] == 0;
                NSLog(@"%@, %d", obj, appDelegate.isBoss);
                [self performSegueWithIdentifier:(appDelegate.isBoss) ? @"LoginAsBoss" : @"LoginAsHelper" sender:nil];
            }
            [actIndicatorViewMain stopAnimating];
        } else {
            [actIndicatorViewMain stopAnimating];
            [self showError:[error description]];
        }
    }];

    
}

-(void)textFieldDidChange:(UITextField *)textField {
    btnLogin.enabled = ([txtFldUsername.text length] > 0 && [txtFldPassword.text length] > 0);
}

@end
