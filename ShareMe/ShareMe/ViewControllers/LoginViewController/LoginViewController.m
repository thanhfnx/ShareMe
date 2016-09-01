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
#import "MainTabBarViewController.h"

static NSString *const kDefaultMessageTitle = @"Warning";
static NSString *const kEmptyUserNameMessage = @"UserName can not be empty!";
static NSString *const kEmptyPasswordMessage = @"Password can not be empty!";
static NSString *const kFailedLoginMessage = @"UserName or password is incorrect. Login failed!";
static NSString *const kGoToMainTabBarSegueIdentifier = @"goToMainTabBar";
static NSString *const kGoToRegisterSegueIdentifier = @"goToRegister";

@interface LoginViewController () {
    User *_user;
}

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

#pragma mark - IBAction

- (IBAction)loginButtonTapped:(UIButton *)sender {
    [self dismissKeyboard];
    if ([self validate]) {
        [self showActitvyIndicator];
        [ClientSocketController sendData:[[self getUser] toJSONString] messageType:kSendingRequestSignal actionName:kUserLoginAction
            sender:self];
    }
}

- (IBAction)registerButtonTapped:(UIButton *)sender {
    [self performSegueWithIdentifier:kGoToRegisterSegueIdentifier sender:self];
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
    [self dismissActitvyIndicator];
    if ([message isEqualToString:kFailureMessage]) {
        [self showMessage:kFailedLoginMessage title:kDefaultMessageTitle complete:nil];
    } else {
        NSError *error;
        _user = [[User alloc] initWithString:message error:&error];
        // TODO: Handle error
        if (!_user.friends) {
            _user.friends = [NSMutableArray<User, Optional> array];
        }
        if (!_user.sentRequests) {
            _user.sentRequests = [NSMutableArray<User, Optional> array];
        }
        if (!_user.receivedRequests) {
            _user.receivedRequests = [NSMutableArray<User, Optional> array];
        }
        [self performSegueWithIdentifier:kGoToMainTabBarSegueIdentifier sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kGoToMainTabBarSegueIdentifier]) {
        MainTabBarViewController *mainTabBarViewController = [segue destinationViewController];
        mainTabBarViewController.loggedInUser = _user;
    }
}

@end
