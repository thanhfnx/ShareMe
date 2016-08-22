//
//  RegisterViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/23/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "RegisterViewController.h"
#import "ClientSocketController.h"
#import "User.h"
#import "DLRadioButton.h"
#import "UIViewController+ResponseHandler.h"

static NSString *const kDefaultDateFormat = @"dd-MM-yyyy";
static NSString *const kDefaultDate = @"05-09-1994";
static NSString *const kDefaultMessageTitle = @"Warning";
static NSString *const kFailedRegisterMessage = @"UserName or email is already exist. Register failed!";
static NSString *const kEmptyDateOfBirthTextFieldText = @"No date selected";
static NSString *const kEmptyFirstNameMessage = @"First name can not be empty!";
static NSString *const kEmptyLastNameMessage = @"Last name can not be empty!";
static NSString *const kEmptyEmailMessage = @"Email can not be empty!";
static NSString *const kEmailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
static NSString *const kInvalidEmailMessage = @"Email format is invalid!";
static NSString *const kEmptyUserNameMessage = @"UserName can not be empty!";
static NSString *const kEmptyDateOfBirthMessage = @"Date of birth can not be empty!";
static NSString *const kEmptyGenderMessage = @"Please choose your gender!";
static NSString *const kUserNameRegex = @"[A-Z0-9a-z._]{6,50}";
static NSString *const kInvalidUserNameMessage
    = @"Username can not be less than 6 characters and can not contain special characters!";
static NSString *const kEmptyPasswordMessage = @"Password can not be empty!";
static NSString *const kInvalidPasswordMessage = @"Password can not be less than 6 characters!";
static NSString *const kEmptyRetypePasswordMessage = @"Retype password can not be empty!";
static NSString *const kNotMatchRetypePasswordMessage = @"Password and retype password have to be the same!";

@interface RegisterViewController () {
    NSDate *_currentDate;
    NSDateFormatter *_dateFormatter;
    int _currentPage;
    THDatePickerViewController *_datePicker;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtDateOfBirth;
@property (weak, nonatomic) IBOutlet DLRadioButton *rdbGender;
@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtRetypePassword;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastButtonBottomConstraint;

@end

@implementation RegisterViewController

#pragma mark - UIView Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"RegisterView" owner:self options:nil];
    UIView *view;
    for (int i = 0; i < nibObjects.count; i++) {
        view = nibObjects[i];
        CGRect screenRect = self.view.frame;
        screenRect.origin.x += screenRect.size.width * i;
        view.frame = screenRect;
        [_scrollView addSubview:view];
    }
    _currentPage = 0;
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:kDefaultDateFormat];
    _currentDate = [_dateFormatter dateFromString:kDefaultDate];
}

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
    if (textField == _txtFirstName) {
        if ([_txtFirstName.text isEqualToString:@""]) {
            [self showMessage:kEmptyFirstNameMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [_txtFirstName becomeFirstResponder];
            }];
            return NO;
        }
        [_txtLastName becomeFirstResponder];
    } else if (textField == _txtLastName) {
        if ([_txtLastName.text isEqualToString:@""]) {
            [self showMessage:kEmptyLastNameMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [_txtLastName becomeFirstResponder];
            }];
            return NO;
        }
        [self btnNextToViewTapped:nil];
    } else if (textField == _txtEmail) {
        if ([_txtEmail.text isEqualToString:@""]) {
            [self showMessage:kEmptyEmailMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [_txtEmail becomeFirstResponder];
            }];
            return NO;
        }
        NSString *emailRegex = kEmailRegex;
        NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
        if ([emailPredicate evaluateWithObject:_txtEmail.text] != YES) {
            [self showMessage:kInvalidEmailMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [_txtEmail becomeFirstResponder];
            }];
            return NO;
        }
        [self txtDateOfBirthTapped:nil];
    } else if (textField == _txtUserName) {
        if ([_txtUserName.text isEqualToString:@""]) {
            [self showMessage:kEmptyUserNameMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [_txtUserName becomeFirstResponder];
            }];
            return NO;
        }
        NSString *userNameRegex = kUserNameRegex;
        NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userNameRegex];
        if ([userNamePredicate evaluateWithObject:_txtUserName.text] != YES) {
            [self showMessage:kInvalidUserNameMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [_txtUserName becomeFirstResponder];
            }];
            return NO;
        }
        [_txtPassword becomeFirstResponder];
    } else if (textField == _txtPassword) {
        if ([_txtPassword.text isEqualToString:@""]) {
            [self showMessage:kEmptyPasswordMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [_txtPassword becomeFirstResponder];
            }];
            return NO;
        }
        if (_txtPassword.text.length < 6) {
            [self showMessage:kInvalidPasswordMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [_txtPassword becomeFirstResponder];
            }];
            return NO;
        }
        [_txtRetypePassword becomeFirstResponder];
    } else {
        if ([_txtRetypePassword.text isEqualToString:@""]) {
            [self showMessage:kEmptyRetypePasswordMessage title:kDefaultMessageTitle
                complete:^(UIAlertAction *action) {
                [_txtRetypePassword becomeFirstResponder];
            }];
            return NO;
        }
        if (![_txtPassword.text isEqualToString:_txtRetypePassword.text]) {
            [self showMessage:kNotMatchRetypePasswordMessage title:kDefaultMessageTitle
                complete:^(UIAlertAction *action) {
                [_txtRetypePassword becomeFirstResponder];
            }];
            return NO;
        }
        [self btnRegisterTapped:nil];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == _txtDateOfBirth) {
        [textField resignFirstResponder];
        [self txtDateOfBirthTapped:nil];
        return NO;
    }
    return YES;
}

