//
//  SearchFriendTableViewCell.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/25/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "SearchFriendTableViewCell.h"
#import "UIViewConstant.h"
#import "User.h"

typedef NS_ENUM(NSInteger, Relations) {
    FriendRelation,
    SentRequestRelation,
    ReceivedRequestRelation,
    NotFriendRelation
};

static NSString *const kDefaultMaleAvatar = @"default-male-avatar";
static NSString *const kDefaultFemaleAvatar = @"default-female-avatar";
static NSString *const kFriendButtonTitle = @"Friends";
static NSString *const kSentRequestButtonTitle = @"Cancel";
static NSString *const kReceivedRequestButtonTitle = @"Reply";
static NSString *const kNotFriendButtonTitle = @"Add";

@implementation SearchFriendTableViewCell

- (void)setUser:(User *)user relationStatus:(NSInteger)relationStatus {
    NSString *imageName;
    if (user.avatarImageURL.length) {
        imageName = user.avatarImageURL;
    } else if (user.gender) {
        imageName = kDefaultMaleAvatar;
    } else {
        imageName = kDefaultFemaleAvatar;
    }
    self.imvAvatar.image = [UIImage imageNamed:imageName];
    self.lblFullName.text = [user fullName];
    self.lblUserName.text = [@"@" stringByAppendingString:user.userName];
    NSString *actionButtonTitle;
    UIColor *actionButtonTitleColor;
    UIColor *actionButtonBackgroundColor;
    switch (relationStatus) {
        case FriendRelation:
            actionButtonTitle = kFriendButtonTitle;
            actionButtonTitleColor = [UIColor whiteColor];
            actionButtonBackgroundColor = [UIColor defaultThemeColor];
            break;
        case SentRequestRelation:
            actionButtonTitle = kSentRequestButtonTitle;
            actionButtonTitleColor = [UIColor defaultThemeColor];
            actionButtonBackgroundColor = [UIColor whiteColor];
            break;
        case ReceivedRequestRelation:
            actionButtonTitle = kReceivedRequestButtonTitle;
            actionButtonTitleColor = [UIColor defaultThemeColor];
            actionButtonBackgroundColor = [UIColor whiteColor];
            break;
        case NotFriendRelation:
            actionButtonTitle = kNotFriendButtonTitle;
            actionButtonTitleColor = [UIColor whiteColor];
            actionButtonBackgroundColor = [UIColor defaultThemeColor];
            break;
    }
    [self.btnAction setTitle:actionButtonTitle forState:UIControlStateNormal];
    [self.btnAction setTitleColor:actionButtonTitleColor forState:UIControlStateNormal];
    [self.btnAction setBackgroundColor:actionButtonBackgroundColor];
}

@end
