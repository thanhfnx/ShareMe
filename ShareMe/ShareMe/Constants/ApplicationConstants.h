//
//  ApplicationConstants.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/19/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplicationConstants : NSObject

extern NSString *const kGoogleMapsAPIKey;

extern NSString *const kSendingRequestSignal;
extern NSString *const kReceivingRequestSignal;

extern NSString *const kServerHost;
extern int const kServerPort;

extern NSString *const kMessageFormat;
extern NSString *const kFinalMessageFormat;
extern NSInteger const kDefaultBufferLength;
extern NSString *const kStartOfStream;
extern NSString *const kEndOfStream;
extern NSString *const kDelim;

extern NSString *const kSuccessMessage;
extern NSString *const kFailureMessage;

extern NSString *const kCloseConnection;
extern NSString *const kEmptyMessage;

extern NSString *const kUserLoginAction;
extern NSString *const kUserRegisterAction;

extern NSString *const kUserAcceptRequestAction;
extern NSString *const kUserDeclineRequestAction;
extern NSString *const kUserCancelRequestAction;

extern NSString *const kAddAcceptRequestToClientsAction;
extern NSString *const kAddDeclineRequestToClientsAction;
extern NSString *const kAddCancelRequestToClientsAction;

extern NSString *const kUserSendRequestToUserAction;
extern NSString *const kUserCancelRequestToUserAction;
extern NSString *const kUserAddFriendToUserAction;
extern NSString *const kUserDeclineRequestToUserAction;
extern NSString *const kUserUnfriendToUserAction;

extern NSString *const kAddSendRequestToClientsAction;
extern NSString *const kAddUnfriendToClientsAction;

extern NSString *const kUserSearchFriendAction;

extern NSString *const kUserUnfriendAction;
extern NSString *const kUserSendRequestAction;

extern NSString *const kUserCreateNewStoryAction;

extern NSString *const kUserGetTopStoriesAction;
extern NSString *const kAddNewStoryToUserAction;
extern NSString *const kAddImageToStoryAction;
extern NSString *const kUserLikeStoryAction;
extern NSString *const kLikedMessageAction;
extern NSString *const kUnlikedMessageAction;
extern NSString *const kUpdateLikedUsersAction;
extern NSString *const kAddNewCommentToUserAction;

extern NSString *const kUserGetTopCommentsAction;
extern NSString *const kUserCreateNewCommentAction;

extern NSString *const kUpdateNewsFeedNotificationName;

extern NSString *const kUserGetLikedUsersAction;

extern NSString *const kGetUserByIdAction;
extern NSString *const kUserGetStoriesOnTimelineAction;

extern NSString *const kUpdateOnlineStatusToUserAction;
extern NSString *const kUserGetMessagesAction;
extern NSString *const kUserCreateNewMessageAction;
extern NSString *const kAddNewMessageToUserAction;

extern NSString *const kUserGetLatestMessagesAction;

extern NSString *const kGoToListFriendSegueIdentifier;
extern NSString *const kGoToUserTimelineSegueIdentifier;

extern NSString *const kSaveUserAccountKey;
extern NSString *const kAutoLoginKey;

extern NSInteger const kMessagesViewControllerIndex;

extern NSString *const kReceivedRequestNotification;

@end
