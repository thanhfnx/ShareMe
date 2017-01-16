//
//  NotificationTableViewCell.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 12/20/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "NotificationTableViewCell.h"
#import "Utils.h"
#import "Notification.h"
#import "User.h"
#import "Story.h"
#import "ApplicationConstants.h"

typedef NS_ENUM(NSInteger, NotificationTypes) {
    LikeNotificationType,
    CommentNotificationType,
    FriendNotificationType,
};

@implementation NotificationTableViewCell

- (void)setNotification:(Notification *)notification {
    self.imvSenderAvatar.image = [Utils getAvatar:notification.sender.avatarImage gender:notification.sender.gender];
    NSMutableAttributedString *notificationContent;
    NSString *notificationImageTypeName;
    switch (notification.notificationType.integerValue) {
        case LikeNotificationType: {
            NSString *plainContent = [NSString stringWithFormat:kLikedStoryNotification, [notification.sender fullName],
                notification.targetStory.content];
            notificationContent = [[NSMutableAttributedString alloc] initWithString:plainContent];
            [notificationContent addAttribute:NSFontAttributeName
                value:[UIFont boldSystemFontOfSize:self.lblContent.font.pointSize]
                range:NSMakeRange(0, [notification.sender fullName].length)];
            notificationImageTypeName = kLikedImage;
            break;
        }
        case CommentNotificationType: {
            NSString *plainContent = [NSString stringWithFormat:kCommenteddStoryNotification,
                [notification.sender fullName], notification.targetStory.content];
            notificationContent = [[NSMutableAttributedString alloc] initWithString:plainContent];
            [notificationContent addAttribute:NSFontAttributeName
                value:[UIFont boldSystemFontOfSize:self.lblContent.font.pointSize]
                range:NSMakeRange(0, [notification.sender fullName].length)];
            notificationImageTypeName = kLikedImage;
            break;
        }
        case FriendNotificationType: {
            NSString *plainContent = [NSString stringWithFormat:kAcceptedRequestNotification,
                [notification.sender fullName]];
            notificationContent = [[NSMutableAttributedString alloc] initWithString:plainContent];
            [notificationContent addAttribute:NSFontAttributeName
                value:[UIFont boldSystemFontOfSize:self.lblContent.font.pointSize]
                range:NSMakeRange(0, [notification.sender fullName].length)];
            notificationImageTypeName = kLikedImage;
            break;
        }
    }
    self.lblContent.attributedText = notificationContent;
    self.imvNotificationType.image = [UIImage imageNamed:notificationImageTypeName];
}

@end
