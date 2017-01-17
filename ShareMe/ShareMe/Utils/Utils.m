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
#import "User.h"
#import "UIViewConstant.h"
#import "ApplicationConstants.h"

@implementation Utils

+ (UIImage *)getAvatar:(NSMutableArray *)imageString gender:(NSNumber *)gender {
    if (imageString.count) {
        NSString *image = (NSString *)imageString[0];
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:image
            options:NSDataBase64DecodingIgnoreUnknownCharacters];
        return [UIImage imageWithData:imageData];
    }
    if (gender.integerValue) {
        return [UIImage imageNamed:kDefaultMaleAvatar];
    } else {
        return [UIImage imageNamed:kDefaultFemaleAvatar];
    }
}

+ (UIImage *)resize:(UIImage *)image scaledToSize:(CGSize)newSize {
    if (CGSizeEqualToSize(image.size, newSize)) {
        return image;
    }
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f);
    [image drawInRect:CGRectMake(0.0f, 0.0f, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)getUIImageFromAsset:(PHAsset *)asset maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight {
    PHImageManager *manager = [PHImageManager defaultManager];
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    __block UIImage *image = [[UIImage alloc] init];
    option.synchronous = true;
    [manager requestImageForAsset:asset targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)
        contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result,
        NSDictionary * _Nullable info) {
        image = result;
    }];
    NSInteger width, height;
    if (asset.pixelWidth < maxWidth && asset.pixelHeight < maxHeight) {
        width = asset.pixelWidth;
        height = asset.pixelHeight;
    } else {
        float ratio;
        if (asset.pixelWidth > asset.pixelHeight) {
            ratio = maxWidth / asset.pixelWidth;
        } else {
            ratio = maxHeight / asset.pixelHeight;
        }
        width = asset.pixelWidth * ratio;
        height = asset.pixelHeight * ratio;
    }
    image = [Utils resize:image scaledToSize:CGSizeMake(width / [UIViewConstant screenScale],
        height / [UIViewConstant screenScale])];
    return image;
}

+ (NSString *)stringfromNumber:(NSUInteger)number {
    switch (number) {
        case 1 ... 999: {
            return [@(number) stringValue];
        }
        case 1000 ... 9999: {
            return [NSString stringWithFormat:@"%.1fk", number / 1000.0];
        }
        case 10000 ... 999999: {
            return [NSString stringWithFormat:@"%ldk", number / 1000];
        }
        case 1000000 ... 9999999: {
            return [NSString stringWithFormat:@"%.1fm", number / 1000000.0];
        }
        case 10000000 ... 999999999: {
            return [NSString stringWithFormat:@"%ldm", number / 1000000];
        }
        case 1000000000 ... NSUIntegerMax: {
            return [NSString stringWithFormat:@"%ldb", number / 1000000000];
        }
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

+ (void)addUserIfNotExist:(NSMutableArray *)array user:(User *)user {
    BOOL isExist = NO;
    for (User *temp in array) {
        if (temp.userId == user.userId) {
            isExist = YES;
            break;
        }
    }
    if (!isExist) {
        [array addObject:user];
    }
}

+ (void)removeUser:(NSMutableArray *)array user:(User *)user {
    for (User *temp in array) {
        if (temp.userId == user.userId) {
            [array removeObject:temp];
            break;
        }
    }
}

+ (UITableViewCell *)emptyTableCell:(NSString *)message {
    UITableViewCell *emptyCell = [UITableViewCell new];
    emptyCell.textLabel.text = message;
    emptyCell.textLabel.font = [UIFont fontWithName:kDefaultFontName size:16.0f];
    emptyCell.textLabel.textAlignment = NSTextAlignmentCenter;
    return emptyCell;
}

+ (void)showLocalNotification:(NSString *)alertBody userInfo:(NSDictionary *)userInfo {
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5.0];
    localNotification.alertBody = alertBody;
    localNotification.userInfo = userInfo;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.timeZone = [NSTimeZone localTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

+ (void)setApplicationBadge:(BOOL)isIncrease {
    if (isIncrease) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[UIApplication sharedApplication]
            applicationIconBadgeNumber] + 1];
    } else {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[UIApplication sharedApplication]
            applicationIconBadgeNumber] - 1];
    }
}

+ (NSString *)sentTimeFromDate:(NSString *)dateString withDetail:(BOOL)withDetail {
    FDateFormatter *dateFormatter = [FDateFormatter sharedDateFormatter];
    dateFormatter.dateFormat = kDefaultDateTimeFormat;
    NSDate *date = [dateFormatter dateFromString:dateString];
    if ([[NSCalendar currentCalendar] isDateInToday:date]) {
        NSString *format = withDetail ? kSentTimeTodayFullFormat : @"%@";
        dateFormatter.dateFormat = kTimeWithHourMinuteFormat;
        return [NSString stringWithFormat:format, [dateFormatter stringFromDate:date withLocalTimeZone:[NSTimeZone
            localTimeZone]]];
    }
    if ([[NSCalendar currentCalendar] isDateInYesterday:date]) {
        if (!withDetail) {
            return kSentTimeYesterdayFormat;
        }
        NSString *format = kSentTimeYesterdayFullFormat;
        dateFormatter.dateFormat = kTimeWithHourMinuteFormat;
        return [NSString stringWithFormat:format, [dateFormatter stringFromDate:date withLocalTimeZone:[NSTimeZone
            localTimeZone]]];
    }
    NSDate *today = [NSDate date];
    NSInteger days = [today timeDiffFromDate:date unit:NSCalendarUnitDay].day;
    if (days > 1 && days < 7) {
        dateFormatter.dateFormat = withDetail ? kTimeWithDayOfWeekFullFormat : kTimeWithDayOfWeekFormat;
        return [dateFormatter stringFromDate:date withLocalTimeZone:[NSTimeZone localTimeZone]];
    }
    NSInteger months = [today timeDiffFromDate:date unit:NSCalendarUnitMonth].month;
    if (months < 12) {
        dateFormatter.dateFormat = withDetail ? kTimeInYearFullFormat : kTimeInYearFormat;
        return [dateFormatter stringFromDate:date withLocalTimeZone:[NSTimeZone localTimeZone]];
    }
    dateFormatter.dateFormat = withDetail ? kTimeNotInYearFullFormat : kTimeNotInYearFormat;
    return [dateFormatter stringFromDate:date withLocalTimeZone:[NSTimeZone localTimeZone]];
}

@end
