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

- (void)setMessage:(Message *)message isFirstMessageOfTheDay:(BOOL)isFirstMessageOfTheDay {
    self.imvAvatar.image = [Utils getAvatar:message.sender.avatarImage gender:message.sender.gender];
    self.lblContent.text = message.content;
    if (isFirstMessageOfTheDay) {
        self.lblSentTime.text = [Utils sentTimeFromDate:message.sentTime withDetail:YES];
        self.messageViewTopConstraint.constant = 4.0f;
        self.sentTimeLabelHeightConstraint.constant = 17.0f;
    } else {
        self.messageViewTopConstraint.constant = 0.0f;
        self.sentTimeLabelHeightConstraint.constant = 0.0f;
    }
}

@end
