//
//  BossInviteHelperViewController.m
//  dhelper3
//
//  Created by Neo on 6/20/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import "BossInviteHelperViewController.h"
#import "AppDelegate.h"

@interface BossInviteHelperViewController ()

@end

@implementation BossInviteHelperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    textViewDetails.text = [NSString stringWithFormat:@"Hi,Please install dhelp from AppStore (http://store.apple.com) or GooglePlay (http://play.google.com/). And then open this link  dhelper://bnc.lt/l/%@]", appDelegate.householdId];
}

-(IBAction) copyToClipboard:(id) sender {
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:[textViewDetails text]];
}

@end
