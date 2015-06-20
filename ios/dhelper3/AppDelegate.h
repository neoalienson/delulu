//
//  AppDelegate.h
//  dhelper3
//
//  Created by Neo on 6/20/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *householdId;
@property (assign, nonatomic) BOOL isBoss;
@end

