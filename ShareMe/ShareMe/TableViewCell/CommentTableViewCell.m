//
//  CommentTableViewCell.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/12/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "Comment.h"
#import "User.h"
#import "Utils.h"

@implementation CommentTableViewCell

- (void)setComment:(Comment *)comment {
    self.imvAvatar.image = [Utils getAvatar:comment.creator.avatarImage gender:comment.creator.gender];
    self.lblFullName.text = [comment.creator fullName];
    self.lblCreatedTime.text = [Utils timeDiffFromDate:comment.createdTime];
    self.lblContent.text = comment.content;
}

@end
