//
//  MessageDetailTableViewCell.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/28/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Message;

@interface MessageDetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imvAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UILabel *lblSentTime;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sentTimeLabelHeightConstraint;

- (void)setMessage:(Message *)message isFirstMessageOfTheDay:(BOOL)isFirstMessageOfTheDay;

@end
