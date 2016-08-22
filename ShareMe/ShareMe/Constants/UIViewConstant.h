//
//  UIViewConstant.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/22/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Extensions)

+ (UIColor *)defaultThemeColor;

@end

@interface UIViewConstant : NSObject

extern NSString *const kDefaultFontName;
extern NSString *const kDefaultFontNameThin;

@end
