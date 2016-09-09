//
//  Utils.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/26/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ImageType) {
    ImageTypeSquare,
    ImageTypePortrait,
    ImageTypeLandscape,
    ImageTypeLongWidth,
    ImageTypeLongHeight
};

extern NSString *const kDateFormat;
extern NSString *const kDefaultDateTimeFormat;
extern NSString *const kDefaultMaleAvatar;
extern NSString *const kDefaultFemaleAvatar;
extern CGFloat const kSquareImageRatio;
extern CGFloat const kLandscapeImageRatio;
extern CGFloat const kPortraitImageRatio;
extern CGFloat const kLongWidthImageRatio;
extern CGFloat const kLongHeightImageRatio;

@interface Utils : NSObject

+ (UIImage *)getAvatar:(NSString *)imageString gender:(BOOL)gender;
+ (UIImage *)resize:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (NSString *)stringfromNumber:(NSUInteger)number;
+ (NSString *)timeDiffFromDate:(NSString *)dateString;
+ (UIImage *)decodeBase64String:(NSString *)base64String;
+ (ImageType)getImageType:(CGSize)size;

@end
