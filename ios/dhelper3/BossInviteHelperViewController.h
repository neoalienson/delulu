//
//  BossInviteHelperViewController.h
//  dhelper3
//
//  Created by Neo on 6/20/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BossInviteHelperViewController : UIViewController {
    IBOutlet UITextView *textViewDetails;
}

-(IBAction) copyToClipboard:(id) sender;

@end
