//
//  FViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/27/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "FViewController.h"
#import "ApplicationConstants.h"
#import "TimelineViewController.h"

NSString *const kTakeImageFromCameraActionTitle = @"Take from camera";
NSString *const kTakeImageFromLibraryActionTitle = @"Take from photo library";
NSString *const kCancelActionTitle = @"Cancel";

@interface FViewController () {
    UIView *_vActivityIndicator;
    NSInteger _preparedUserId;
}

@end

@implementation FViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_isSwipeGestureDisable) {
        [self setSwipeGestureRecognizer];
    }
}

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

- (void)showImagePickerDialog:(NSString *)message title:(NSString *)title
    takeFromCameraHandler:(void (^ _Nullable)(UIAlertAction *action))takeFromCameraHandler
    takeFromLibraryHandler:(void (^ _Nullable)(UIAlertAction *action))takeFromLibraryHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message
        preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takeFromCameraAction = [UIAlertAction actionWithTitle:kTakeImageFromCameraActionTitle
        style:UIAlertActionStyleDefault handler:takeFromCameraHandler];
    UIAlertAction *takeFromLibraryAction = [UIAlertAction actionWithTitle:kTakeImageFromLibraryActionTitle
        style:UIAlertActionStyleDefault handler:takeFromLibraryHandler];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kCancelActionTitle
        style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:takeFromCameraAction];
    [alertController addAction:takeFromLibraryAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)setTapGestureRecognizer:(NSArray<UIView *> *)views userId:(NSInteger)userId {
    UITapGestureRecognizer *tapGestureRecognizer;
    for (UIView *view in views) {
        view.tag = userId;
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToUserProfile:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        view.userInteractionEnabled = YES;
        [view addGestureRecognizer:tapGestureRecognizer];
    }
}

- (void)setSwipeGestureRecognizer {
    UISwipeGestureRecognizer *swipeGestureRecognizer;
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] > 0) {
        swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
            action:@selector(goToPreviousViewController:)];
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    } else if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] == 0) {
        swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
            action:@selector(goToOnlineFriends:)];
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    }
    [self.view addGestureRecognizer:swipeGestureRecognizer];
}

- (void)goToPreviousViewController:(UISwipeGestureRecognizer *)sender {
    [self dismissKeyboard];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goToOnlineFriends:(UISwipeGestureRecognizer *)sender {
    [self dismissKeyboard];
    [self performSegueWithIdentifier:kGoToListFriendSegueIdentifier sender:self];
}

- (void)goToUserProfile:(UITapGestureRecognizer *)sender {
    _preparedUserId = [sender view].tag;
    [self dismissKeyboard];
    [self performSegueWithIdentifier:kGoToUserTimelineSegueIdentifier sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kGoToUserTimelineSegueIdentifier]) {
        TimelineViewController *timelineViewController = [segue destinationViewController];
        timelineViewController.userId = _preparedUserId;
    }
}

@end
