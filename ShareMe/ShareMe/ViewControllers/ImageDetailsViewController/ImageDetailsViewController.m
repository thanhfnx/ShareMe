//
//  ImageDetailsViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 10/28/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "ImageDetailsViewController.h"
#import "ImageDetailCollectionViewCell.h"
#import "ApplicationConstants.h"
#import "Story.h"
#import "Utils.h"

@interface ImageDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UIView *vSeparator;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;
@property (weak, nonatomic) IBOutlet UIButton *btnComment;
@property (weak, nonatomic) IBOutlet UILabel *lblNumberOfLikes;
@property (weak, nonatomic) IBOutlet UILabel *lblNumberOfComments;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *showHideSubviewsTapGestureRecognizer;

@end

@implementation ImageDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [self updateStory];
}

- (void)updateStory {
    if (self.story) {
        self.lblContent.text = self.story.content;
        UIImage *likedImage = [UIImage imageNamed:kWhiteLikedImage];
        UIImage *unlikedImage = [UIImage imageNamed:kWhiteUnikedImage];
        UIImage *commentedImage = [UIImage imageNamed:kWhiteCommentedImage];
        UIImage *uncommentedImage = [UIImage imageNamed:kWhiteUncommentedImage];
        if (self.story.numberOfLikedUsers.integerValue) {
            self.lblNumberOfLikes.text = [Utils stringfromNumber:self.story.numberOfLikedUsers.integerValue];
            if (self.story.likedUsers.count) {
                [self.btnLike setImage:likedImage forState:UIControlStateNormal];
            } else {
                [self.btnLike setImage:unlikedImage forState:UIControlStateNormal];
            }
        } else {
            self.lblNumberOfLikes.text = @"";
        }
        if (self.story.numberOfComments.integerValue) {
            self.lblNumberOfComments.text = [Utils stringfromNumber:self.story.numberOfComments.integerValue];
            if (self.story.comments.count) {
                [self.btnComment setImage:commentedImage forState:UIControlStateNormal];
            } else {
                [self.btnComment setImage:uncommentedImage forState:UIControlStateNormal];
            }
        } else {
            self.lblNumberOfComments.text = @"";
            [self.btnComment setImage:uncommentedImage forState:UIControlStateNormal];
        }
    }
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.story.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
    cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageDetailCollectionViewCell *cell = [collectionView
        dequeueReusableCellWithReuseIdentifier:kImageDetailReuseIdentifier forIndexPath:indexPath];
    [cell setImageDetail:self.story.images[indexPath.row] withHandler:^(BOOL isZooming,
        UITapGestureRecognizer *gesture){
        [collectionView setScrollEnabled:isZooming];
        [self.showHideSubviewsTapGestureRecognizer requireGestureRecognizerToFail:gesture];
    }];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size;
}

#pragma mark - IBAction

- (IBAction)btnCloseTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showHideSubviews:(UIGestureRecognizer *)sender {
    if (self.btnClose.alpha == 1.0f) {
        [UIView animateWithDuration:0.3 animations:^{
            [self updateSubviewsAlpha:0.0f];
        }];
    } else if (self.btnClose.alpha == 0.0f) {
        [UIView animateWithDuration:0.3 animations:^{
            [self updateSubviewsAlpha:1.0f];
        }];
    }
}

- (void)updateSubviewsAlpha:(CGFloat)newValue {
    self.btnClose.alpha = newValue;
    self.lblContent.alpha = newValue;
    self.vSeparator.alpha = newValue;
    self.btnLike.alpha = newValue;
    self.btnComment.alpha = newValue;
    self.lblNumberOfLikes.alpha = newValue;
    self.lblNumberOfComments.alpha = newValue;
}

- (IBAction)closeImageDetailsView:(UISwipeGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
