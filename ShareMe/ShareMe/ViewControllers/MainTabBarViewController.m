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
    AddUnfriendToClientsAction
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
        kAddUnfriendToClientsAction
    ];
    [self registerRequestHandler];
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
        case UserUnfriendToUserAction: {
            [self removeUser:self.loggedInUser.friends user:user];
            break;
        }
        case UserSendRequestToUserAction: {
            [self addUserIfNotExist:self.loggedInUser.receivedRequests user:user];
            break;
        }
        case UserCancelRequestToUserAction: {
            [self removeUser:self.loggedInUser.receivedRequests user:user];
            break;
        }
        case UserAddFriendToUserAction: {
            [self addUserIfNotExist:self.loggedInUser.friends user:user];
            [self removeUser:self.loggedInUser.sentRequests user:user];
            break;
        }
        case UserDeclineRequestToUserAction: {
            [self removeUser:self.loggedInUser.sentRequests user:user];
            break;
        }
        case AddAcceptRequestToClientsAction: {
            [self removeUser:self.loggedInUser.receivedRequests user:user];
            [self addUserIfNotExist:self.loggedInUser.friends user:user];
            break;
        }
        case AddDeclineRequestToClientsAction: {
            [self removeUser:self.loggedInUser.receivedRequests user:user];
            break;
        }
        case AddCancelRequestToClientsAction: {
            [self removeUser:self.loggedInUser.sentRequests user:user];
            break;
        }
        case AddSendRequestToClientsAction: {
            [self addUserIfNotExist:self.loggedInUser.sentRequests user:user];
            break;
        }
        case AddUnfriendToClientsAction: {
            [self removeUser:self.loggedInUser.friends user:user];
            break;
        }
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

@end
