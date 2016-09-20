//
//  FriendTableViewCell.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/20/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface FriendTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imvAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblFullName;
@property (weak, nonatomic) IBOutlet UILabel *lblOnlineStatus;

- (void)setUser:(User *)user;

@end
