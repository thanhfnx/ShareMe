//
//  User.m
//  SocialNetwork
//
//  Created by Nguyen Xuan Thanh on 7/18/16.
//  Copyright © 2016 Nguyen Xuan Thanh. All rights reserved.
//

#import "User.h"

@implementation User

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

@end
