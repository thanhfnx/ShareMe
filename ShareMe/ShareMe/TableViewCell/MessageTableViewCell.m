//
//  MessageTableViewCell.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/30/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "Message.h"
#import "Utils.h"
#import "User.h"

@implementation MessageTableViewCell

- (void)setMessage:(Message *)message currentUser:(User *)currentUser {
    if (currentUser.userId == message.sender.userId) {
        self.imvAvatar.image = [Utils getAvatar:message.receiver.avatarImage gender:message.receiver.gender];
        self.lblFullName.text = [message.receiver fullName];
    } else {
        self.imvAvatar.image = [Utils getAvatar:message.sender.avatarImage gender:message.sender.gender];
        self.lblFullName.text = [message.sender fullName];
    }
    self.lblLastMessage.text = message.content;
    self.lblSentTime.text = [Utils timeDiffFromDate:message.sentTime];
}

@end
