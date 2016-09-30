//
//  MessageTableViewCell.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/30/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;
@class Message;

@interface MessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imvAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblFullName;
@property (weak, nonatomic) IBOutlet UILabel *lblLastMessage;
@property (weak, nonatomic) IBOutlet UILabel *lblSentTime;

- (void)setMessage:(Message *)message currentUser:(User *)currentUser;

@end
