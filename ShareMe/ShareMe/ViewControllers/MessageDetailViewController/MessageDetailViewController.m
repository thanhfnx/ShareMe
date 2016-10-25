//
//  MessageDetailViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/28/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "MessageDetailTableViewCell.h"
#import "MainTabBarViewController.h"
#import "ClientSocketController.h"
#import "ApplicationConstants.h"
#import "UITableView+ScrollHelpers.h"
#import "Message.h"
#import "FDateFormatter.h"
#import "NSDate+TimeDiff.h"
#import "Utils.h"
#import "User.h"

typedef NS_ENUM(NSInteger, UserResponseActions) {
    UserGetMessagesAction,
    UserCreateNewMessageAction
};

typedef NS_ENUM(NSInteger, UserRequestActions) {
    AddNewMessageToUserAction
};

@interface MessageDetailViewController () {
    NSMutableArray<Message *> *_messages;
    Message *_message;
    NSInteger _startIndex;
    NSArray<NSString *> *_responseActions;
    NSArray<NSString *> *_requestActions;
    User *_currentUser;
    NSDateFormatter *_dateFormatter;
    UIRefreshControl *_topRefreshControl;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *txvNewMessage;
@property (weak, nonatomic) IBOutlet UILabel *lblPlaceHolder;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addMessageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *lblHeaderTitle;

@end

@implementation MessageDetailViewController

#pragma mark - UIView Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lblHeaderTitle.text = [self.receiver fullName];
    CGRect frame = self.navigationItem.titleView.frame;
    frame.size.width = [UIViewConstant screenWidth];
    self.navigationItem.titleView.frame = frame;
    [self.txvNewMessage becomeFirstResponder];
    _messages = [NSMutableArray array];
    _responseActions = @[
        kUserGetMessagesAction,
        kUserCreateNewMessageAction
    ];
    _requestActions = @[kAddNewMessageToUserAction];
    [self registerRequestHandler];
    _currentUser = ((MainTabBarViewController *)self.navigationController.tabBarController).loggedInUser;
    _dateFormatter = [FDateFormatter sharedDateFormatter];
    _dateFormatter.dateFormat = kDefaultDateTimeFormat;
    [self loadMessages];
    _topRefreshControl = [[UIRefreshControl alloc] init];
    [_topRefreshControl addTarget:self action:@selector(loadMessages) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_topRefreshControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
        name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
        name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController && ![self.navigationController.viewControllers containsObject:self]) {
        [self resignRequestHandler];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadMessages {
    _startIndex = _messages.count;
    [[ClientSocketController sharedController] sendData:[NSString stringWithFormat:kGetMessagesFormat,
        _currentUser.userId.integerValue, self.receiver.userId.integerValue, _startIndex, kNumberOfMessages]
        messageType:kSendingRequestSignal actionName:kUserGetMessagesAction sender:self];
}

#pragma mark - Packing entity

- (void)getMessage {
    _message = [[Message alloc] init];
    User *sender = [[User alloc] init];
    sender.userId = _currentUser.userId;
    User *receiver = [[User alloc] init];
    receiver.userId = self.receiver.userId;
    _message.sender = sender;
    _message.receiver = receiver;
    _message.content = self.txvNewMessage.text;
    _dateFormatter.dateFormat = kDefaultDateTimeFormat;
    _message.sentTime = [_dateFormatter stringFromDate:[NSDate date]];
}

#pragma mark - IBAction

- (IBAction)btnBackTapped:(UIButton *)sender {
    if ([self.txvNewMessage hasText]) {
        [self showConfirmDialog:kConfirmDiscardMessage title:kConfirmMessageTitle handler:^(UIAlertAction *action) {
            [self dismissKeyboard];
            [self.navigationController popViewControllerAnimated:YES];
            [self.navigationController.tabBarController setSelectedIndex:kMessagesViewControllerIndex];
        }];
    } else {
        [self dismissKeyboard];
        [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController.tabBarController setSelectedIndex:kMessagesViewControllerIndex];
    }
}

- (IBAction)btnSendTapped:(UIButton *)sender {
    if ([self.txvNewMessage hasText]) {
        [self getMessage];
        [[ClientSocketController sharedController] sendData:[_message toJSONString] messageType:kSendingRequestSignal
            actionName:kUserCreateNewMessageAction sender:self];
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.lblPlaceHolder.hidden = [self.txvNewMessage hasText];
}

#pragma mark - UITableViewDatasource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!_messages.count) {
        return 1;
    }
    return _messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_messages.count) {
        return [Utils emptyTableCell:kEmptyMessagesTableViewMessage];
    }
    Message *message = _messages[indexPath.row];
    NSString *reuseIdentifier = kFriendMessageReuseIdentifier;
    message.sender.avatarImage = self.receiver.avatarImage;
    if (message.receiver.userId.integerValue == self.receiver.userId.integerValue) {
        reuseIdentifier = kSelfMessageReuseIdentifier;
        message.sender.avatarImage = _currentUser.avatarImage;
    }
    MessageDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier
        forIndexPath:indexPath];
    if (!cell) {
        return [UITableViewCell new];
    }
    BOOL isFirstMessageOfTheDay = YES;
    if (indexPath.row) {
        _dateFormatter.dateFormat = kDefaultDateTimeFormat;
        NSDate *currentMessageSentTime = [_dateFormatter dateFromString:message.sentTime];
        NSDate *previousMessageSentTime = [_dateFormatter dateFromString:_messages[indexPath.row - 1].sentTime];
        isFirstMessageOfTheDay = ![[NSCalendar currentCalendar] isDate:currentMessageSentTime
            inSameDayAsDate:previousMessageSentTime];
    }
    [cell setMessage:message isFirstMessageOfTheDay:isFirstMessageOfTheDay];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_messages.count) {
        return tableView.frame.size.height;
    }
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)reloadDataWithAnimated:(BOOL)animated {
    [self.tableView reloadData];
    [self updateContentInset];
    [self.tableView scrollToBottom:animated];
}

