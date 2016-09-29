//
//  MessageDetailTableViewCell.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/28/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "MessageDetailTableViewCell.h"
#import "Utils.h"
#import "Message.h"
#import "User.h"

@implementation MessageDetailTableViewCell

- (void)setMessage:(Message *)message {
    self.imvAvatar.image = [Utils getAvatar:message.sender.avatarImage gender:message.sender.gender];
    self.lblContent.text = message.content;
}

@end
