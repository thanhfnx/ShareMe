//
//  WhoLikeThisViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/21/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "WhoLikeThisViewController.h"
#import "UIViewController+RequestHandler.h"
#import "UIViewController+ResponseHandler.h"
#import "ClientSocketController.h"
#import "SearchFriendTableViewCell.h"
#import "User.h"
#import "MainTabBarViewController.h"
#import "Utils.h"

typedef NS_ENUM(NSInteger, Relations) {
    FriendRelation,
    SentRequestRelation,
    ReceivedRequestRelation,
    NotFriendRelation,
    SelfRelation
};

typedef NS_ENUM(NSInteger, UserRequestActions) {
    UserUnfriendToUserAction,
    UserSendRequestToUserAction,
    UserDeclineRequestToUserAction,
    UserCancelRequestToUserAction,
    UserAddFriendToUserAction,
    AddAcceptRequestToClientsAction,
    AddDeclineRequestToClientsAction,
    AddCancelRequestToClientsAction,
    AddSendRequestToClientsAction,
    AddUnfriendToClientsAction,
    UpdateLikedUsersAction
};

typedef NS_ENUM(NSInteger, UserResponseActions) {
    UserGetLikedUsersAction,
    UserAcceptRequestAction,
    UserDeclineRequestAction,
    UserCancelRequestAction,
    UserSendRequestAction,
    UserUnfriendAction,
    GetUserByIdAction
};

static NSString *const kLikedUserReuseIdentifier = @"LikedUserCell";
static NSString *const kConfirmMessageTitle = @"Confirm";
static NSString *const kRequestFormat = @"%ld-%ld";
static NSString *const kConfirmUnfriendMessage = @"Do you really want to unfriend %@?";
static NSString *const kConfirmCancelRequestMessage = @"Do you really want to cancel friend request to %@?";
static NSString *const kConfirmAcceptMessage = @"Do you want to accept %@'s friend request?";
static NSString *const kAcceptButtonTitle = @"Accept";
static NSString *const kDeclineButtonTitle = @"Decline";
static NSString *const kDefaultMessageTitle = @"Warning";
static NSString *const kAcceptRequestErrorMessage = @"Something went wrong! Can not accept friend request!";
static NSString *const kDeclineRequestErrorMessage = @"Something went wrong! Can not decline friend request!";
static NSString *const kCancelRequestErrorMessage = @"Something went wrong! Can not cancel friend request!";
static NSString *const kSendRequestErrorMessage = @"Something went wrong! Can not send friend request!";
static NSString *const kUnfriendErrorMessage = @"Something went wrong! Can not unfriend!";
static NSString *const kGetLikedUsersErrorMessage = @"Something went wrong! Can not get liked users!";

@interface WhoLikeThisViewController () {
    User *_currentUser;
    NSMutableArray<User *> *_users;
    NSMutableArray<NSNumber *> *_relationStatuses;
    NSArray<NSString *> *_requestActions;
    NSArray<NSString *> *_responseActions;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation WhoLikeThisViewController

#pragma mark - UIView Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _requestActions = @[
        kUserUnfriendToUserAction,
        kUserSendRequestToUserAction,
        kUserDeclineRequestToUserAction,
        kUserCancelRequestToUserAction,
        kUserAddFriendToUserAction,
        kAddAcceptRequestToClientsAction,
        kAddDeclineRequestToClientsAction,
        kAddCancelRequestToClientsAction,
        kAddSendRequestToClientsAction,
        kAddUnfriendToClientsAction,
        kUpdateLikedUsersAction
    ];
    _responseActions = @[
        kUserGetLikedUsersAction,
        kUserAcceptRequestAction,
        kUserDeclineRequestAction,
        kUserCancelRequestAction,
        kUserSendRequestAction,
        kUserUnfriendAction,
        kGetUserByIdAction
    ];
    [self registerRequestHandler];
    _currentUser = ((MainTabBarViewController *)self.navigationController.tabBarController).loggedInUser;
    _relationStatuses = [NSMutableArray array];
    CGRect frame = self.navigationItem.titleView.frame;
    frame.size.width = [UIViewConstant screenWidth];
    self.navigationItem.titleView.frame = frame;
    [self loadLikedUsers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setRelationStatuses];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController && ![self.navigationController.viewControllers containsObject:self]) {
        [self resignRequestHandler];
    }
}

- (void)loadLikedUsers {
    [[ClientSocketController sharedController] sendData:[@(self.storyId) stringValue] messageType:kSendingRequestSignal
        actionName:kUserGetLikedUsersAction sender:self];
}

