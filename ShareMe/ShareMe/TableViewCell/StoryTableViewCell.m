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
#import "ApplicationConstants.h"
#import "UIViewConstant.h"

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
        } else if ([story.images[0] isKindOfClass:[NSString class]]) {
            firstImageSize = CGSizeFromString(story.images[0]);
        }
        NSInteger firstImageType = [Utils getImageType:firstImageSize];
        switch (numberOfImages) {
            case 1: {
                view = (UIView *)nibObjects[0];
                if (firstImageType == ImageTypeLongWidth) {
                    height += [UIViewConstant screenWidth] / kLandscapeImageRatio;
                } else if (firstImageType == ImageTypeLongHeight) {
                    height += [UIViewConstant screenWidth] / kPortraitImageRatio;
                } else {
                    height += [UIViewConstant screenWidth] * (firstImageSize.height / firstImageSize.width);
                }
                break;
            }
            case 2: {
                if (firstImageType == ImageTypeLongHeight || firstImageType == ImageTypePortrait) {
                    view = (UIView *)nibObjects[2];
                    height += ([UIViewConstant screenWidth] - 2.0f) / (kPortraitImageRatio * 2);
                } else {
                    view = (UIView *)nibObjects[1];
                    height += [UIViewConstant screenWidth] / (kLandscapeImageRatio / 2);
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
                height += [UIViewConstant screenWidth];
                break;
            }
            case 4 ... NSIntegerMax: {
                if (firstImageType == ImageTypeLongHeight || firstImageType == ImageTypePortrait) {
                    view = (UIView *)nibObjects[6];
                } else {
                    view = (UIView *)nibObjects[5];
                }
                height += [UIViewConstant screenWidth];
                break;
            }
        }
        self.contentImageViewHeightConstraint.constant = height;
        [self.likeButtonTopSpacingConstraint setConstant:height + 8.0f];
        CGRect frame = CGRectMake(0.0f, 0.0f, [UIViewConstant screenWidth], height);
        view.frame = frame;
        [self.vContentImages addSubview:view];
        [view.subviews enumerateObjectsUsingBlock:^(id view, NSUInteger index, BOOL *stop) {
            if ([view isKindOfClass:[UIImageView class]] && [story.images[index] isKindOfClass:[UIImage class]]) {
                ((UIImageView *)view).image = story.images[index];
            } else if ([view isKindOfClass:[UILabel class]] && story.images.count > 4 && [story.images[3]
                isKindOfClass:[UIImage class]]) {
                UILabel *lblNumberOfRemainingImages = view;
                lblNumberOfRemainingImages.text = [NSString stringWithFormat:@"+%ld", story.images.count - 4];
                lblNumberOfRemainingImages.hidden = NO;
            }
        }];
    }
    UIImage *likedImage = [UIImage imageNamed:@"loved"];
    UIImage *unlikedImage = [UIImage imageNamed:@"love"];
    UIImage *commentedImage = [UIImage imageNamed:@"commented"];
    UIImage *uncommentedImage = [UIImage imageNamed:@"comment"];
    if (story.numberOfLikedUsers.integerValue) {
        self.lblNumberOfLikes.text = [Utils stringfromNumber:story.numberOfLikedUsers.integerValue];
        if (story.likedUsers.count) {
            [self.btnLike setImage:likedImage forState:UIControlStateNormal];
            self.lblNumberOfLikes.textColor = [UIColor redColor];
        } else {
            [self.btnLike setImage:unlikedImage forState:UIControlStateNormal];
            self.lblNumberOfLikes.textColor = [UIColor lightGrayColor];
        }
    } else {
        self.lblNumberOfLikes.text = @"";
        [self.btnLike setImage:unlikedImage forState:UIControlStateNormal];
    }
    if (story.numberOfComments.integerValue) {
        self.lblNumberOfComments.text = [Utils stringfromNumber:story.numberOfComments.integerValue];
        if (story.comments.count) {
            [self.btnComment setImage:commentedImage forState:UIControlStateNormal];
            self.lblNumberOfComments.textColor = [UIColor redColor];
        } else {
            [self.btnComment setImage:uncommentedImage forState:UIControlStateNormal];
            self.lblNumberOfComments.textColor = [UIColor lightGrayColor];
        }
    } else {
        self.lblNumberOfComments.text = @"";
        [self.btnComment setImage:uncommentedImage forState:UIControlStateNormal];
    }
    [self.btnWhoLikeThis setTitle:@"" forState:UIControlStateNormal];
    switch (story.numberOfLikedUsers.integerValue) {
        case 0: {
            [self.btnLike setImage:unlikedImage forState:UIControlStateNormal];
            [self.btnWhoLikeThis setTitle:kEmptyLikedUsersLabelText forState:UIControlStateNormal];
            break;
        }
        case 1: {
            if (story.likedUsers.count) {
                [self.btnWhoLikeThis setTitle:kSelfLikeLabelText forState:UIControlStateNormal];
                [self.btnLike setImage:likedImage forState:UIControlStateNormal];
            } else {
                [self.btnWhoLikeThis setTitle:kOneLikeLabelText forState:UIControlStateNormal];
                [self.btnLike setImage:unlikedImage forState:UIControlStateNormal];
            }
            break;
        }
        case 2 ... NSIntegerMax: {
            if (story.likedUsers.count) {
                [self.btnWhoLikeThis setTitle:[NSString stringWithFormat:kSelfLikeWithOthersLabelText,
                    story.numberOfLikedUsers.integerValue - 1] forState:UIControlStateNormal];
                [self.btnLike setImage:likedImage forState:UIControlStateNormal];
            } else {
                [self.btnWhoLikeThis setTitle:[NSString stringWithFormat:kManyLikeLabelText,
                    story.numberOfLikedUsers.integerValue] forState:UIControlStateNormal];
                [self.btnLike setImage:unlikedImage forState:UIControlStateNormal];
            }
            break;
        }
    }
}

@end
