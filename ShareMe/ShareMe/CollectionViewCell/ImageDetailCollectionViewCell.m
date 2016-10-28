//
//  ImageDetailCollectionViewCell.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 10/28/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "ImageDetailCollectionViewCell.h"

@interface ImageDetailCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopConstraint;

@end

@implementation ImageDetailCollectionViewCell

- (void)setImageDetail:(UIImage *)image {
    self.scrollView.delegate = self;
    self.imvDetail.image = image;
    [self layoutIfNeeded];
    [self updateMinZoomScaleForSize];
    [self updateConstraintsForSize];
    UITapGestureRecognizer *zoomTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
        action:@selector(zoomWhenDoubleTapped:)];
    zoomTapGestureRecognizer.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:zoomTapGestureRecognizer];
}

#pragma  mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imvDetail;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self updateConstraintsForSize];
}

- (void)updateMinZoomScaleForSize {
    float widthScale = self.contentView.bounds.size.width / self.imvDetail.bounds.size.width;
    float heightScale = self.contentView.bounds.size.height / self.imvDetail.bounds.size.height;
    float minScale = widthScale < heightScale ? widthScale : heightScale;
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.zoomScale = minScale;
}

- (void)updateConstraintsForSize {
    CGFloat xOffset = MAX(0.0f, (self.contentView.bounds.size.width - self.imvDetail.frame.size.width) / 2);
    self.imageViewLeadingConstraint.constant = xOffset;
    self.imageViewTrailingConstraint.constant = xOffset;
    CGFloat yOffset = MAX(0.0f, (self.contentView.bounds.size.height - self.imvDetail.frame.size.height) / 2);
    self.imageViewTopConstraint.constant = yOffset;
    self.imageViewBottomConstraint.constant = yOffset;
    [self layoutIfNeeded];
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.collectionView setScrollEnabled:NO];
    } else {
        [self.collectionView setScrollEnabled:YES];
    }
}

- (void)zoomWhenDoubleTapped:(UIGestureRecognizer *)gesture {
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        [self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
    }
}

@end
