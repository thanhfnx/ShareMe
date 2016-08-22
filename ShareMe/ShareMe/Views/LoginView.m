//
//  LoginView.m
//  SocialNetwork
//
//  Created by Nguyen Xuan Thanh on 7/27/16.
//  Copyright © 2016 Nguyen Xuan Thanh. All rights reserved.
//

#import "LoginView.h"
#import "UIViewConstant.h"

NSString *const kWelcomeLabelText = @"Welcome";
NSString *const kLogoImageName = @"logo";
NSString *const kUserTextFieldPlaceHolder = @"UserName";
NSString *const kPasswordTextFieldPlaceHolder = @"Password";
NSString *const kLoginButtonTitle = @"Login";
NSString *const kRegisterButtonTitle = @"Create an account";
NSString *const kForgotPasswordTitle = @"Forgot password";

@implementation LoginView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = [[UIScreen mainScreen] bounds];
        self.backgroundColor = [UIColor defaultThemeColor];
        [self initViews];
    }
    return self;
}

- (void)initViews {
    float ratio = [[UIScreen mainScreen] bounds].size.width / 320.0f;
    // Init lblWelcome
    UILabel *lblWelcome = [[UILabel alloc] init];
    lblWelcome.translatesAutoresizingMaskIntoConstraints = NO;
    lblWelcome.text = kWelcomeLabelText;
    lblWelcome.font = [UIFont fontWithName:kDefaultFontNameThin size:30.0f];
    lblWelcome.textAlignment = NSTextAlignmentCenter;
    lblWelcome.textColor = [UIColor whiteColor];
    [self addSubview:lblWelcome];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:lblWelcome attribute:NSLayoutAttributeCenterX
        relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:lblWelcome attribute:NSLayoutAttributeTop
        relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f
        constant:60.0f * ratio]];
    // Init _imvLogo
    _imvLogo = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imvLogo.translatesAutoresizingMaskIntoConstraints = NO;
    _imvLogo.image = [UIImage imageNamed:kLogoImageName];
    _imvLogo.contentMode = UIViewContentModeScaleAspectFill;
    _imvLogo.clipsToBounds = YES;
    [self addSubview:_imvLogo];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_imvLogo attribute:NSLayoutAttributeCenterX
        relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_imvLogo attribute:NSLayoutAttributeTop
        relatedBy:NSLayoutRelationEqual toItem:lblWelcome attribute:NSLayoutAttributeBottom multiplier:1.0f
        constant:20.0f * ratio]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_imvLogo attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0f
        constant:60.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_imvLogo attribute:NSLayoutAttributeHeight
        relatedBy:NSLayoutRelationEqual toItem:_imvLogo attribute:NSLayoutAttributeWidth multiplier:1.0f
        constant:0.0f]];
    // Init _txtUserName
    _txtUserName = [[UITextField alloc] init];
    _txtUserName.placeholder = kUserTextFieldPlaceHolder;
    _txtUserName.font = [UIFont fontWithName:kDefaultFontName size:14.0f];
    _txtUserName.borderStyle = UITextBorderStyleRoundedRect;
    _txtUserName.textAlignment = NSTextAlignmentCenter;
    _txtUserName.autocorrectionType = UITextAutocorrectionTypeNo;
    _txtUserName.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _txtUserName.returnKeyType = UIReturnKeyNext;
    _txtUserName.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_txtUserName];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_txtUserName attribute:NSLayoutAttributeLeading
        relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:20.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_txtUserName attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0f
        constant:-20.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_txtUserName attribute:NSLayoutAttributeBottom
        relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f
        constant:-10.0f * ratio]];
    // Init txtPassword
    _txtPassword = [[UITextField alloc] init];
    _txtPassword.placeholder = kPasswordTextFieldPlaceHolder;
    _txtPassword.font = [UIFont fontWithName:kDefaultFontName size:14.0f];
    _txtPassword.borderStyle = UITextBorderStyleRoundedRect;
    _txtPassword.textAlignment = NSTextAlignmentCenter;
    _txtPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    _txtPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _txtPassword.secureTextEntry = YES;
    _txtPassword.returnKeyType = UIReturnKeyDone;
    _txtPassword.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_txtPassword];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_txtPassword attribute:NSLayoutAttributeLeading
        relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:20.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_txtPassword attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0f
        constant:-20.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_txtPassword attribute:NSLayoutAttributeTop
        relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f
        constant:10.0f * ratio]];
    // Init btnLogin
    _btnLogin = [[UIButton alloc] init];
    _btnLogin.titleLabel.font = [UIFont fontWithName:kDefaultFontName size:15.0f];
    _btnLogin.titleLabel.textColor = [UIColor whiteColor];
    [_btnLogin setTitle:kLoginButtonTitle forState:UIControlStateNormal];
    _btnLogin.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_btnLogin];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_btnLogin attribute:NSLayoutAttributeCenterX
        relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_btnLogin attribute:NSLayoutAttributeTop
        relatedBy:NSLayoutRelationEqual toItem:_txtPassword attribute:NSLayoutAttributeBottom multiplier:1.0f
        constant:12.0f * ratio]];
    // Init _btnForgotPassword
    _btnForgotPassword = [[UIButton alloc] init];
    _btnForgotPassword.titleLabel.font = [UIFont fontWithName:kDefaultFontName size:15.0f];
    _btnForgotPassword.titleLabel.textColor = [UIColor whiteColor];
    [_btnForgotPassword setTitle:kForgotPasswordTitle forState:UIControlStateNormal];
    _btnForgotPassword.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_btnForgotPassword];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_btnForgotPassword attribute:NSLayoutAttributeCenterX
        relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_btnForgotPassword attribute:NSLayoutAttributeTop
        relatedBy:NSLayoutRelationEqual toItem:_btnLogin attribute:NSLayoutAttributeBottom multiplier:1.0f
        constant:8.0f * ratio]];
    // Init btnRegister
    _btnRegister = [[UIButton alloc] init];
    _btnRegister.titleLabel.font = [UIFont fontWithName:kDefaultFontName size:15.0f];
    _btnRegister.titleLabel.textColor = [UIColor whiteColor];
    [_btnRegister setTitle:kRegisterButtonTitle forState:UIControlStateNormal];
    _btnRegister.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_btnRegister];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_btnRegister attribute:NSLayoutAttributeCenterX
        relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    _registerButtonBottomConstraint = [NSLayoutConstraint constraintWithItem:_btnRegister
        attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
        toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-8.0f * ratio];
    [self addConstraint:_registerButtonBottomConstraint];
}

@end
