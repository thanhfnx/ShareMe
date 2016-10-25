//
//  Utils.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/26/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QBImagePickerController/QBImagePickerController.h>

@class User;

typedef NS_ENUM(NSInteger, ImageType) {
    ImageTypeSquare,
    ImageTypePortrait,
    ImageTypeLandscape,
    ImageTypeLongWidth,
    ImageTypeLongHeight
};

@interface Utils : NSObject

+ (UIImage *)getAvatar:(NSMutableArray *)imageString gender:(NSNumber *)gender;
+ (UIImage *)resize:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)getUIImageFromAsset:(PHAsset *)asset maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight;
+ (NSString *)stringfromNumber:(NSUInteger)number;
+ (NSString *)timeDiffFromDate:(NSString *)dateString;
+ (UIImage *)decodeBase64String:(NSString *)base64String;
+ (ImageType)getImageType:(CGSize)size;
+ (void)addUserIfNotExist:(NSMutableArray *)array user:(User *)user;
+ (void)removeUser:(NSMutableArray *)array user:(User *)user;
+ (UITableViewCell *)emptyTableCell:(NSString *)message;
+ (void)showLocalNotification:(NSString *)alertBody userInfo:(NSDictionary *)userInfo;
+ (void)setApplicationBadge:(BOOL)isIncrease;
+ (NSString *)sentTimeFromDate:(NSString *)dateString withDetail:(BOOL)withDetail;

@end
