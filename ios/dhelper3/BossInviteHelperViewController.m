//
//  BossInviteHelperViewController.m
//  dhelper3
//
//  Created by Neo on 6/20/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import "BossInviteHelperViewController.h"

@interface BossInviteHelperViewController ()

@end

@implementation BossInviteHelperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) copyToClipboard:(id) sender {
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:[textViewDetails text]];
}

@end
