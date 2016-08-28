//
//  FViewController.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/27/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FViewController : UIViewController

- (void)dismissKeyboard;
- (void)showActitvyIndicator;
- (void)dismissActitvyIndicator;
- (void)showMessage:(NSString *)message title:(NSString *)title complete:(void (^)(UIAlertAction *action))complete;
- (void)showConfirmDialog:(NSString *)message title:(NSString *)title handler:(void (^)(UIAlertAction *action))handler;

@end
