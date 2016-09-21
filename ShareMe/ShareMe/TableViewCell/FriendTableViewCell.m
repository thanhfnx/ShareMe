//
//  FriendTableViewCell.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/20/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "FriendTableViewCell.h"
#import "Utils.h"
#import "User.h"

@implementation FriendTableViewCell

- (void)setUser:(User *)user {
    self.imvAvatar.image = [Utils getAvatar:user.avatarImage gender:user.gender];
    self.lblFullName.text = [user fullName];
    if (user.status.boolValue) {
        self.lblOnlineStatus.backgroundColor = [UIColor greenColor];
    } else {
        self.lblOnlineStatus.backgroundColor = [UIColor lightGrayColor];
    }
}

@end
