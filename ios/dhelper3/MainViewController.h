//
//  MainViewController.h
//  dhelper3
//
//  Created by Neo on 6/20/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UITextFieldDelegate> {
    IBOutlet UIActivityIndicatorView *actIndicatorViewMain;
    IBOutlet UIButton *btnLogin;
    IBOutlet UIView *viewLogin;
    IBOutlet UITextField *txtFldUsername;
    IBOutlet UITextField *txtFldPassword;
        
    IBOutlet UIImageView *imgWelcome;
    IBOutlet UIImageView *imgOut1;
    IBOutlet UIImageView *imgOut2;
    IBOutlet UIImageView *imgPaper;
}

-(IBAction) login:(id) sender;
-(void)textFieldDidChange:(UITextField *)textField;

@end
