//
//  UICustomTextField.m
//  dhelper3
//
//  Created by Neo on 6/20/15.
//  Copyright (c) 2015 dhelper3. All rights reserved.
//

#import <UIKit/UIKit.h>

@implementation UITextField (custom)
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 10, bounds.origin.y + 8,
                      bounds.size.width - 20, bounds.size.height - 16);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}
@end
