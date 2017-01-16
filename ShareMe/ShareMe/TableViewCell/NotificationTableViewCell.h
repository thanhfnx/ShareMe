//
//  NotificationTableViewCell.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 12/20/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Notification;

@interface NotificationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imvSenderAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UIImageView *imvNotificationType;
@property (weak, nonatomic) IBOutlet UILabel *lblSentTime;

- (void)setNotification:(Notification *)notification;

@end
