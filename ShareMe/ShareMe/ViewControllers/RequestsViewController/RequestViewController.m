//
//  RequestsTableViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/24/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "RequestViewController.h"
#import "MainTabBarViewController.h"
#import "ReceivedRequestTableViewCell.h"
#import "SentRequestTableViewCell.h"
#import "ClientSocketController.h"
#import "UIViewController+RequestHandler.h"
#import "UIViewController+ResponseHandler.h"
#import "UIViewConstant.h"
#import "Utils.h"
#import "User.h"

typedef NS_ENUM(NSInteger, UserRequestActions) {
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
};

typedef NS_ENUM(NSInteger, RequestSections) {
    ReceivedRequestSection,
    SentRequestSection
};

@interface RequestViewController () {
    User *_currentUser;
    NSArray<User *> *_receivedRequests;
    NSArray<User *> *_sentRequests;
    NSArray<NSString *> *_requestActions;
    NSArray<NSString *> *_responseActions;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scRequestType;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@end

@implementation RequestViewController

#pragma mark - UIView Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _requestActions = @[
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
        kUserCancelRequestAction
    ];
    [self registerRequestHandler];
    _currentUser = ((MainTabBarViewController *)self.navigationController.tabBarController).loggedInUser;
    _receivedRequests = _currentUser.receivedRequests;
    _sentRequests = _currentUser.sentRequests;
    UIFont *font = [UIFont fontWithName:kDefaultFontName size:15];
    [self.scRequestType setTitleTextAttributes:@{NSFontAttributeName: font} forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    self.scRequestType.selectedSegmentIndex = 0;
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController && ![self.navigationController.viewControllers containsObject:self]) {
        [self resignRequestHandler];
    }
}

#pragma mark - UITableViewDatasource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRowsInSection = 0;
    switch (self.scRequestType.selectedSegmentIndex) {
        case ReceivedRequestSection:
            numberOfRowsInSection = _receivedRequests.count;
            break;
        case SentRequestSection:
            numberOfRowsInSection = _sentRequests.count;
            break;
    }
    if (numberOfRowsInSection == 0) {
        self.lblTitle.text = kNoRequestsMessage;
        self.lblTitle.textAlignment = NSTextAlignmentCenter;
    } else {
        self.lblTitle.text = [NSString stringWithFormat:@"%@:", [self.scRequestType
            titleForSegmentAtIndex:self.scRequestType.selectedSegmentIndex]];
        self.lblTitle.textAlignment = NSTextAlignmentLeft;
    }
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.scRequestType.selectedSegmentIndex) {
        case ReceivedRequestSection: {
            ReceivedRequestTableViewCell *cell = [tableView
                dequeueReusableCellWithIdentifier:kReceivedRequestReuseIdentifier forIndexPath:indexPath];
            if (cell) {
                [cell setUser:_receivedRequests[indexPath.row]];
                cell.btnAccept.tag = indexPath.row;
                cell.btnDecline.tag = indexPath.row;
                [self setTapGestureRecognizer:@[cell.imvAvatar, cell.lblFullName, cell.lblUserName]
                    userId:_receivedRequests[indexPath.row].userId.integerValue];
                return cell;
            }
        }
        case SentRequestSection: {
            SentRequestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSentRequestReuseIdentifier
                forIndexPath:indexPath];
            if (cell) {
                [cell setUser:_sentRequests[indexPath.row]];
                cell.btnCancel.tag = indexPath.row;
                [self setTapGestureRecognizer:@[cell.imvAvatar, cell.lblFullName, cell.lblUserName]
                    userId:_sentRequests[indexPath.row].userId.integerValue];
                return cell;
            }
        }
    }
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - IBAction

- (IBAction)requestTypeValueChanged:(UISegmentedControl *)sender {
    [self.tableView reloadData];
}

- (IBAction)btnAcceptTapped:(UIButton *)sender {
    NSInteger index = sender.tag;
    NSString *data = [NSString stringWithFormat:kRequestFormat, _currentUser.userId.integerValue,
        _receivedRequests[index].userId.integerValue];
    [[ClientSocketController sharedController] sendData:data messageType:kSendingRequestSignal
        actionName:kUserAcceptRequestAction sender:self];
}

- (IBAction)btnDeclineTapped:(UIButton *)sender {
    NSInteger index = sender.tag;
    NSString *data = [NSString stringWithFormat:kRequestFormat, _currentUser.userId.integerValue,
        _receivedRequests[index].userId.integerValue];
    [[ClientSocketController sharedController] sendData:data messageType:kSendingRequestSignal
        actionName:kUserDeclineRequestAction sender:self];
}

- (IBAction)btnCancelTapped:(UIButton *)sender {
    NSInteger index = sender.tag;
    NSString *data = [NSString stringWithFormat:kRequestFormat, _currentUser.userId.integerValue,
        _sentRequests[index].userId.integerValue];
    [[ClientSocketController sharedController] sendData:data messageType:kSendingRequestSignal
        actionName:kUserCancelRequestAction sender:self];
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
                [self.tableView reloadData];
            }
            break;
    }
}

@end
