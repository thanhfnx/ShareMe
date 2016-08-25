//
//  RequestsTableViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/24/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "RequestsTableViewController.h"
#import "MainTabBarViewController.h"
#import "ReceivedRequestTableViewCell.h"
#import "SentRequestTableViewCell.h"
#import "ClientSocketController.h"
#import "UIViewController+RequestHandler.h"
#import "UIViewController+ResponseHandler.h"
#import "User.h"

typedef NS_ENUM(NSInteger, UserRequestActions) {
    UserSendRequestToUserAction,
    UserDeclineRequestToUserAction,
    UserCancelRequestToUserAction,
    UserAddFriendToUserAction
};

typedef NS_ENUM(NSInteger, UserResponseActions) {
    UserAcceptRequestAction,
    UserDeclineRequestAction,
    UserCancelRequestAction,
};

typedef NS_ENUM(NSInteger, RequestSections) {
    ReceivedRequestSection,
    SentRequestSection,
    RequestSectionsCount
};

static NSString *const kReceivedRequestReuseIdentifier = @"ReceivedRequestCell";
static NSString *const kSentRequestReuseIdentifier = @"SentRequestCell";
static NSString *const kRequestFormat = @"%ld-%ld";
static NSString *const kDefaultMessageTitle = @"Warning";
static NSString *const kAcceptRequestErrorMessage = @"Something went wrong! Can not accept friend request!";
static NSString *const kDeclineRequestErrorMessage = @"Something went wrong! Can not decline friend request!";
static NSString *const kCancelRequestErrorMessage = @"Something went wrong! Can not cancel friend request!";

@interface RequestsTableViewController () {
    User *_currentUser;
    NSArray<User *> *_receivedRequests;
    NSArray<User *> *_sentRequests;
    NSArray<NSString *> *_requestActions;
    NSArray<NSString *> *_responseActions;
}

@end

@implementation RequestsTableViewController

#pragma mark - UIView Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerRequestHandler];
    _requestActions = @[
        kUserSendRequestToUserAction,
        kUserDeclineRequestToUserAction,
        kUserCancelRequestToUserAction,
        kUserAddFriendToUserAction
    ];
    _responseActions = @[
        kUserAcceptRequestAction,
        kUserDeclineRequestAction,
        kUserCancelRequestAction
    ];
    _currentUser = ((MainTabBarViewController *)self.navigationController.tabBarController).loggedInUser;
    _receivedRequests = _currentUser.receivedRequests;
    _sentRequests = _currentUser.sentRequests;
    self.tableView.estimatedRowHeight = 80.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDatasource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return RequestSectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRowsInSection = 0;
    switch (section) {
        case ReceivedRequestSection:
            numberOfRowsInSection = _receivedRequests.count;
            break;
        case SentRequestSection:
            numberOfRowsInSection = _sentRequests.count;
            break;
    }
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case ReceivedRequestSection: {
            ReceivedRequestTableViewCell *cell = [tableView
                dequeueReusableCellWithIdentifier:kReceivedRequestReuseIdentifier forIndexPath:indexPath];
            if (cell) {
                [cell setUser:_receivedRequests[indexPath.row]];
                cell.btnAccept.tag = indexPath.row;
                cell.btnDecline.tag = indexPath.row;
                return cell;
            }
        }
        case SentRequestSection: {
            SentRequestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSentRequestReuseIdentifier
                forIndexPath:indexPath];
            if (cell) {
                [cell setUser:_sentRequests[indexPath.row]];
                cell.btnCancel.tag = indexPath.row;
                return cell;
            }
        }
    }
    return [UITableViewCell new];
}

#pragma mark - IBAction

- (IBAction)btnAcceptTapped:(UIButton *)sender {
    NSInteger index = sender.tag;
    NSString *data = [NSString stringWithFormat:kRequestFormat, _currentUser.userId.integerValue,
        _receivedRequests[index].userId.integerValue];
    [ClientSocketController sendData:data messageType:kSendingRequestSignal actionName:kUserAcceptRequestAction
        sender:self];
}

