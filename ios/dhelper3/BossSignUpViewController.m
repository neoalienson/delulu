//
//  SignUpViewController.m
//  dhelper3
//
//  Created by Neo on 6/20/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import "BossSignUpViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface BossSignUpViewController ()

@end

@implementation BossSignUpViewController

-(void)viewDidLoad {
    txtFldUsername.placeholder = @"Username";
    txtFldPassword.placeholder = @"Password";
    txtFldHousehold.placeholder = @"Your household's name, e.g., Chen's family";
    txtFldName.placeholder = @"Your name";
}

-(void)viewDidAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden  = FALSE;
}

-(void)showError:(NSError*)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Fail to create user"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}

-(IBAction) signUp:(id) sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [actIndicatorViewMain startAnimating];

    PFObject *row2 = [PFObject objectWithClassName:@"Household"];
    row2[@"name"] = self->txtFldHousehold.text;
    row2[@"MealPerWeek"] = [NSNumber numberWithFloat:self->sdlMeal.value];
    row2[@"adult"] = [NSNumber numberWithFloat:self->sdrAdult.value];
    row2[@"child"] = [NSNumber numberWithFloat:self->sdrChild.value];
    [row2 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"create user");
        if (succeeded) {
            PFObject *row = [PFObject objectWithClassName:@"Users"];
            row[@"name"] = self->txtFldName.text;
            row[@"username"] = self->txtFldUsername.text;
            row[@"password"] = self->txtFldPassword.text;
            row[@"type"] = @"employer";
            row[@"parent"] = row2;
            appDelegate.isBoss = TRUE;
            appDelegate.householdId = row2.objectId;
            [row saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [actIndicatorViewMain stopAnimating];
                NSLog(@"create household");
                if (succeeded) {
                    appDelegate.userId = row.objectId;
                    [self performSegueWithIdentifier:@"BossSignUpComplete" sender:nil];
                } else {
                    [self showError:error];
                }
            }];
        } else {
            [actIndicatorViewMain stopAnimating];
            [self showError:error];
        }
        NSLog(@"login result: %i", succeeded);
    }];
}

- (void)clearFocus {
    [txtFldName resignFirstResponder];
    [txtFldHousehold resignFirstResponder];
    [txtFldUsername resignFirstResponder];
    [txtFldPassword resignFirstResponder];

}

- (IBAction)adultValueChanged:(UISlider *)sender {
    sender.value = ceil(sender.value);
    lblAdult.text = [NSString stringWithFormat:@"Number of adult: %.0f", sender.value];
    [self clearFocus];
}

- (IBAction)childValueChanged:(UISlider *)sender {
    sender.value = ceil(sender.value);
    lblChild.text = [NSString stringWithFormat:@"Number of baby: %.0f", sender.value];
    [self clearFocus];
}

- (IBAction)mealValueChanged:(UISlider *)sender {
    sender.value = ceil(sender.value * 10) / 10;
    lblMeal.text = [NSString stringWithFormat:@"Number of meal per week (average): %.1f", sender.value];
    [self clearFocus];
}

@end
