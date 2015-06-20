//
//  HelperNewExpenseViewController.m
//  dhelper3
//
//  Created by Neo on 6/20/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import "HelperNewExpenseViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface HelperNewExpenseViewController ()

@end

@implementation HelperNewExpenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    txtFldCost.placeholder = @"Amount in HKD";
    txtFldDescription.placeholder = @"Description";
}

-(void) clearFocus {
    [txtFldCost resignFirstResponder];
    [txtFldDescription resignFirstResponder];
}

-(IBAction)dateIsChanged:(UIDatePicker*)sender{
    [self clearFocus];
}

-(void)showError:(NSError*)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Fail to create user"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}


-(IBAction)create:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [actIndicatorViewMain startAnimating];
    
    PFObject *row2 = [PFObject objectWithClassName:@"Ledger"];
    NSNumber* amount = [NSNumber numberWithInt:[self->txtFldCost.text intValue]];
    row2[@"amount"] = amount;
    row2[@"description"] = self->txtFldDescription.text;
    row2[@"household"] = [PFObject objectWithoutDataWithClassName:@"Household" objectId:appDelegate.householdId];
    row2[@"createdBy"] = [PFObject objectWithoutDataWithClassName:@"Users" objectId:appDelegate.userId];
    row2[@"type"] = @"expense";
    row2[@"date"] = datePickerDate.date;
    
    [row2 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [actIndicatorViewMain stopAnimating];
        if (succeeded) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self showError:error];
        }
        NSLog(@"login result: %i", succeeded);
    }];

}

-(IBAction)takePhoto:(id)sender {
    self->imgPicker = [[UIImagePickerController alloc] init];
    self->imgPicker.delegate = self;
    self->imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera | UIImagePickerControllerSourceTypePhotoLibrary;
    self->imgPicker.mediaTypes = @[(NSString *) kUTTypeImage];
    self->imgPicker.allowsEditing = TRUE;
    
    [self presentViewController:self->imgPicker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];

    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        
        self->imgTaken.image = info[UIImagePickerControllerEditedImage];
        /*
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        //append filename to document directory url
        NSURL *urlSave = [[self getDocumentsPathURL] URLByAppendingPathComponent:k_IMAGE_NAME];
        
        //do something to previously taken image (in this case: delete it)
        if ([[NSFileManager defaultManager] fileExistsAtPath:urlSave.path]) {
            [[NSFileManager defaultManager] removeItemAtPath:urlSave.path error:nil];
        }
        
        //save image to document directory
        [UIImagePNGRepresentation(image) writeToFile:urlSave.path atomically:YES];
        
        //optional: save image to photo library
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
         */
    }
}

@end