#pragma mark - Packing Entity

- (User *)getUser{
    User *user = [[User alloc] init];
    user.userName = _txtUserName.text;
    user.password = _txtPassword.text;
    user.firstName = _txtFirstName.text;
    user.lastName = _txtLastName.text;
    user.email = _txtEmail.text;
    user.dateOfBirth = _txtDateOfBirth.text;
    user.gender = [NSNumber numberWithBool:_rdbGender.selected];
    return user;
}

#pragma mark - Validating Data

- (BOOL)validate {
    if (_currentPage == 0) {
        if ([_txtFirstName.text isEqualToString:@""]) {
            [self showMessage:kEmptyFirstNameMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [_txtFirstName becomeFirstResponder];
            }];
            return NO;
        }
        if ([_txtLastName.text isEqualToString:@""]) {
            [self showMessage:kEmptyLastNameMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [_txtLastName becomeFirstResponder];
            }];
            return NO;
        }
    } else if (_currentPage == 1) {
        if ([_txtEmail.text isEqualToString:@""]) {
            [self showMessage:kEmptyEmailMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [_txtEmail becomeFirstResponder];
            }];
            return NO;
        }
        NSString *emailRegex = kEmailRegex;
        NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
        if ([emailPredicate evaluateWithObject:_txtEmail.text] != YES) {
            [self showMessage:kInvalidEmailMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [_txtEmail becomeFirstResponder];
            }];
            return NO;
        }
        if ([_txtDateOfBirth.text isEqualToString:@""]) {
            [self showMessage:kEmptyDateOfBirthMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [self txtDateOfBirthTapped:nil];
            }];
            return NO;
        }
        if (_rdbGender.selectedButton == nil) {
            [self showMessage:kEmptyGenderMessage title:kDefaultMessageTitle complete:nil];
            return NO;
        }
    } else if (_currentPage == 2) {
        if ([_txtUserName.text isEqualToString:@""]) {
            [self showMessage:kEmptyUserNameMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [_txtUserName becomeFirstResponder];
            }];
            return NO;
        }
        NSString *userNameRegex = kUserNameRegex;
        NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userNameRegex];
        if ([userNamePredicate evaluateWithObject:_txtUserName.text] != YES) {
            [self showMessage:kInvalidUserNameMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [_txtUserName becomeFirstResponder];
            }];
            return NO;
        }
        if ([_txtPassword.text isEqualToString:@""]) {
            [self showMessage:kEmptyPasswordMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [_txtPassword becomeFirstResponder];
            }];
            return NO;
        }
        if (_txtPassword.text.length < 6) {
            [self showMessage:kInvalidPasswordMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [_txtPassword becomeFirstResponder];
            }];
            return NO;
        }
        if ([_txtRetypePassword.text isEqualToString:@""]) {
            [self showMessage:kEmptyRetypePasswordMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [_txtRetypePassword becomeFirstResponder];
            }];
            return NO;
        }
        if (![_txtPassword.text isEqualToString:_txtRetypePassword.text]) {
            [self showMessage:kNotMatchRetypePasswordMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
                [_txtRetypePassword becomeFirstResponder];
            }];
            return NO;
        }
    }
    return YES;
}

#pragma mark - IBAction

- (IBAction)btnRegisterTapped:(UIButton *)sender {
    [self dismissKeyboard];
    if ([self validate]) {
        [ClientSocketController sendData:[self getUser] messageType:kSendingRequestSignal
            actionName:kUserRegisterAction sender:self];
    }
}

