//
//  ImageDetailsViewController.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 10/28/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageDetailsViewController : UIViewController <UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSArray<UIImage *> *images;

@end
