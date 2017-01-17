//
//  MessagesViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/28/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <CCBottomRefreshControl/UIScrollView+BottomRefreshControl.h>
#import "MessagesViewController.h"
#import "User.h"
#import "Message.h"
#import "ClientSocketController.h"
#import "UIViewConstant.h"
#import "MainTabBarViewController.h"
#import "FDateFormatter.h"
#import "MessageTableViewCell.h"
#import "MessageDetailViewController.h"
#import "Utils.h"

typedef NS_ENUM(NSInteger, UserResponseActions) {
    UserGetLatestMessagesAction
};

typedef NS_ENUM(NSInteger, UserRequestActions) {
    AddNewMessageToUserAction
};

@interface MessagesViewController () {
    NSMutableArray<Message *> *_latestMessages;
    NSArray<NSString *> *_responseActions;
    NSArray<NSString *> *_requestActions;
    User *_currentUser;
    NSInteger _startIndex;
    UIRefreshControl *_bottomRefreshControl;
    NSInteger _selectedIndex;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    _isSwipeGestureDisable = YES;
    [super viewDidLoad];
    CGRect frame = self.navigationItem.titleView.frame;
    frame.size.width = [UIViewConstant screenWidth];
    self.navigationItem.titleView.frame = frame;
    _latestMessages = [NSMutableArray array];
    _requestActions = @[kAddNewMessageToUserAction];
    [self registerRequestHandler];
    _currentUser = ((MainTabBarViewController *)self.navigationController.tabBarController).loggedInUser;
    [self loadLatestMessages];
    _bottomRefreshControl = [UIRefreshControl new];
    _bottomRefreshControl.triggerVerticalOffset = 50.0f;
    [_bottomRefreshControl addTarget:self action:@selector(loadLatestMessages)
        forControlEvents:UIControlEventValueChanged];
    self.tableView.bottomRefreshControl = _bottomRefreshControl;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewMessage:)
        name:kUpdateMessagesNotificationName object:nil];
}

- (void)loadLatestMessages {
    _startIndex = _latestMessages.count;
    NSString *message = [NSString stringWithFormat:kGetLatestMessagesFormat, _currentUser.userId.integerValue,
        _startIndex, kNumberOfLatestMessages];
    [[ClientSocketController sharedController] sendData:message messageType:kSendingRequestSignal
        actionName:kUserGetLatestMessagesAction sender:self];
}

#pragma mark - UITableViewDatasource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!_latestMessages.count) {
        return 1;
    }
    return _latestMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_latestMessages.count) {
        return [Utils emptyTableCell:kEmptyRecentMessagesTableViewMessage];
    }
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMessageReuseIdentifier
        forIndexPath:indexPath];
    if (!cell) {
        return [UITableViewCell new];
    }
    [cell setMessage:_latestMessages[indexPath.row] currentUser:_currentUser];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_latestMessages.count) {
        return tableView.frame.size.height;
    }
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!_latestMessages.count) {
        return;
    }
    _selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:kGoToMessageDetailSegueIdentifier sender:self];
}

- (void)addNewMessage:(NSNotification *)notification {
    Message *newMessage = [[notification userInfo] valueForKey:kNewMessageKey];
    if (!newMessage) {
        return;
    }
    if (!_latestMessages.count) {
        [_latestMessages insertObject:newMessage atIndex:0];
        return;
    }
    for (Message *message in _latestMessages) {
        BOOL isNewSentMessage = message.sender.userId == newMessage.sender.userId
            && message.receiver.userId == newMessage.receiver.userId;
        BOOL isNewReceivedMessage = message.sender.userId == newMessage.receiver.userId
            && message.receiver.userId == newMessage.sender.userId;
        if (isNewSentMessage || isNewReceivedMessage) {
            [_latestMessages removeObject:message];
            [_latestMessages insertObject:newMessage atIndex:0];
            [self.tableView reloadData];
            break;
        }
    }
}

#pragma mark - Response Handler

- (void)handleResponse:(NSString *)actionName message:(NSString *)message {
    NSInteger index = [_responseActions indexOfObject:actionName];
    switch (index) {
        case UserGetLatestMessagesAction: {
            if (![message isEqualToString:kFailureMessage]) {
                NSError *error;
                NSArray *array = [Message arrayOfModelsFromString:message error:&error];
                if (error) {
                    return;
                }
                [_latestMessages addObjectsFromArray:array];
                [self.tableView reloadData];
            }
            if ([_bottomRefreshControl isRefreshing]) {
                [_bottomRefreshControl endRefreshing];
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
            if (error || !receivedMessage) {
                return;
            }
            for (Message *message in _latestMessages) {
                BOOL isNewSentMessage = message.sender.userId == receivedMessage.sender.userId
                    && message.receiver.userId == receivedMessage.receiver.userId;
                BOOL isNewReceivedMessage = message.sender.userId == receivedMessage.receiver.userId
                    && message.receiver.userId == receivedMessage.sender.userId;
                if (isNewSentMessage || isNewReceivedMessage) {
                    [_latestMessages removeObject:message];
                    [_latestMessages insertObject:receivedMessage atIndex:0];
                    [self.tableView reloadData];
                    break;
                }
            }
            break;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:kGoToMessageDetailSegueIdentifier]) {
        MessageDetailViewController *messageDetailViewController = [segue destinationViewController];
        Message *selectedMessage = _latestMessages[_selectedIndex];
        if (_currentUser.userId == selectedMessage.sender.userId) {
            messageDetailViewController.receiver = selectedMessage.receiver;
        } else if (_currentUser.userId == selectedMessage.receiver.userId) {
            messageDetailViewController.receiver = selectedMessage.sender;
        }
    }
}

@end
