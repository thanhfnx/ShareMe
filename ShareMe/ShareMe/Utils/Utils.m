//
//  Utils.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/26/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "Utils.h"
#import "NSDate+TimeDiff.h"
#import "FDateFormatter.h"

NSString *const kDateFormat = @"d MMM yy";
NSString *const kDefaultDateTimeFormat = @"yyyy-MM-dd HH:mm:ss";
NSString *const kDefaultMaleAvatar = @"default-male-avatar";
NSString *const kDefaultFemaleAvatar = @"default-female-avatar";
CGFloat const kSquareImageRatio = 1.0f;
CGFloat const kLandscapeImageRatio = 16.0f / 9.0f;
CGFloat const kPortraitImageRatio = 9.0f / 16.0f;
CGFloat const kLongWidthImageRatio = 2.0f;
CGFloat const kLongHeightImageRatio = 0.5f;

@implementation Utils

+ (UIImage *)getAvatar:(NSString *)imageString gender:(BOOL)gender {
    if (imageString.length) {
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:imageString
            options:NSDataBase64DecodingIgnoreUnknownCharacters];
        return [UIImage imageWithData:imageData];
    }
    if (gender) {
        return [UIImage imageNamed:kDefaultMaleAvatar];
    } else {
        return [UIImage imageNamed:kDefaultMaleAvatar];
    }
}

+ (UIImage *)resize:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f);
    [image drawInRect:CGRectMake(0.0f, 0.0f, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSString *)stringfromNumber:(NSUInteger)number {
    switch (number) {
        case 1 ... 999:
            return [@(number) stringValue];
        case 1000 ... 9999:
            return [NSString stringWithFormat:@"%.1fk", number / 1000.0];
        case 10000 ... 999999:
            return [NSString stringWithFormat:@"%ldk", number / 1000];
        case 1000000 ... 9999999:
            return [NSString stringWithFormat:@"%.1fm", number / 1000000.0];
        case 10000000 ... 999999999:
            return [NSString stringWithFormat:@"%ldm", number / 1000000];
        case 1000000000 ... NSUIntegerMax:
            return [NSString stringWithFormat:@"%ldb", number / 1000000000];
    }
    return @"";
}

+ (NSString *)timeDiffFromDate:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [FDateFormatter sharedDateFormatter];
    dateFormatter.dateFormat = kDefaultDateTimeFormat;
    NSDate *date = [dateFormatter dateFromString:dateString];
    NSDate *today = [NSDate date];
    NSInteger minutes = [today timeDiffFromDate:date unit:NSCalendarUnitMinute].minute;
    if (minutes == 0) {
        return @"just now";
    } else if (minutes < 60) {
        return [NSString stringWithFormat:@"%ldm", minutes];
    }
    NSInteger hours = [today timeDiffFromDate:date unit:NSCalendarUnitHour].hour;
    if (hours > 0 && hours < 24) {
        return [NSString stringWithFormat:@"%ldh", hours];
    }
    NSInteger days = [today timeDiffFromDate:date unit:NSCalendarUnitDay].day;
    if (days > 0 && days < 7) {
        return [NSString stringWithFormat:@"%ldd", days];
    }
    dateFormatter.dateFormat = kDateFormat;
    return [dateFormatter stringFromDate:date];
}

+ (UIImage *)decodeBase64String:(NSString *)base64String {
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64String
        options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:imageData];
}

+ (ImageType)getImageType:(CGSize)size {
    float ratio = size.width / size.height;
    if (ratio > kLongWidthImageRatio) {
        return ImageTypeLongWidth;
    } else if (ratio > (kSquareImageRatio + kLandscapeImageRatio) / 2) {
        return ImageTypeLandscape;
    } else if (ratio > (kSquareImageRatio + kPortraitImageRatio) / 2) {
        return ImageTypeSquare;
    } else if (ratio >= kLongHeightImageRatio) {
        return ImageTypePortrait;
    } else {
        return ImageTypeLongHeight;
    }
}

@end
