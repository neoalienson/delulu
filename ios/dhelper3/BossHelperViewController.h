//
//  BossHelperViewController.h
//  dhelper3
//
//  Created by Neo on 6/21/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BossViewController.h"

@interface BossHelperViewController : UIViewController {
    IBOutlet UITableView* tableViewRecent;
    IBOutlet UILabel* lblBalance;
    IBOutlet UITextField* txtFldAmount;
    
}
@property (strong, nonatomic) NSString* helperId;
@property (assign, nonatomic) float balance;
@property (strong, nonatomic) NSMutableArray* arrayRecent;

@end