- (void)setRelationStatuses {
    [_relationStatuses removeAllObjects];
    for (User *user in _users) {
        NSInteger status = NotFriendRelation;
        if (user.userId == _currentUser.userId) {
            status = SelfRelation;
            [_relationStatuses addObject:[NSNumber numberWithInteger:status]];
            continue;
        }
        for (User *temp in _currentUser.friends) {
            if (user.userId == temp.userId) {
                status = FriendRelation;
                break;
            }
        }
        if (status != NotFriendRelation) {
            [_relationStatuses addObject:[NSNumber numberWithInteger:status]];
            continue;
        }
        for (User *temp in _currentUser.sentRequests) {
            if (user.userId == temp.userId) {
                status = SentRequestRelation;
                break;
            }
        }
        if (status != NotFriendRelation) {
            [_relationStatuses addObject:[NSNumber numberWithInteger:status]];
            continue;
        }
        for (User *temp in _currentUser.receivedRequests) {
            if (user.userId == temp.userId) {
                status = ReceivedRequestRelation;
                break;
            }
        }
        [_relationStatuses addObject:[NSNumber numberWithInteger:status]];
    }
}

#pragma mark - UITableViewDatasource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLikedUserReuseIdentifier
        forIndexPath:indexPath];
    if (!cell) {
        return [UITableViewCell new];
    }
    cell.btnAction.tag = indexPath.row;
    [cell setUser:_users[indexPath.row] relationStatus:_relationStatuses[indexPath.row].integerValue];
    [self setTapGestureRecognizer:@[cell.imvAvatar, cell.lblFullName, cell.lblUserName]
        userId:_users[indexPath.row].userId.integerValue];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - IBAction

- (IBAction)btnBackTapped:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnActionTapped:(UIButton *)sender {
    NSInteger index = sender.tag;
    switch (_relationStatuses[index].integerValue) {
        case FriendRelation: {
            NSString *fullName = [_users[index] fullName];
            NSString *data = [NSString stringWithFormat:kRequestFormat, _currentUser.userId.integerValue,
                _users[index].userId.integerValue];
            [self showConfirmDialog:[NSString stringWithFormat:kConfirmUnfriendMessage, fullName]
                title:kConfirmMessageTitle handler:^(UIAlertAction *action) {
                [[ClientSocketController sharedController] sendData:data messageType:kSendingRequestSignal
                    actionName:kUserUnfriendAction sender:self];
            }];
            break;
        }
        case SentRequestRelation: {
            NSString *fullName = [_users[index] fullName];
            NSString *data = [NSString stringWithFormat:kRequestFormat, _currentUser.userId.integerValue,
                _users[index].userId.integerValue];
            [self showConfirmDialog:[NSString stringWithFormat:kConfirmCancelRequestMessage, fullName]
                title:kConfirmMessageTitle handler:^(UIAlertAction *action) {
                [[ClientSocketController sharedController] sendData:data messageType:kSendingRequestSignal
                actionName:kUserCancelRequestAction sender:self];
            }];
            break;
        }
        case ReceivedRequestRelation: {
            NSString *fullName = [_users[index] fullName];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kConfirmMessageTitle
                message:[NSString stringWithFormat:kConfirmAcceptMessage, fullName]
                preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:kAcceptButtonTitle
                style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSString *data = [NSString stringWithFormat:kRequestFormat, _currentUser.userId.integerValue,
                    _users[index].userId.integerValue];
                [[ClientSocketController sharedController] sendData:data messageType:kSendingRequestSignal
                    actionName:kUserAcceptRequestAction sender:self];
            }];
            UIAlertAction *declineAction = [UIAlertAction actionWithTitle:kDeclineButtonTitle
                style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSString *data = [NSString stringWithFormat:kRequestFormat, _currentUser.userId.integerValue,
                    _users[index].userId.integerValue];
                [[ClientSocketController sharedController] sendData:data messageType:kSendingRequestSignal
                    actionName:kUserDeclineRequestAction sender:self];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                handler:nil];
            [alertController addAction:acceptAction];
            [alertController addAction:declineAction];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
            break;
        }
        case NotFriendRelation: {
            NSString *data = [NSString stringWithFormat:kRequestFormat, _currentUser.userId.integerValue,
                _users[index].userId.integerValue];
            [[ClientSocketController sharedController] sendData:data messageType:kSendingRequestSignal
                actionName:kUserSendRequestAction sender:self];
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
    NSError *error;
    User *user = [[User alloc] initWithString:message error:&error];
    // TODO: Handle error
    NSInteger index = [_requestActions indexOfObject:actionName];
    switch (index) {
        case UserUnfriendToUserAction: {
            [Utils removeUser:_currentUser.friends user:user];
            break;
        }
        case UserSendRequestToUserAction: {
            [Utils addUserIfNotExist:_currentUser.receivedRequests user:user];
            break;
        }
        case UserCancelRequestToUserAction: {
            [Utils removeUser:_currentUser.receivedRequests user:user];
            break;
        }
        case UserAddFriendToUserAction: {
            [Utils addUserIfNotExist:_currentUser.friends user:user];
            [Utils removeUser:_currentUser.sentRequests user:user];
            break;
        }
        case UserDeclineRequestToUserAction: {
            [Utils removeUser:_currentUser.sentRequests user:user];
            break;
        }
        case AddAcceptRequestToClientsAction: {
            [Utils removeUser:_currentUser.receivedRequests user:user];
            [Utils addUserIfNotExist:_currentUser.friends user:user];
            break;
        }
        case AddDeclineRequestToClientsAction: {
            [Utils removeUser:_currentUser.receivedRequests user:user];
            break;
        }
        case AddCancelRequestToClientsAction: {
            [Utils removeUser:_currentUser.sentRequests user:user];
            break;
        }
        case AddSendRequestToClientsAction: {
            [Utils addUserIfNotExist:_currentUser.sentRequests user:user];
            break;
        }
        case AddUnfriendToClientsAction: {
            [Utils removeUser:_currentUser.friends user:user];
            break;
        }
        case UpdateLikedUsersAction: {
            NSArray *array = [message componentsSeparatedByString:@"-"];
            if ([array containsObject:@""]) {
                return;
            }
            NSInteger userId = [array[0] integerValue];
            NSString *likeMessage = array[1];
            [self updateLikeStory:likeMessage userId:userId];
            break;
        }
    }
    if (self.isViewLoaded && self.view.window) {
        [self setRelationStatuses];
        [self.tableView reloadData];
    }
}

