//
//  UIViewConstant.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/25/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Extentions)

+ (UIColor *)defaultThemeColor;

@end

@interface UIViewConstant : NSObject

extern NSString *const kDefaultFontName;

+ (CGFloat)screenScale;
+ (CGFloat)screenWidth;

@end
