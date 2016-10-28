//
//  ImageDetailCollectionViewCell.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 10/28/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageDetailCollectionViewCell : UICollectionViewCell <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imvDetail;
@property (strong, nonatomic) UICollectionView *collectionView;

- (void)setImageDetail:(UIImage *)image;

@end
