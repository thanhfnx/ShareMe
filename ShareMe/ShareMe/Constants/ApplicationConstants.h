//
//  ApplicationConstants.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/19/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

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

/* Constants for NSUserDefaults keys */
extern NSString *const kSaveUserAccountKey;
extern NSString *const kAutoLoginKey;
extern NSString *const kUserNameKey;
extern NSString *const kPasswordKey;

extern NSInteger const kMessagesViewControllerIndex;

/* Constants for Notifications */
extern NSString *const kReceivedRequestNotification;

/* Constants for SubMenuViewController */
extern NSString *const kSubMenuReuseIdentifier;
extern NSString *const kSaveUserAccountTextLabel;
extern NSString *const kAutoLoginTextLabel;

/* Constants for MenuItemViewController */
extern NSString *const kViewProfileReuseIdentifier;
extern NSString *const kMenuItemReuseIdentifier;
extern NSString *const kLogOutReuseIdentifier;
extern NSString *const kFindFriendsIconName;
extern NSString *const kSettingsIconName;
extern NSString *const kAboutIconName;
extern NSString *const kFindFriendsTextLabel;
extern NSString *const kSettingsTextLabel;
extern NSString *const kAboutTextLabel;
extern NSString *const kLogOutMessage;
extern NSString *const kLogOutActionTitle;
extern NSString *const kCancelActionTitle;
extern NSString *const kGoToSubMenuSegueIdentifier;
extern NSString *const kGoToFindFriendSegueIdentifier;

/* Constants for MessageDetailViewController */
extern NSString *const kFriendMessageReuseIdentifier;
extern NSString *const kConfirmMessageTitle;
extern NSString *const kDefaultMessageTitle;
extern NSString *const kConfirmDiscardMessage;
extern NSString *const kAddNewMessageErrorMessage;
extern NSString *const kSelfMessageReuseIdentifier;
extern NSString *const kGetMessagesFormat;
extern NSString *const kEmptyMessagesTableViewMessage;
extern NSInteger const kNumberOfMessages;

/* Constants for MessagesViewController */
extern NSString *const kMessageReuseIdentifier;
extern NSString *const kGoToMessageDetailSegueIdentifier;
extern NSString *const kEmptyRecentMessagesTableViewMessage;
extern NSString *const kGetLatestMessagesFormat;
extern NSInteger const kNumberOfLatestMessages;

/* Constants for TimelineViewController */
extern NSString *const kStoryReuseIdentifier;
extern NSString *const kGetTopStoriesRequestFormat;
extern NSString *const kGetUserErrorMessage;
extern NSString *const kGoToCommentSegueIdentifier;
extern NSString *const kLikeRequestFormat;
extern NSString *const kTimelineHeaderLabelText;
extern NSInteger const kNumberOfStories;
extern NSString *const kFriendButtonTitle;
extern NSString *const kSelfButtonTitle;
extern NSString *const kSentRequestButtonTitle;
extern NSString *const kReceivedRequestButtonTitle;
extern NSString *const kNotFriendButtonTitle;
extern NSString *const kMessageButtonTitle;
extern NSString *const kChangePasswordButtonTitle;
extern NSString *const kRequestFormat;
extern NSString *const kAcceptRequestErrorMessage;
extern NSString *const kDeclineRequestErrorMessage;
extern NSString *const kCancelRequestErrorMessage;
extern NSString *const kSendRequestErrorMessage;
extern NSString *const kUnfriendErrorMessage;
extern NSString *const kConfirmUnfriendMessage;
extern NSString *const kConfirmCancelRequestMessage;
extern NSString *const kConfirmAcceptMessage;
extern NSString *const kAcceptButtonTitle;
extern NSString *const kDeclineButtonTitle;
extern NSString *const kGoToUpdateProfileSegueIdentifier;
extern NSString *const kEmptyStoriesTableViewMessage;
extern NSString *const kSelfTimelineHeaderLabelText;
extern NSString *const kGoToStoryDetailSegueIdentifier;

/* Constants for WhoLikeThisViewController */
extern NSString *const kLikedUserReuseIdentifier;
extern NSString *const kGetLikedUsersErrorMessage;

/* Constants for FriendsViewController */
extern NSString *const kFriendReuseIdentifier;
extern NSString *const kNoFriendsReuseIdentifier;
extern NSString *const kEmptySearchMessage;
extern NSString *const kEmptySearchResultMessage;
extern NSString *const kOnlineFriendsSectionHeader;
extern NSString *const kOfflineFriendsSectionHeader;
extern NSString *const kEmptyFriendsTableViewMessage;

