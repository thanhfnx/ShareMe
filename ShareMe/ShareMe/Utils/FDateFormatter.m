//
//  FDateFormatter.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/1/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "FDateFormatter.h"

@implementation FDateFormatter

+ (instancetype)sharedDateFormatter {
  static id sharedDateFormatter = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedDateFormatter = [[self alloc] init];
    [((NSDateFormatter *)sharedDateFormatter) setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
  });
  return sharedDateFormatter;
}

- (NSString *)stringFromDate:(NSDate *)date withLocalTimeZone:(NSTimeZone *)timeZone {
    [self setTimeZone:timeZone];
    NSString *result = [self stringFromDate:date];
    [self setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    return result;
}

@end
