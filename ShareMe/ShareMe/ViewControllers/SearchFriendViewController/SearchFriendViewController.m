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
        [self.searchTextFieldLeadingConstraint setConstant:-CGRectGetWidth(self.lblTitle.frame) - 10.0f];
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
    [[ClientSocketController sharedController] sendData:self.txtSearch.text messageType:kSendingRequestSignal
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
                [[ClientSocketController sharedController] sendData:data messageType:kSendingRequestSignal
                    actionName:kUserUnfriendAction sender:self];
            }];
            break;
        }
        case SentRequestRelation: {
            NSString *fullName = [self.users[index] fullName];
            NSString *data = [NSString stringWithFormat:kRequestFormat, _currentUser.userId.integerValue,
                self.users[index].userId.integerValue];
            [self showConfirmDialog:[NSString stringWithFormat:kConfirmCancelRequestMessage, fullName]
                title:kConfirmMessageTitle handler:^(UIAlertAction *action) {
                [[ClientSocketController sharedController] sendData:data messageType:kSendingRequestSignal
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
                [[ClientSocketController sharedController] sendData:data messageType:kSendingRequestSignal
                    actionName:kUserAcceptRequestAction sender:self];
            }];
            UIAlertAction *declineAction = [UIAlertAction actionWithTitle:kDeclineButtonTitle
                style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSString *data = [NSString stringWithFormat:kRequestFormat, _currentUser.userId.integerValue,
                    self.users[index].userId.integerValue];
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
                self.users[index].userId.integerValue];
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
    if (self.isViewLoaded && self.view.window) {
        [self setRelationStatuses];
        [self.tableView reloadData];
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
                if (error) {
                    return;
                }
                [Utils removeUser:_currentUser.receivedRequests user:user];
                [Utils addUserIfNotExist:_currentUser.friends user:user];
                [self setRelationStatuses];
                [self.tableView reloadData];
                [((MainTabBarViewController *)self.navigationController.tabBarController) setRequestBadgeValue];
            }
            break;
        case UserDeclineRequestAction:
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kDeclineRequestErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                User *user = [[User alloc] initWithString:message error:&error];
                if (error) {
                    return;
                }
                [Utils removeUser:_currentUser.receivedRequests user:user];
                [self setRelationStatuses];
                [self.tableView reloadData];
                [((MainTabBarViewController *)self.navigationController.tabBarController) setRequestBadgeValue];
            }
            break;
        case UserCancelRequestAction:
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kCancelRequestErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                User *user = [[User alloc] initWithString:message error:&error];
                if (error) {
                    return;
                }
                [Utils removeUser:_currentUser.sentRequests user:user];
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
                if (error) {
                    return;
                }
                [Utils addUserIfNotExist:_currentUser.sentRequests user:user];
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
                if (error) {
                    return;
                }
                [Utils removeUser:_currentUser.friends user:user];
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
                if (error) {
                    return;
                }
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
