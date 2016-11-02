//
//  ImageDetailsViewController.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 10/28/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Story;

@interface ImageDetailsViewController : UIViewController <UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) Story *story;

@end
