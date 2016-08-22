//
//  LoginViewController.m
//  SocialNetwork
//
//  Created by Nguyen Xuan Thanh on 7/18/16.
//  Copyright © 2016 Nguyen Xuan Thanh. All rights reserved.
//

#import "LoginController.h"
#import "UIViewController+ResponseHandler.h"
#import "ClientSocketController.h"
#import "User.h"
#import "LoginView.h"

NSString *const kDefaultMessageTitle = @"Warning";
NSString *const kEmptyUserNameMessage = @"UserName can not be empty!";
NSString *const kEmptyPasswordMessage = @"Password can not be empty!";
NSString *const kFailedLoginMessage = @"UserName or password is incorrect. Login failed!";

@interface LoginController () {
    LoginView *_loginView;
}

@end

@implementation LoginController

- (void)loadView {
    _loginView = [[LoginView alloc] init];
    self.view = _loginView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _loginView.txtUserName.delegate = self;
    _loginView.txtPassword.delegate = self;
    [_loginView.btnLogin addTarget:self action:@selector(btnLoginTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_loginView.btnRegister addTarget:self action:@selector(btnRegisterTapped:)
        forControlEvents:UIControlEventTouchUpInside];
    [_loginView.btnForgotPassword addTarget:self action:@selector(btnForgotPasswordTapped:)
        forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
        action:@selector(dismissKeyboard)];
    [_loginView addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
        name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
        name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == _loginView.txtUserName) {
        if ([_loginView.txtUserName.text isEqualToString:@""]) {
            [self showMessage:kEmptyUserNameMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [_loginView.txtUserName becomeFirstResponder];
            }];
            return NO;
        }
        [_loginView.txtPassword becomeFirstResponder];
    } else {
        if ([_loginView.txtPassword.text isEqualToString:@""]) {
            [self showMessage:kEmptyPasswordMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [_loginView.txtPassword becomeFirstResponder];
            }];
            return NO;
        }
        [self btnLoginTapped:nil];
    }
    return YES;
}

- (User *)getUser {
    User *user = [[User alloc] init];
    user.userName = _loginView.txtUserName.text;
    user.password = _loginView.txtPassword.text;
    return user;
}

- (BOOL)validate {
    if ([_loginView.txtUserName.text isEqualToString:@""]) {
        [self showMessage:kEmptyUserNameMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
            [_loginView.txtUserName becomeFirstResponder];
        }];
        return NO;
    }
    if ([_loginView.txtPassword.text isEqualToString:@""]) {
        [self showMessage:kEmptyPasswordMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
            [_loginView.txtPassword becomeFirstResponder];
        }];
        return NO;
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

- (void)dismissKeyboard {
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UITextField class]] && [view isFirstResponder]) {
            [view resignFirstResponder];
        }
    }
}

- (void)btnLoginTapped:(UIButton *)sender {
    [self dismissKeyboard];
    if ([self validate]) {
        [ClientSocketController sendData:[self getUser] messageType:kSendingRequestSignal
            actionName:kUserLoginAction sender:self];
    }
}

- (void)btnRegisterTapped:(UIButton *)sender {
    [self dismissKeyboard];
    // TODO
}

- (void)btnForgotPasswordTapped:(UIButton *)sender {
    // TODO
}

#pragma mark - Show/hide keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect theFrame = self.view.frame;
        CGFloat offset = _loginView.imvLogo.frame.origin.y + _loginView.imvLogo.frame.size.height;
        _loginView.registerButtonBottomConstraint.constant = offset - keyboardSize.height;
        theFrame.origin.y = -offset;
        self.view.frame = theFrame;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    float ratio = [[UIScreen mainScreen] bounds].size.width / 320.0f;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        _loginView.registerButtonBottomConstraint.constant = -8.0f * ratio;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

#pragma mark - Response Handler

- (void)handleResponse:(NSArray *)result {
    if ([result[2] isEqualToString:kFailureMessage]) {
        [self showMessage:kFailedLoginMessage title:kDefaultMessageTitle complete:nil];
    } else {
        NSError *error;
        User *user = [[User alloc] initWithString:result[2] error:&error];
        if (!user.friends) {
            user.friends = [NSMutableArray<User, Optional> array];
        }
        if (!user.sentRequests) {
            user.sentRequests = [NSMutableArray<User, Optional> array];
        }
        if (!user.receivedRequests) {
            user.receivedRequests = [NSMutableArray<User, Optional> array];
        }
        [self initTabBarController:user];
    }
}

- (void)initTabBarController:(User *)user {
    // TOTO
}

@end