- (void)updateLikeStory:(NSString *)likeMessage userId:(NSInteger)userId {
    if ([likeMessage isEqualToString:kLikedMessageAction]) {
        for (User *user in _currentUser.friends) {
            if (user.userId.integerValue == userId) {
                [_users addObject:user];
                return;
            }
        }
        for (User *user in _currentUser.sentRequests) {
            if (user.userId.integerValue == userId) {
                [_users addObject:user];
                return;
            }
        }
        for (User *user in _currentUser.receivedRequests) {
            if (user.userId.integerValue == userId) {
                [_users addObject:user];
                return;
            }
        }
        [[ClientSocketController sharedController] sendData:[@(userId) stringValue] messageType:kSendingRequestSignal
            actionName:kGetUserByIdAction sender:self];
    } else if ([likeMessage isEqualToString:kUnlikedMessageAction]) {
        for (User *user in _users) {
            if (user.userId.integerValue == userId) {
                [_users removeObject:user];
                break;
            }
        }
    }
}

#pragma mark - Response Handler

- (void)handleResponse:(NSString *)actionName message:(NSString *)message {
    NSInteger index = [_responseActions indexOfObject:actionName];
    switch (index) {
        case UserGetLikedUsersAction: {
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kGetLikedUsersErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                _users = [User arrayOfModelsFromString:message error:&error];
                // TODO: Handle error
                [self setRelationStatuses];
                [self.tableView reloadData];
            }
            break;
        }
        case UserAcceptRequestAction: {
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kAcceptRequestErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                User *user = [[User alloc] initWithString:message error:&error];
                // TODO: Handle error
                [Utils removeUser:_currentUser.receivedRequests user:user];
                [Utils addUserIfNotExist:_currentUser.friends user:user];
                [self setRelationStatuses];
                [self.tableView reloadData];
            }
            break;
        }
        case UserDeclineRequestAction: {
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kDeclineRequestErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                User *user = [[User alloc] initWithString:message error:&error];
                // TODO: Handle error
                [Utils removeUser:_currentUser.receivedRequests user:user];
                [self setRelationStatuses];
                [self.tableView reloadData];
            }
            break;
        }
        case UserCancelRequestAction: {
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kCancelRequestErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                User *user = [[User alloc] initWithString:message error:&error];
                // TODO: Handle error
                [Utils removeUser:_currentUser.sentRequests user:user];
                [self setRelationStatuses];
                [self.tableView reloadData];
            }
            break;
        }
        case UserSendRequestAction: {
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kSendRequestErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                User *user = [[User alloc] initWithString:message error:&error];
                // TODO: Handle error
                [Utils addUserIfNotExist:_currentUser.sentRequests user:user];
                [self setRelationStatuses];
                [self.tableView reloadData];
            }
            break;
        }
        case UserUnfriendAction: {
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kUnfriendErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                User *user = [[User alloc] initWithString:message error:&error];
                // TODO: Handle error
                [Utils removeUser:_currentUser.friends user:user];
                [self setRelationStatuses];
                [self.tableView reloadData];
            }
            break;
        }
        case GetUserByIdAction: {
            if (![message isEqualToString:kFailureMessage]) {
                NSError *error;
                User *user = [[User alloc] initWithString:message error:&error];
                // TODO: Handle error
                [_users addObject:user];
                [self setRelationStatuses];
                [self.tableView reloadData];
            }
            break;
        }
    }
}

@end
