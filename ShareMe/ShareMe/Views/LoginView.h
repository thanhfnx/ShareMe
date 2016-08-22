//
//  LoginView.h
//  SocialNetwork
//
//  Created by Nguyen Xuan Thanh on 7/27/16.
//  Copyright © 2016 Nguyen Xuan Thanh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginView : UIView

@property (nonatomic) UIImageView *imvLogo;
@property (nonatomic) UITextField *txtUserName;
@property (nonatomic) UITextField *txtPassword;
@property (nonatomic) UIButton *btnLogin;
@property (nonatomic) UIButton *btnForgotPassword;
@property (nonatomic) UIButton *btnRegister;
@property (nonatomic) NSLayoutConstraint *registerButtonBottomConstraint;

@end
