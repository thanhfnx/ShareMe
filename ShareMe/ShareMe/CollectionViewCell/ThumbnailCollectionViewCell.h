//
//  ThumbnailCollectionViewCell.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/30/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThumbnailCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imvThumbnail;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;

@end
