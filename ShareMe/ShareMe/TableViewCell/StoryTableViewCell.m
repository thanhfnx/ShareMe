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
#import "SocketConstant.h"

@implementation StoryTableViewCell

- (void)setStory:(Story *)story {
    self.imvAvatar.image = [Utils getAvatar:story.creator.avatarImage gender:story.creator.gender];
    self.lblFullName.text = [story.creator fullName];
    self.lblUserName.text = [NSString stringWithFormat:@"@%@", story.creator.userName];
    self.lblCreatedTime.text = [Utils timeDiffFromDate:story.createdTime];
    self.txvContent.text = story.content;
    [[self.vContentImages subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (!story.images.count) {
        [self.likeButtonTopSpacingConstraint setConstant:0.0f];
        [self.contentImageViewHeightConstraint setConstant:0.0f];
    } else {
        CGFloat height = 0.0f;
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"NewsFeedImageView" owner:self options:nil];
        NSInteger numberOfImages = story.images.count;
        UIView *view;
        CGSize firstImageSize;
        if ([story.images[0] isKindOfClass:[UIImage class]]) {
            firstImageSize = ((UIImage *)story.images[0]).size;
        } else if ([story.images[0] isKindOfClass:[NSString class]]){
            firstImageSize = CGSizeFromString(story.images[0]);
        }
        NSInteger firstImageType = [Utils getImageType:firstImageSize];
        switch (numberOfImages) {
            case 1: {
                view = (UIView *)nibObjects[0];
                if (firstImageType == ImageTypeLongWidth) {
                    height += [Utils screenWidth] / kLandscapeImageRatio;
                } else if (firstImageType == ImageTypeLongHeight) {
                    height += [Utils screenWidth] / kPortraitImageRatio;
                } else {
                    height += [Utils screenWidth] * (firstImageSize.height / firstImageSize.width);
                }
                break;
            }
            case 2: {
                if (firstImageType == ImageTypeLongHeight || firstImageType == ImageTypePortrait) {
                    view = (UIView *)nibObjects[2];
                    height += ([Utils screenWidth] - 2.0f) / (kPortraitImageRatio * 2);
                } else {
                    view = (UIView *)nibObjects[1];
                    height += [Utils screenWidth] / (kLandscapeImageRatio / 2);
                    height += 2.0f;
                }
                break;
            }
            case 3: {
                if (firstImageType == ImageTypeLongHeight || firstImageType == ImageTypePortrait) {
                    view = (UIView *)nibObjects[4];
                } else {
                    view = (UIView *)nibObjects[3];
                }
                height += [Utils screenWidth];
                break;
            }
            case 4 ... NSIntegerMax: {
                if (firstImageType == ImageTypeLongHeight || firstImageType == ImageTypePortrait) {
                    view = (UIView *)nibObjects[6];
                } else {
                    view = (UIView *)nibObjects[5];
                }
                height += [Utils screenWidth];
                break;
            }
        }
        self.contentImageViewHeightConstraint.constant = height;
        [self.likeButtonTopSpacingConstraint setConstant:height + 8.0f];
        CGRect frame = CGRectMake(0.0f, 0.0f, [Utils screenWidth], height);
        view.frame = frame;
        [self.vContentImages addSubview:view];
        [view.subviews enumerateObjectsUsingBlock:^(id view, NSUInteger index, BOOL *stop){
            if ([view isKindOfClass:[UIImageView class]] && [story.images[index] isKindOfClass:[UIImage class]]) {
                ((UIImageView *)view).image = story.images[index];
                if (index == 3 && story.images.count > 4) {
                    self.lblNumberOfRemainingImages.text = [NSString stringWithFormat:@"+%ld", story.images.count - 4];
                    self.lblNumberOfRemainingImages.hidden = NO;
                }
            }
        }];
    }
    // TODO: Replace sample data
    self.lblNumberOfComments.text = [Utils stringfromNumber:723233];
    self.lblNumberOfLikes.text = [Utils stringfromNumber:411];
}

@end
