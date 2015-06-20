//
//  SignUpViewController.h
//  dhelper3
//
//  Created by Neo on 6/20/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BossSignUpViewController : UIViewController {
    IBOutlet UIActivityIndicatorView *actIndicatorViewMain;
    IBOutlet UITextField *txtFldUsername;
    IBOutlet UITextField *txtFldPassword;
    IBOutlet UITextField *txtFldHousehold;
    IBOutlet UITextField *txtFldName;
    IBOutlet UIButton *btnSignUp;
    
    IBOutlet UILabel* lblAdult;
    IBOutlet UILabel* lblChild;
    IBOutlet UILabel* lblMeal;
    
    IBOutlet UISlider* sdrAdult;
    IBOutlet UISlider* sdrChild;
    IBOutlet UISlider* sdlMeal;
}

-(IBAction) signUp:(id) sender;



@end
