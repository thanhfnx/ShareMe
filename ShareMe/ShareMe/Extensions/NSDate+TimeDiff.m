//
//  NSDate+TimeDiff.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/1/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "NSDate+TimeDiff.h"

@implementation NSDate (TimeDiff)

- (NSDateComponents *)timeDiffFromDate:(NSDate *)date unit:(NSCalendarUnit)unit {
    return [[NSCalendar currentCalendar] components:unit fromDate:date toDate:self options:kNilOptions];
}

@end
