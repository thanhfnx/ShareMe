//
//  MainTabBarViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/24/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "UIViewController+RequestHandler.h"
#import "ApplicationConstants.h"
#import "ClientSocketController.h"
#import "Utils.h"
#import "User.h"

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
    UpdateOnlineStatusToUserAction
};

@interface MainTabBarViewController () {
    NSArray<NSString *> *_requestActions;
}

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
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
        kUpdateOnlineStatusToUserAction
    ];
    [self registerRequestHandler];
    [self setRequestBadgeValue];
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
    if (index == UpdateOnlineStatusToUserAction) {
        NSArray *array = [message componentsSeparatedByString:@"-"];
        if ([array containsObject:@""]) {
            return;
        }
        NSInteger userId = [array[0] integerValue];
        NSString *onlineStatus = array[1];
        for (User *user in self.loggedInUser.friends) {
            if (userId == user.userId.integerValue) {
                if ([onlineStatus isEqualToString:kFailureMessage]) {
                    user.status = @(user.status.integerValue - 1);
                } else {
                    user.status = @(user.status.integerValue + 1);
                }
                break;
            }
        }
        return;
    }
    NSError *error;
    User *user = [[User alloc] initWithString:message error:&error];
    if (error) {
        return;
    }
    switch (index) {
        case UserUnfriendToUserAction: {
            [Utils removeUser:self.loggedInUser.friends user:user];
            break;
        }
        case UserSendRequestToUserAction: {
            [Utils addUserIfNotExist:self.loggedInUser.receivedRequests user:user];
            [Utils showLocalNotification:[NSString stringWithFormat:kReceivedRequestNotification, [user fullName]]
                userInfo:nil];
            [Utils setApplicationBadge:YES];
            [self setRequestBadgeValue];
            break;
        }
        case UserCancelRequestToUserAction: {
            [Utils removeUser:self.loggedInUser.receivedRequests user:user];
            [self setRequestBadgeValue];
            [Utils setApplicationBadge:NO];
            break;
        }
        case UserAddFriendToUserAction: {
            [Utils addUserIfNotExist:self.loggedInUser.friends user:user];
            [Utils removeUser:self.loggedInUser.sentRequests user:user];
            break;
        }
        case UserDeclineRequestToUserAction: {
            [Utils removeUser:self.loggedInUser.sentRequests user:user];
            break;
        }
        case AddAcceptRequestToClientsAction: {
            [Utils removeUser:self.loggedInUser.receivedRequests user:user];
            [Utils addUserIfNotExist:self.loggedInUser.friends user:user];
            [self setRequestBadgeValue];
            [Utils setApplicationBadge:NO];
            break;
        }
        case AddDeclineRequestToClientsAction: {
            [Utils removeUser:self.loggedInUser.receivedRequests user:user];
            [self setRequestBadgeValue];
            [Utils setApplicationBadge:NO];
            break;
        }
        case AddCancelRequestToClientsAction: {
            [Utils removeUser:self.loggedInUser.sentRequests user:user];
            break;
        }
        case AddSendRequestToClientsAction: {
            [Utils addUserIfNotExist:self.loggedInUser.sentRequests user:user];
            break;
        }
        case AddUnfriendToClientsAction: {
            [Utils removeUser:self.loggedInUser.friends user:user];
            break;
        }
    }
}

- (void)setRequestBadgeValue {
    if (self.loggedInUser.receivedRequests.count) {
        self.viewControllers[1].tabBarItem.badgeValue = [@(self.loggedInUser.receivedRequests.count) stringValue];
    } else {
        self.viewControllers[1].tabBarItem.badgeValue = nil;
    }
}

@end
