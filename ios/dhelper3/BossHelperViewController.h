//
//  BossHelperViewController.h
//  dhelper3
//
//  Created by Neo on 6/21/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BossViewController.h"

@interface BossHelperViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView* tableViewRecent;
    IBOutlet UILabel* lblBalance;
    IBOutlet UILabel* lblOverview;
    IBOutlet UITextField* txtFldAmount;
    IBOutlet UIActivityIndicatorView *actIndicatorViewMain;
    
}
@property (strong, nonatomic) NSString* helperId;
@property (strong, nonatomic) NSString* name;
@property (assign, nonatomic) float balance;
@property (strong, nonatomic) NSMutableArray* arrayRecent;

@end
