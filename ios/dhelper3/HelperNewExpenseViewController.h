//
//  HelperNewExpenseViewController.h
//  dhelper3
//
//  Created by Neo on 6/20/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelperNewExpenseViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    IBOutlet UIActivityIndicatorView *actIndicatorViewMain;
    IBOutlet UITextField* txtFldDescription;
    IBOutlet UITextField* txtFldCost;
    IBOutlet UIDatePicker* datePickerDate;
    IBOutlet UIImageView* imgTaken;
    UIImagePickerController* imgPicker;
}

@end
