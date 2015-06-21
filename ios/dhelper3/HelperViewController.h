//
//  HelperViewController.h
//  dhelper3
//
//  Created by Neo on 6/20/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelperViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView* tableViewRecent;
    IBOutlet UILabel* lblBalance;
}

- (void)loadData;

@property (strong, nonatomic) NSMutableArray *arrayRecent;

@end
