//
//  ReceivedRequestTableViewCell.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/24/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "ReceivedRequestTableViewCell.h"
#import "User.h"

static NSString *const kDefaultMaleAvatar = @"default-male-avatar";
static NSString *const kDefaultFemaleAvatar = @"default-female-avatar";

@implementation ReceivedRequestTableViewCell

- (void)setUser:(User *)user {
    NSString *imageName;
    if (user.avatarImageURL.length) {
        imageName = user.avatarImageURL;
    } else if (user.gender) {
        imageName = kDefaultMaleAvatar;
    } else {
        imageName = kDefaultFemaleAvatar;
    }
    self.imvAvatar.image = [UIImage imageNamed:imageName];
    self.lblFullName.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    self.lblUserName.text = [@"@" stringByAppendingString:user.userName];
}

@end