/* Constants for CommentsViewController */
extern NSString *const kCommentReuseIdentifier;
extern NSString *const kGetTopCommentsMessageFormat;
extern NSString *const kConfirmDiscardComment;
extern NSString *const kAddNewCommentErrorMessage;
extern NSString *const kEmptyLikedUsersLabelText;
extern NSString *const kSelfLikeLabelText;
extern NSString *const kOneLikeLabelText;
extern NSString *const kSelfLikeWithOthersLabelText;
extern NSString *const kManyLikeLabelText;
extern NSInteger const kNumberOfComments;
extern NSString *const kGoToWhoLikeThisSegueIdentifier;
extern NSString *const kEmptyCommentsTableViewMessage;

/* Constants for NewStoryViewController */
extern NSString *const kThumbnailReuseIdentifier;
extern NSString *const kConfirmDiscardStory;
extern NSString *const kAddNewStoryErrorMessage;
extern NSString *const kOpenCameraErrorMessage;
extern NSString *const kImageMessageFormat;
extern NSString *const kImagePickerTitle;
extern NSString *const kImagePickerMessage;
extern CGFloat const kMaxImageWidth;
extern CGFloat const kMaxImageHeight;
extern NSInteger const kNumberOfCell;

/* Constants for SearchFriendViewController */
extern NSString *const kSearchFriendReuseIdentifier;
extern NSString *const kSearchLabelTitle;

/* Constants for RequestsViewController */
extern NSString *const kReceivedRequestReuseIdentifier;
extern NSString *const kSentRequestReuseIdentifier;
extern NSString *const kNoRequestsMessage;

/* Constants for NewsFeedViewController */
extern NSString *const kGoToSearchFriendSegueIdentifier;
extern NSString *const kGoToNewStorySegueIdentifier;

/* Constants for RegisterViewController */
extern NSString *const kDefaultDateFormat;
extern NSString *const kDefaultDate;
extern NSString *const kFailedRegisterMessage;
extern NSString *const kEmptyDateOfBirthTextFieldText;
extern NSString *const kEmptyFirstNameMessage;
extern NSString *const kEmptyLastNameMessage;
extern NSString *const kEmptyEmailMessage;
extern NSString *const kEmailRegex;
extern NSString *const kInvalidEmailMessage;
extern NSString *const kEmptyUserNameMessage;
extern NSString *const kEmptyDateOfBirthMessage;
extern NSString *const kEmptyGenderMessage;
extern NSString *const kUserNameRegex;
extern NSString *const kInvalidUserNameMessage;
extern NSString *const kEmptyPasswordMessage;
extern NSString *const kInvalidPasswordMessage;
extern NSString *const kEmptyRetypePasswordMessage;
extern NSString *const kNotMatchRetypePasswordMessage;
extern NSInteger const kMinimumPasswordLength;
extern CGFloat const kMaxAvatarWidth;
extern CGFloat const kMaxAvatarHeight;

/* Constants for LoginViewController */
extern NSString *const kFailedLoginMessage;
extern NSString *const kGoToMainTabBarSegueIdentifier;
extern NSString *const kGoToRegisterSegueIdentifier;

/* Constants for FViewController */
extern NSString *const kTakeImageFromCameraActionTitle;
extern NSString *const kTakeImageFromLibraryActionTitle;

/* Constants for Utils */
extern NSString *const kDateFormat;
extern NSString *const kDefaultDateTimeFormat;
extern NSString *const kDefaultMaleAvatar;
extern NSString *const kDefaultFemaleAvatar;
extern CGFloat const kSquareImageRatio;
extern CGFloat const kLandscapeImageRatio;
extern CGFloat const kPortraitImageRatio;
extern CGFloat const kLongWidthImageRatio;
extern CGFloat const kLongHeightImageRatio;
extern NSString *const kTimeWithHourMinuteFormat;
extern NSString *const kTimeWithDayOfWeekFormat;
extern NSString *const kTimeWithDayOfWeekFullFormat;
extern NSString *const kTimeInYearFormat;
extern NSString *const kTimeInYearFullFormat;
extern NSString *const kTimeNotInYearFormat;
extern NSString *const kTimeNotInYearFullFormat;
extern NSString *const kSentTimeTodayFullFormat;
extern NSString *const kSentTimeYesterdayFormat;
extern NSString *const kSentTimeYesterdayFullFormat;

/* Constants for StoryDetailViewController */
extern NSString *const kStoryDetailTitle;

@end
