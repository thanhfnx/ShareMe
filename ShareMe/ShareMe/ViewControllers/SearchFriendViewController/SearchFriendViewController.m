//
//  SearchFriendTableViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/25/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "SearchFriendViewController.h"
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
    NotFriendRelation
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
    AddUnfriendToClientsAction
};

typedef NS_ENUM(NSInteger, UserResponseActions) {
    UserAcceptRequestAction,
    UserDeclineRequestAction,
    UserCancelRequestAction,
    UserSendRequestAction,
    UserUnfriendAction,
    UserSearchFriendAction
};

static NSString *const kSearchFriendReuseIdentifier = @"SearchFriendCell";
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
static NSString *const kEmptySearchMessage = @"Please enter friend's name or email to search!";
static NSString *const kEmptySearchResultMessage = @"Could not find anything for \"%@\"!";
static NSString *const kSearchLabelTitle = @"Search results for '%@':";

@interface SearchFriendViewController () {
    User *_currentUser;
    NSMutableArray<NSNumber *> *_relationStatuses;
    NSArray<NSString *> *_requestActions;
    NSArray<NSString *> *_responseActions;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UILabel *lblSearchTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchTextFieldLeadingConstraint;

@end

@implementation SearchFriendViewController

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
        kAddUnfriendToClientsAction
    ];
    _responseActions = @[
        kUserAcceptRequestAction,
        kUserDeclineRequestAction,
        kUserCancelRequestAction,
        kUserSendRequestAction,
        kUserUnfriendAction,
        kUserSearchFriendAction
    ];
    [self registerRequestHandler];
    _currentUser = ((MainTabBarViewController *)self.navigationController.tabBarController).loggedInUser;
    _relationStatuses = [NSMutableArray array];
    CGRect frame = self.navigationItem.titleView.frame;
    frame.size.width = [UIViewConstant screenWidth];
    self.navigationItem.titleView.frame = frame;
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

- (void)setRelationStatuses {
    [_relationStatuses removeAllObjects];
    for (User *user in self.users) {
        NSInteger status = NotFriendRelation;
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
    [self.lblSearchTitle setText:[NSString stringWithFormat:kSearchLabelTitle, self.keyword]];
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSearchFriendReuseIdentifier
        forIndexPath:indexPath];
    if (!cell) {
        return [UITableViewCell new];
    }
    cell.btnAction.tag = indexPath.row;
    [cell setUser:self.users[indexPath.row] relationStatus:_relationStatuses[indexPath.row].integerValue];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self dissmissKeyboard];
}

- (void)dissmissKeyboard {
    [self.txtSearch resignFirstResponder];
    [self.searchTextFieldLeadingConstraint setConstant:-10.0f];
    [self.navigationItem.titleView setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.4 animations:^{
        [self.navigationItem.titleView layoutIfNeeded];
        self.lblTitle.alpha = 1.0f;
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.txtSearch) {
        [self btnSearchTapped:nil];
        return YES;
    }
    return NO;
}

#pragma mark - IBAction

- (IBAction)btnSearchTapped:(UIButton *)sender {
    if (self.lblTitle.alpha == 1.0f) {
        [self.searchTextFieldLeadingConstraint setConstant:-self.lblTitle.frame.size.width];
        [self.navigationItem.titleView setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.4 animations:^{
            self.lblTitle.alpha = 0.0f;
            [self.navigationItem.titleView layoutIfNeeded];
        }];
        [self.txtSearch becomeFirstResponder];
        return;
    }
    if ([self.txtSearch.text isEqualToString:@""]) {
        [self showMessage:kEmptySearchMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
            [self.txtSearch becomeFirstResponder];
        }];
        return;
    }
    [ClientSocketController sendData:self.txtSearch.text messageType:kSendingRequestSignal
        actionName:kUserSearchFriendAction sender:self];
}

