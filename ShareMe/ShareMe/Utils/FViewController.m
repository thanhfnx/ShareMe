//
//  FViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/27/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "FViewController.h"

@interface FViewController () {
    UIView *_vActivityIndicator;
}

@end

@implementation FViewController

- (void)showActitvyIndicator:(UIView *)container frame:(CGRect)frame {
    if (!_vActivityIndicator) {
        _vActivityIndicator = [[NSBundle mainBundle] loadNibNamed:@"ActivityIndicatorView" owner:self options:nil][0];
        _vActivityIndicator.frame = frame;
        [container addSubview:_vActivityIndicator];
    } else {
        _vActivityIndicator.hidden = NO;
    }
}

- (void)dismissActitvyIndicator {
    _vActivityIndicator.hidden = YES;
}

- (void)showMessage:(NSString *)message title:(NSString *)title complete:(void (^)(UIAlertAction *action))complete {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message
        preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:complete];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showConfirmDialog:(NSString *)message title:(NSString *)title
    handler:(void (^ _Nullable)(UIAlertAction *action))handler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message
        preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:handler];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:yesAction];
    [alertController addAction:noAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

@end
