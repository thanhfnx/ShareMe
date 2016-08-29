//
//  UIViewConstant.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/25/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "UIViewConstant.h"

@implementation UIColor (Extentions)

+ (UIColor *)defaultThemeColor {
    static UIColor *color = nil;
    if (!color) {
        color = [UIColor colorWithRed:0.0f / 255.0f green:172.0f / 255.0f blue:237.0f /255.0f alpha:1.0f];
    }
    return color;
}

@end

@implementation UIViewConstant

NSString *const kDefaultFontName = @"Helvetica-Light";

@end
