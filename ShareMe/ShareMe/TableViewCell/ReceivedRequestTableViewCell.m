//
//  ReceivedRequestTableViewCell.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/24/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "ReceivedRequestTableViewCell.h"
#import "User.h"
#import "UIViewConstant.h"
#import "Utils.h"

@implementation ReceivedRequestTableViewCell

- (void)setUser:(User *)user {
    self.imvAvatar.image = [Utils getAvatar:user.avatarImage gender:user.gender];
    self.lblFullName.text = [user fullName];
    self.lblUserName.text = [@"@" stringByAppendingString:user.userName];
}

@end
