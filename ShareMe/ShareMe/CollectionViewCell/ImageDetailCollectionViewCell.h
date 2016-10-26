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

- (void)setImageDetail:(UIImage *)image withHandler:(void(^)(BOOL isZooming))handler;

@end
