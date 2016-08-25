//
//  StoryTableViewCell.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/24/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "StoryTableViewCell.h"
#import "Story.h"

static NSString *const kDefaultMaleAvatar = @"default-male-avatar";
static NSString *const kDefaultFemaleAvatar = @"default-female-avatar";

@implementation StoryTableViewCell

- (void)setStory:(Story *)story {
    self.imvAvatar.image = [UIImage imageNamed:(story.creator.avatarImageURL == nil ? (story.creator.gender.boolValue == 0 ? kDefaultMaleAvatar : kDefaultFemaleAvatar) : story.creator.avatarImageURL)];
    self.lblFullName.text = [story.creator fullName];
    self.lblUserName.text = [NSString stringWithFormat:@"@%@", story.creator.userName];
    // TODO: Calculate created time and display
    self.lblCreatedTime.text = @"4d ago";
    self.txvContent.text = story.content;
    // TODO: Replace sample data
    UIImage *image = [UIImage imageNamed:@"story-image"];
    self.imvContent.image = image;
    if (image.size.width >= image.size.height) {
        self.imvContent.contentMode = UIViewContentModeScaleAspectFill;
    } else {
        self.imvContent.contentMode = UIViewContentModeScaleAspectFit;
    }
    // TODO: Replace sample data
    self.lblNumberOfComments.text = @"942";
    self.lblNumberOfLikes.text = @"1.2k";
    [self setNeedsUpdateConstraints];
}

@end
