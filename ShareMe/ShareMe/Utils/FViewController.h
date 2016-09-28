//
//  FViewController.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/27/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewConstant.h"

@interface FViewController : UIViewController

- (void)dismissKeyboard;
- (void)showActitvyIndicator:(UIView *)container frame:(CGRect)frame;
- (void)dismissActitvyIndicator;
- (void)showMessage:(NSString *)message title:(NSString *)title complete:(void (^)(UIAlertAction *action))complete;
- (void)showConfirmDialog:(NSString *)message title:(NSString *)title handler:(void (^)(UIAlertAction *action))handler;
- (void)showImagePickerDialog:(NSString *)message title:(NSString *)title
    takeFromCameraHandler:(void (^)(UIAlertAction *action))takeFromCameraHandler
    takeFromLibraryHandler:(void (^)(UIAlertAction *action))takeFromLibraryHandler;
- (void)setTapGestureRecognizer:(NSArray<UIView *> *)views userId:(NSInteger)userId;
- (void)setSwipeGestureRecognizer;
- (void)goToUserProfile:(UITapGestureRecognizer *)sender;
- (void)goToPreviousViewController:(UISwipeGestureRecognizer *)sender;
- (void)goToOnlineFriends:(UISwipeGestureRecognizer *)sender;

@end
