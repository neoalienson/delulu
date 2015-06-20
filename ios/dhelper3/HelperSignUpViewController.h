//
//  HelperSignUpViewController.h
//  dhelper3
//
//  Created by Neo on 6/20/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelperSignUpViewController : UIViewController {
    IBOutlet UIActivityIndicatorView *actIndicatorViewMain;
    IBOutlet UITextField *txtFldName;
    IBOutlet UITextField *txtFldUsername;
    IBOutlet UITextField *txtFldPassword;
    IBOutlet UIButton *btnSignUp;
    IBOutlet UILabel *lblWelcome;
}

-(IBAction) signUp:(id) sender;

@end
