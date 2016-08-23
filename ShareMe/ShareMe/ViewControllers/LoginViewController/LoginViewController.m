//
//  LoginViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/22/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "LoginViewController.h"
#import "User.h"
#import "ClientSocketController.h"
#import "UIViewController+ResponseHandler.h"

NSString *const kDefaultMessageTitle = @"Warning";
NSString *const kEmptyUserNameMessage = @"UserName can not be empty!";
NSString *const kEmptyPasswordMessage = @"Password can not be empty!";
NSString *const kFailedLoginMessage = @"UserName or password is incorrect. Login failed!";
NSString *const kGoToMainTabBarSegueIdentifier = @"goToMainTabBar";

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imvLogo;
@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *registerButtonBottomConstraint;

@end

@implementation LoginViewController

#pragma mark - UIView Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
        name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
        name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self dismissKeyboard];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == self.txtUserName) {
        if ([self.txtUserName.text isEqualToString:@""]) {
            [self showMessage:kEmptyUserNameMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [self.txtUserName becomeFirstResponder];
            }];
            return NO;
        }
        [self.txtPassword becomeFirstResponder];
    } else {
        if ([self.txtPassword.text isEqualToString:@""]) {
            [self showMessage:kEmptyPasswordMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [self.txtPassword becomeFirstResponder];
            }];
            return NO;
        }
        [self loginButtonTapped:nil];
    }
    return YES;
}

- (void)showMessage:(NSString *)message title:(NSString *)title
        complete:(void (^ _Nullable)(UIAlertAction *action))complete {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message
        preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:complete];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Packing Entity

- (User *)getUser {
    User *user = [[User alloc] init];
    user.userName = self.txtUserName.text;
    user.password = self.txtPassword.text;
    return user;
}

#pragma mark - Validating Data

- (BOOL)validate {
    if ([self.txtUserName.text isEqualToString:@""]) {
        [self showMessage:kEmptyUserNameMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
            [self.txtUserName becomeFirstResponder];
        }];
        return NO;
    }
    if ([self.txtPassword.text isEqualToString:@""]) {
        [self showMessage:kEmptyPasswordMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
            [self.txtPassword becomeFirstResponder];
        }];
        return NO;
    }
    return YES;
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - IBAction

- (IBAction)loginButtonTapped:(UIButton *)sender {
    [self dismissKeyboard];
    if ([self validate]) {
        [ClientSocketController sendData:[self getUser] messageType:kSendingRequestSignal actionName:kUserLoginAction
            sender:self];
    }
}

- (IBAction)tapGestureRecognizer:(UITapGestureRecognizer *)sender {
    [self dismissKeyboard];
}

#pragma mark - Show / hide keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect theFrame = self.view.frame;
        CGFloat offset = self.imvLogo.frame.origin.y + self.imvLogo.frame.size.height;
        self.registerButtonBottomConstraint.constant = keyboardSize.height + 8.0f - offset;
        theFrame.origin.y = -offset;
        self.view.frame = theFrame;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        self.registerButtonBottomConstraint.constant = 8.0f;
        frame.origin.y = 0.0f;
        self.view.frame = frame;
    }];
}

#pragma mark - Response Handler

- (void)handleResponse:(NSString *)actionName message:(NSString *)message; {
    if ([message isEqualToString:kFailureMessage]) {
        [self showMessage:kFailedLoginMessage title:kDefaultMessageTitle complete:nil];
    } else {
        NSError *error;
        User *user = [[User alloc] initWithString:message error:&error];
        if (!user.friends) {
            user.friends = [NSMutableArray<User, Optional> array];
        }
        if (!user.sentRequests) {
            user.sentRequests = [NSMutableArray<User, Optional> array];
        }
        if (!user.receivedRequests) {
            user.receivedRequests = [NSMutableArray<User, Optional> array];
        }
        [self performSegueWithIdentifier:kGoToMainTabBarSegueIdentifier sender:self];
    }
}

@end
