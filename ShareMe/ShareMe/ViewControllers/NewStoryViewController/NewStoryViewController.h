//
//  NewStoryViewController.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/26/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FViewController.h"
#import <QBImagePickerController/QBImagePickerController.h>

@interface NewStoryViewController : FViewController <UITextFieldDelegate, QBImagePickerControllerDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end
