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

-(IBAction) login:(id) sender {
    [actIndicatorViewMain startAnimating];

    // validation
    [self performSegueWithIdentifier:@"Login" sender:nil];
    
}

@end
