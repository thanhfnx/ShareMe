//
//  FLabel.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/28/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "FLabel.h"

@implementation FLabel

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = UIEdgeInsetsMake(8.0f, 8.0f, 8.0f, 8.0f);
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
