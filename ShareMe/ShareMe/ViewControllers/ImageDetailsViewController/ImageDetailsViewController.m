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

@interface ImageDetailsViewController ()

@end

@implementation ImageDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
    cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageDetailCollectionViewCell *cell = [collectionView
        dequeueReusableCellWithReuseIdentifier:kImageDetailReuseIdentifier forIndexPath:indexPath];
    [cell setImageDetail:self.images[indexPath.row] withHandler:^(BOOL isZooming){
        [collectionView setScrollEnabled:isZooming];
    }];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size;
}

@end
