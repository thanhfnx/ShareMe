//
//  NotificationsViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 12/20/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <CCBottomRefreshControl/UIScrollView+BottomRefreshControl.h>
#import "NotificationsViewController.h"
#import "Notification.h"
#import "MainTabBarViewController.h"
#import "ClientSocketController.h"
#import "User.h"
#import "Utils.h"
//TODO: Delete this import
#import "Story.h"
#import "NotificationTableViewCell.h"

typedef NS_ENUM(NSInteger, UserResponseActions) {
    UserGetLatestNotificationsAction
};

typedef NS_ENUM(NSInteger, UserRequestActions) {
    AddNewNotificationToUserAction
};

@interface NotificationsViewController () {
    NSMutableArray<Notification *> *_latestNotifications;
    NSArray<NSString *> *_responseActions;
    NSArray<NSString *> *_requestActions;
    User *_currentUser;
    NSInteger _startIndex;
    UIRefreshControl *_bottomRefreshControl;
    NSInteger _selectedIndex;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    _isSwipeGestureDisable = YES;
    [super viewDidLoad];
    CGRect frame = self.navigationItem.titleView.frame;
    frame.size.width = [UIViewConstant screenWidth];
    self.navigationItem.titleView.frame = frame;
    _latestNotifications = [NSMutableArray array];
    _requestActions = @[kAddNewNotificationToUserAction];
    [self registerRequestHandler];
    _currentUser = ((MainTabBarViewController *)self.navigationController.tabBarController).loggedInUser;
    [self loadLatestNotifications];
    _bottomRefreshControl = [UIRefreshControl new];
    _bottomRefreshControl.triggerVerticalOffset = 50.0f;
    [_bottomRefreshControl addTarget:self action:@selector(loadLatestNotifications)
        forControlEvents:UIControlEventValueChanged];
    self.tableView.bottomRefreshControl = _bottomRefreshControl;
}

- (void)loadLatestNotifications {
    //TODO: Sample data
    Notification *likedStoryNotification = [[Notification alloc] init];
    likedStoryNotification.notificationId = @1;
    likedStoryNotification.notificationType = @0;
    User *userA = [[User alloc] init];
    userA.firstName = @"Thanh";
    userA.lastName = @"Nguyen";
    likedStoryNotification.sender = userA;
    Story *storyA = [[Story alloc] init];
    storyA.content = @"Happy new year";
    likedStoryNotification.targetStory = storyA;
    [_latestNotifications addObject:likedStoryNotification];
}

#pragma mark - UITableViewDatasource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!_latestNotifications.count) {
        return 1;
    }
    return _latestNotifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_latestNotifications.count) {
        return [Utils emptyTableCell:kEmptyRecentMessagesTableViewMessage];
    }
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNotificationReuseIdentifier
        forIndexPath:indexPath];
    if (!cell) {
        return [UITableViewCell new];
    }
    [cell setNotification:_latestNotifications[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_latestNotifications.count) {
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
    forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!_latestNotifications.count) {
        return;
    }
    _selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:kGoToMessageDetailSegueIdentifier sender:self];
}

#pragma mark - Response Handler

- (void)handleResponse:(NSString *)actionName message:(NSString *)message {
    NSInteger index = [_responseActions indexOfObject:actionName];
    switch (index) {
        case UserGetLatestNotificationsAction: {
            if (![message isEqualToString:kFailureMessage]) {
                NSError *error;
                NSArray *array = [Notification arrayOfModelsFromString:message error:&error];
                if (error) {
                    return;
                }
                [_latestNotifications addObjectsFromArray:array];
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
    //TODO: Handle request
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //TODO: Prepare for segue
}

@end
