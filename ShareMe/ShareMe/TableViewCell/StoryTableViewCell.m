//
//  StoryTableViewCell.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/24/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "StoryTableViewCell.h"
#import "Story.h"
#import "Utils.h"

@implementation StoryTableViewCell

- (void)setStory:(Story *)story imageIndex:(NSInteger)imageIndex {
    self.imvAvatar.image = [Utils getAvatar:story.creator.avatarImage gender:story.creator.gender];
    self.lblFullName.text = [story.creator fullName];
    self.lblUserName.text = [NSString stringWithFormat:@"@%@", story.creator.userName];
    self.lblCreatedTime.text = [Utils timeDiffFromDate:story.createdTime];
    self.txvContent.text = story.content;
    if (!story.images.count) {
        [self.likeButtonTopSpacingConstraint setConstant:0.0f];
        [self.contentImageViewHeightConstraint setConstant:0.0f];
    } else {
        CGFloat height = [Utils screenWidth] * 9.0f / 16.0f;
        [self.likeButtonTopSpacingConstraint setConstant:height + 8.0f];
        [self.contentImageViewHeightConstraint setConstant:height];
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:story.images[imageIndex]
            options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *image = [UIImage imageWithData:imageData];
        self.imvContent.image = image;
    }
    // TODO: Replace sample data
    self.lblNumberOfComments.text = [Utils stringfromNumber:723233];
    self.lblNumberOfLikes.text = [Utils stringfromNumber:411];
}

@end
