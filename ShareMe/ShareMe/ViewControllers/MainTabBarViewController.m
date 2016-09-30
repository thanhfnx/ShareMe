//
//  MainTabBarViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/24/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "UIViewController+RequestHandler.h"
#import "UIViewController+ResponseHandler.h"
#import "ApplicationConstants.h"
#import "ClientSocketController.h"
#import "Utils.h"
#import "User.h"
#import "Message.h"

typedef NS_ENUM(NSInteger, UserResponseActions) {
    UserGetLatestMessagesAction
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
    UpdateOnlineStatusToUserAction
};

static NSString *const kGetLatestMessagesFormat = @"%ld-%ld-%ld";
static NSInteger const kNumberOfLatestMessages = 20;

@interface MainTabBarViewController () {
    NSArray<NSString *> *_requestActions;
    NSArray<NSString *> *_responseActions;
}

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    _responseActions = @[kUserGetLatestMessagesAction];
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
    self.latestMessages = [NSMutableArray array];
    [self registerRequestHandler];
    [self loadLatestMessages];
}

- (void)loadLatestMessages {
    NSString *message = [NSString stringWithFormat:kGetLatestMessagesFormat, self.loggedInUser.userId.integerValue,
        (long)0, kNumberOfLatestMessages];
    [ClientSocketController sendData:message messageType:kSendingRequestSignal actionName:kUserGetLatestMessagesAction
        sender:self];
}

#pragma mark - Response Handler

- (void)handleResponse:(NSString *)actionName message:(NSString *)message {
    NSInteger index = [_responseActions indexOfObject:actionName];
    switch (index) {
        case UserGetLatestMessagesAction: {
            if (![message isEqualToString:kFailureMessage]) {
                NSError *error;
                // TODO: Handle error
                [self.latestMessages addObjectsFromArray:[Message arrayOfModelsFromString:message error:&error]];
            }
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
        case UserUnfriendToUserAction: {
            [Utils removeUser:self.loggedInUser.friends user:user];
            break;
        }
        case UserSendRequestToUserAction: {
            [Utils addUserIfNotExist:self.loggedInUser.receivedRequests user:user];
            break;
        }
        case UserCancelRequestToUserAction: {
            [Utils removeUser:self.loggedInUser.receivedRequests user:user];
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
            break;
        }
        case AddDeclineRequestToClientsAction: {
            [Utils removeUser:self.loggedInUser.receivedRequests user:user];
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
        case UpdateOnlineStatusToUserAction: {
            NSArray *array = [message componentsSeparatedByString:@"-"];
            if ([array containsObject:@""]) {
                return;
            }
            NSInteger userId = [array[0] integerValue];
            NSString *onlineStatus = array[1];
            [self updateOnlineStatus:onlineStatus userId:userId];
            break;
        }
    }
}

- (void)updateOnlineStatus:(NSString *)onlineStatus userId:(NSInteger)userId {
    if ([onlineStatus isEqualToString:kFailureMessage]) {
        for (User *user in self.loggedInUser.friends) {
            if (userId == user.userId.integerValue) {
                user.status = @(user.status.integerValue - 1);
            }
        }
    } else {
        NSInteger index = 0;
        for (User *user in self.loggedInUser.friends) {
            if (userId == user.userId.integerValue) {
                index = [self.loggedInUser.friends indexOfObject:user];
                break;
            }
        }
        if (index) {
            User *user = self.loggedInUser.friends[index];
            user.status = @(user.status.integerValue + 1);
            if (user.status.integerValue == 1) {
                [self.loggedInUser.friends removeObject:user];
                [self.loggedInUser.friends insertObject:user atIndex:0];
            }
        }
    }
}

@end