- (void)updateContentInset {
    [self.tableView layoutIfNeeded];
    CGFloat topInset = MAX(CGRectGetHeight(self.tableView.frame) - self.tableView.contentSize.height, 0.0f);
    self.tableView.contentInset = UIEdgeInsetsMake(topInset + 4.0f, 0.0f, 4.0f, 0.0f);
}

#pragma mark - Show / hide keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey]
        doubleValue];
    [UIView animateWithDuration:duration animations:^{
        CGFloat offset = keyboardSize.height;
        self.addMessageViewBottomConstraint.constant += offset;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey]
        doubleValue];
    [UIView animateWithDuration:duration animations:^{
        self.addMessageViewBottomConstraint.constant = 0.0f;
    }];
}

#pragma mark - Response Handler

- (void)handleResponse:(NSString *)actionName message:(NSString *)message {
    NSInteger index = [_responseActions indexOfObject:actionName];
    switch (index) {
        case UserGetMessagesAction: {
            if (![message isEqualToString:kFailureMessage]) {
                NSError *error;
                NSMutableArray *array = [Message arrayOfModelsFromString:message error:&error];
                if (error) {
                    return;
                }
                array = [[[array reverseObjectEnumerator] allObjects] mutableCopy];
                [array addObjectsFromArray:_messages];
                [_messages removeAllObjects];
                [_messages addObjectsFromArray:array];
                if (_startIndex) {
                    [self.tableView reloadData];
                } else {
                    [self reloadDataWithAnimated:NO];
                }
            }
            [_topRefreshControl endRefreshing];
            break;
        }
        case UserCreateNewMessageAction: {
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kAddNewMessageErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                _message.messageId = @(message.integerValue);
                [_messages addObject:_message];
                [self.txvNewMessage setText:@""];
                self.lblPlaceHolder.hidden = NO;
                [self reloadDataWithAnimated:YES];
            }
            break;
        }
    }
}

#pragma mark - Request Handler

- (void)registerRequestHandler {
    for (NSString *action in _requestActions) {
        [[ClientSocketController sharedController] registerRequestHandler:action receiver:self];
    }
}

- (void)resignRequestHandler {
    for (NSString *action in _requestActions) {
        [[ClientSocketController sharedController] resignRequestHandler:action receiver:self];
    }
}

- (void)handleRequest:(NSString *)actionName message:(NSString *)message {
    NSInteger index = [_requestActions indexOfObject:actionName];
    switch (index) {
        case AddNewMessageToUserAction: {
            NSError *error;
            Message *receivedMessage = [[Message alloc] initWithString:message error:&error];
            if (error) {
                return;
            }
            if (receivedMessage && ((receivedMessage.sender.userId == self.receiver.userId &&
                receivedMessage.receiver.userId == _currentUser.userId) || (receivedMessage.receiver.userId ==
                self.receiver.userId && receivedMessage.sender.userId == _currentUser.userId))) {
                [_messages addObject:receivedMessage];
                [self reloadDataWithAnimated:YES];
            }
            break;
        }
    }
}

@end