- (IBAction)btnBackTapped:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnActionTapped:(UIButton *)sender {
    NSInteger index = sender.tag;
    switch (_relationStatuses[index].integerValue) {
        case FriendRelation: {
            NSString *fullName = [self.users[index] fullName];
            NSString *data = [NSString stringWithFormat:kRequestFormat, _currentUser.userId.integerValue,
                self.users[index].userId.integerValue];
            [self showConfirmDialog:[NSString stringWithFormat:kConfirmUnfriendMessage, fullName]
                title:kConfirmMessageTitle handler:^(UIAlertAction *action) {
                [ClientSocketController sendData:data messageType:kSendingRequestSignal actionName:kUserUnfriendAction
                    sender:self];
            }];
            break;
        }
        case SentRequestRelation: {
            NSString *fullName = [self.users[index] fullName];
            NSString *data = [NSString stringWithFormat:kRequestFormat, _currentUser.userId.integerValue,
                self.users[index].userId.integerValue];
            [self showConfirmDialog:[NSString stringWithFormat:kConfirmCancelRequestMessage, fullName]
                title:kConfirmMessageTitle handler:^(UIAlertAction *action) {
                [ClientSocketController sendData:data messageType:kSendingRequestSignal
                actionName:kUserCancelRequestAction sender:self];
            }];
            break;
        }
        case ReceivedRequestRelation: {
            NSString *fullName = [self.users[index] fullName];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kConfirmMessageTitle
                message:[NSString stringWithFormat:kConfirmAcceptMessage, fullName]
                preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:kAcceptButtonTitle
                style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSString *data = [NSString stringWithFormat:kRequestFormat, _currentUser.userId.integerValue,
                    self.users[index].userId.integerValue];
                [ClientSocketController sendData:data messageType:kSendingRequestSignal
                    actionName:kUserAcceptRequestAction sender:self];
            }];
            UIAlertAction *declineAction = [UIAlertAction actionWithTitle:kDeclineButtonTitle
                style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSString *data = [NSString stringWithFormat:kRequestFormat, _currentUser.userId.integerValue,
                    self.users[index].userId.integerValue];
                [ClientSocketController sendData:data messageType:kSendingRequestSignal
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
                self.users[index].userId.integerValue];
            [ClientSocketController sendData:data messageType:kSendingRequestSignal actionName:kUserSendRequestAction
                sender:self];
            break;
        }
    }
}

#pragma mark - Request Handler

- (void)registerRequestHandler {
    for (NSString *action in _requestActions) {
        [ClientSocketController registerRequestHandler:action receiver:self];
    }
}

- (void)resignRequestHandler {
    for (NSString *action in _requestActions) {
        [ClientSocketController resignRequestHandler:action receiver:self];
    }
}

- (void)handleRequest:(NSString *)actionName message:(NSString *)message {
    NSError *error;
    User *user = [[User alloc] initWithString:message error:&error];
    // TODO: Handle error
    NSInteger index = [_requestActions indexOfObject:actionName];
    switch (index) {
        case UserUnfriendToUserAction:
            [self removeUser:_currentUser.friends user:user];
            break;
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
        case AddAcceptRequestToClientsAction:
            [self removeUser:_currentUser.receivedRequests user:user];
            [self addUserIfNotExist:_currentUser.friends user:user];
            break;
        case AddDeclineRequestToClientsAction:
            [self removeUser:_currentUser.receivedRequests user:user];
            break;
        case AddCancelRequestToClientsAction:
            [self removeUser:_currentUser.sentRequests user:user];
            break;
        case AddSendRequestToClientsAction:
            [self addUserIfNotExist:_currentUser.sentRequests user:user];
            break;
        case AddUnfriendToClientsAction:
            [self removeUser:_currentUser.friends user:user];
            break;
    }
    if (self.isViewLoaded && self.view.window) {
        [self setRelationStatuses];
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
                // TODO: Handle error
                [self removeUser:_currentUser.receivedRequests user:user];
                [self addUserIfNotExist:_currentUser.friends user:user];
                [self setRelationStatuses];
                [self.tableView reloadData];
            }
            break;
        case UserDeclineRequestAction:
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kDeclineRequestErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                User *user = [[User alloc] initWithString:message error:&error];
                // TODO: Handle error
                [self removeUser:_currentUser.receivedRequests user:user];
                [self setRelationStatuses];
                [self.tableView reloadData];
            }
            break;
        case UserCancelRequestAction:
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kCancelRequestErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                User *user = [[User alloc] initWithString:message error:&error];
                // TODO: Handle error
                [self removeUser:_currentUser.sentRequests user:user];
                [self setRelationStatuses];
                [self.tableView reloadData];
            }
            break;
        case UserSendRequestAction:
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kSendRequestErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                User *user = [[User alloc] initWithString:message error:&error];
                // TODO: Handle error
                [self addUserIfNotExist:_currentUser.sentRequests user:user];
                [self setRelationStatuses];
                [self.tableView reloadData];
            }
            break;
        case UserUnfriendAction:
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kUnfriendErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                User *user = [[User alloc] initWithString:message error:&error];
                // TODO: Handle error
                [self removeUser:_currentUser.friends user:user];
                [self setRelationStatuses];
                [self.tableView reloadData];
            }
            break;
        case UserSearchFriendAction:
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:[NSString stringWithFormat:kEmptySearchResultMessage, self.txtSearch.text]
                    title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                self.users = [User arrayOfModelsFromString:message error:&error];
                // TODO: Handle error
                [self setRelationStatuses];
                self.keyword = self.txtSearch.text;
                self.txtSearch.text = @"";
                [self dismissKeyboard];
                [self.tableView reloadData];
            }
            break;
    }
}

@end
