//
//  FDateFormatter.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/1/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FDateFormatter : NSDateFormatter

+ (instancetype)sharedDateFormatter;
- (NSString *)stringFromDate:(NSDate *)date withLocalTimeZone:(NSTimeZone *)timeZone;

@end