- (IBAction)btnDeclineTapped:(UIButton *)sender {
    NSInteger index = sender.tag;
    NSString *data = [NSString stringWithFormat:kRequestFormat, _currentUser.userId.integerValue,
        _receivedRequests[index].userId.integerValue];
    [ClientSocketController sendData:data messageType:kSendingRequestSignal actionName:kUserDeclineRequestAction
        sender:self];
}

- (IBAction)btnCancelTapped:(UIButton *)sender {
    NSInteger index = sender.tag;
    NSString *data = [NSString stringWithFormat:kRequestFormat, _currentUser.userId.integerValue,
        _sentRequests[index].userId.integerValue];
    [ClientSocketController sendData:data messageType:kSendingRequestSignal actionName:kUserCancelRequestAction
        sender:self];
}

- (void)showMessage:(NSString *)message title:(NSString *)title
        complete:(void (^ _Nullable)(UIAlertAction *action))complete {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message
        preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:complete];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Request Handler

- (void)registerRequestHandler {
    [ClientSocketController registerRequestHandler:kUserSendRequestToUserAction receiver:self];
    [ClientSocketController registerRequestHandler:kUserCancelRequestToUserAction receiver:self];
    [ClientSocketController registerRequestHandler:kUserAddFriendToUserAction receiver:self];
    [ClientSocketController registerRequestHandler:kUserDeclineRequestToUserAction receiver:self];
}

- (void)handleRequest:(NSString *)actionName message:(NSString *)message {
    NSError *error;
    User *user = [[User alloc] initWithString:message error:&error];
    NSInteger index = [_requestActions indexOfObject:actionName];
    switch (index) {
        case UserSendRequestToUserAction:
            [self addUserIfNotExist:_currentUser.receivedRequests user:user];
            break;
        case UserCancelRequestToUserAction:
            [self removeUser:_currentUser.receivedRequests user:user];
            break;
        case UserAddFriendToUserAction:
            [self addUserIfNotExist:_currentUser.friends user:user];
            [self removeUser:_currentUser.sentRequests user:user];
            break;
        case UserDeclineRequestToUserAction:
            [self removeUser:_currentUser.sentRequests user:user];
            break;
    }
    if (self.isViewLoaded && self.view.window) {
        [self.tableView reloadData];
    }
}

#pragma mark - Process Entity

- (void)addUserIfNotExist:(NSMutableArray *)array user:(User *)user {
    BOOL isExist = NO;
    for (User *temp in array) {
        if (temp.userId == user.userId) {
            isExist = YES;
            break;
        }
    }
    if (!isExist) {
        [array addObject:user];
    }
}

- (void)removeUser:(NSMutableArray *)array user:(User *)user {
    for (User *temp in array) {
        if (temp.userId == user.userId) {
            [array removeObject:temp];
            break;
        }
    }
}

#pragma mark - Response Handler

- (void)handleResponse:(NSString *)actionName message:(NSString *)message {
    NSInteger index = [_responseActions indexOfObject:actionName];
    switch (index) {
        case UserAcceptRequestAction:
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kAcceptRequestErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                User *user = [[User alloc] initWithString:message error:&error];
                [self removeUser:_currentUser.receivedRequests user:user];
                [self.tableView reloadData];
            }
            break;
        case UserDeclineRequestAction:
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kDeclineRequestErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                User *user = [[User alloc] initWithString:message error:&error];
                [self removeUser:_currentUser.receivedRequests user:user];
                [self.tableView reloadData];
            }
            break;
        case UserCancelRequestAction:
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kCancelRequestErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                User *user = [[User alloc] initWithString:message error:&error];
                [self removeUser:_currentUser.sentRequests user:user];
                [self.tableView reloadData];
            }
            break;
    }
}

@end