- (IBAction)btnNextToViewTapped:(UIButton *)sender {
    if ([self validate]) {
        CGRect screenRect = self.view.frame;
        screenRect.origin.x = screenRect.size.width;
        _currentPage++;
        [self dismissKeyboard];
        [UIView animateWithDuration:0.3 animations:^{
            _scrollView.contentOffset = CGPointMake(screenRect.size.width * _currentPage, 0.0f);
        }];
    }
}

- (IBAction)btnBackToViewTapped:(UIButton *)sender {
    CGRect screenRect = self.view.frame;
    screenRect.origin.x = screenRect.size.width;
    _currentPage--;
    [UIView animateWithDuration:0.3 animations:^{
        _scrollView.contentOffset = CGPointMake(screenRect.size.width * _currentPage, 0.0f);
    }];
}

- (IBAction)tapGestureRecognizer:(UITapGestureRecognizer *)sender {
    [self dismissKeyboard];
}

- (IBAction)btnLoginTapped:(UIButton *)sender {
    [self dismissKeyboard];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)txtDateOfBirthTapped:(UITextField *)sender {
    [self dismissKeyboard];
    if (!_datePicker) {
        _datePicker = [THDatePickerViewController datePicker];
        _datePicker.date = _currentDate;
        _datePicker.delegate = self;
        [_datePicker setAllowClearDate:YES];
        [_datePicker setClearAsToday:YES];
        [_datePicker setAutoCloseOnSelectDate:YES];
        [_datePicker setAllowSelectionOfSelectedDate:YES];
        [_datePicker setDisableHistorySelection:NO];
        [_datePicker setDisableFutureSelection:YES];
        [_datePicker setSelectedBackgroundColor:[UIColor colorWithRed:125.0f / 255.0f
            green:208.0f / 255.0f blue:0.0f / 255.0f alpha:1.0f]];
        [_datePicker setCurrentDateColor:[UIColor colorWithRed:242.0f / 255.0f green:121.0f / 255.0f
            blue:53.0f / 255.0f alpha:1.0f]];
        [_datePicker setDateHasItemsCallback:^BOOL(NSDate *date) {
            int tmp = (arc4random() % 30) + 1;
            if(tmp % 5 == 0)
                return YES;
            return NO;
        }];
    }
    [self presentSemiViewController:_datePicker withOptions:@{KNSemiModalOptionKeys.pushParentBack: @(NO),
        KNSemiModalOptionKeys.animationDuration: @(0.5f), KNSemiModalOptionKeys.shadowOpacity: @(0.3f)}];
}

- (void)dismissKeyboard {
    [_scrollView endEditing:YES];
}

- (void)showMessage:(NSString *)message title:(NSString *)title
        complete:(void (^ _Nullable)(UIAlertAction *action))complete {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message
        preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel
        handler:complete];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    if (scrollView.contentOffset.x != screenWidth * _currentPage) {
        [scrollView setContentOffset:CGPointMake(screenWidth * _currentPage, scrollView.contentOffset.y)];
    }
}

#pragma mark - THDatePickerDelegate

- (void)datePickerDonePressed:(THDatePickerViewController *)datePicker {
    _currentDate = datePicker.date;
    [self refreshDateOfBirthTextField];
    [self dismissSemiModalView];
}

- (void)datePickerCancelPressed:(THDatePickerViewController *)datePicker {
    [self dismissSemiModalView];
}

-(void)refreshDateOfBirthTextField {
    _txtDateOfBirth.text = (_currentDate ?
    [_dateFormatter stringFromDate:_currentDate] : kEmptyDateOfBirthTextFieldText);
}

#pragma mark - Show / hide keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect theFrame = self.view.frame;
        CGFloat offset = _lblTitle.frame.origin.y + _lblTitle.frame.size.height;
        _lastButtonBottomConstraint.constant = keyboardSize.height + 8.0f - offset;
        theFrame.origin.y = -offset;
        self.view.frame = theFrame;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    __block CGRect frame = self.view.frame;
    [UIView animateWithDuration:0.3 animations:^{
        _lastButtonBottomConstraint.constant = 8.0f;
        frame.origin.y = 0.0f;
        self.view.frame = frame;
    }];
}

#pragma mark - Response Handler

- (void)handleResponse:(NSArray *)result {
    if ([result[2] isEqualToString:kFailureMessage]) {
        [self showMessage:kFailedRegisterMessage title:kDefaultMessageTitle complete:nil];
    } else {
        [self.navigationController popToRootViewControllerAnimated:NO];
        [ClientSocketController sendData:[self getUser] messageType:kSendingRequestSignal actionName:kUserLoginAction
            sender:self.navigationController.viewControllers[0]];
    }
}

@end
