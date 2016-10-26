//
//  ApplicationConstants.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/19/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "ApplicationConstants.h"

@implementation ApplicationConstants

NSString *const kGoogleMapsAPIKey = @"AIzaSyBKHe41nrMWDuq91_2UyQRjM_QX06SUO5g";

NSString *const kSendingRequestSignal = @"TO";
NSString *const kReceivingRequestSignal = @"RE";

NSString *const kServerHost = @"127.0.0.1";
int const kServerPort = 1994;

NSString *const kMessageFormat = @"%@~%@~%@";
NSString *const kFinalMessageFormat = @"%@%ld-%@%@";
NSInteger const kDefaultBufferLength = 1024;
NSString *const kStartOfStream = @"<!START>";
NSString *const kEndOfStream = @"<!END>";
NSString *const kDelim = @"~";

NSString *const kSuccessMessage = @"TRUE";
NSString *const kFailureMessage = @"FALSE";

NSString *const kCloseConnection = @"CLIENT_CLOSE_CONNECTION";
NSString *const kEmptyMessage = @"N/A";

NSString *const kUserLoginAction = @"USER_LOGIN";
NSString *const kUserRegisterAction = @"USER_REGISTER";

NSString *const kUserAcceptRequestAction = @"USER_ACCEPT_FRIEND_REQUEST";
NSString *const kUserDeclineRequestAction = @"USER_DECLINE_FRIEND_REQUEST";
NSString *const kUserCancelRequestAction = @"USER_CANCEL_FRIEND_REQUEST";

NSString *const kAddAcceptRequestToClientsAction = @"ACCEPT_FRIEND_REQUEST_TO_CLIENTS";
NSString *const kAddDeclineRequestToClientsAction = @"DECLINE_FRIEND_REQUEST_TO_CLIENTS";
NSString *const kAddCancelRequestToClientsAction = @"CANCEL_FRIEND_REQUEST_TO_CLIENTS";

NSString *const kUserSendRequestToUserAction = @"SEND_FRIEND_REQUEST_TO_USER";
NSString *const kUserCancelRequestToUserAction = @"SEND_CANCEL_FRIEND_REQUEST_TO_USER";
NSString *const kUserAddFriendToUserAction = @"ADD_FRIEND_TO_USER";
NSString *const kUserDeclineRequestToUserAction = @"DECLINE_FRIEND_REQUEST_TO_USER";
NSString *const kUserUnfriendToUserAction = @"UNFRIEND_TO_USER";

NSString *const kAddSendRequestToClientsAction = @"SEND_FRIEND_REQUEST_TO_CLIENTS";
NSString *const kAddUnfriendToClientsAction = @"UNFRIEND_TO_CLIENTS";

NSString *const kUserSearchFriendAction = @"USER_SEARCH_FRIEND";

NSString *const kUserUnfriendAction = @"USER_UNFRIEND_USER";
NSString *const kUserSendRequestAction = @"USER_SEND_FRIEND_REQUEST";

NSString *const kUserCreateNewStoryAction = @"USER_CREATE_NEW_STORY";

NSString *const kUserGetTopStoriesAction = @"USER_GET_TOP_STORIES";
NSString *const kAddNewStoryToUserAction = @"ADD_NEW_STORY_TO_USER";
NSString *const kAddImageToStoryAction = @"ADD_IMAGE_TO_STORY";
NSString *const kUserLikeStoryAction = @"USER_LIKE_STORY";
NSString *const kLikedMessageAction = @"LIKED";
NSString *const kUnlikedMessageAction = @"UNLIKED";
NSString *const kUpdateLikedUsersAction = @"UPDATE_LIKED_USERS";
NSString *const kAddNewCommentToUserAction = @"ADD_NEW_COMMENT_TO_USER";

NSString *const kUserGetTopCommentsAction = @"USER_GET_TOP_COMMENTS";
NSString *const kUserCreateNewCommentAction = @"USER_CREATE_NEW_COMMENT";

NSString *const kUpdateNewsFeedNotificationName = @"UPDATE_NEWS_FEED";

NSString *const kUserGetLikedUsersAction = @"USER_GET_LIKED_USERS";

NSString *const kGetUserByIdAction = @"GET_USER_BY_ID";
NSString *const kUserGetStoriesOnTimelineAction = @"USER_GET_STORIES_ON_TIMELINE";

NSString *const kUpdateOnlineStatusToUserAction = @"UPDATE_ONLINE_STATUS_TO_USER";
NSString *const kUserGetMessagesAction = @"USER_GET_MESSAGES";
NSString *const kUserCreateNewMessageAction = @"USER_CREATE_NEW_MESSAGE";
NSString *const kAddNewMessageToUserAction = @"ADD_NEW_MESSAGE_TO_USER";

NSString *const kUserGetLatestMessagesAction = @"USER_GET_LATEST_MESSAGES";

NSString *const kGoToListFriendSegueIdentifier = @"goToListFriend";
NSString *const kGoToUserTimelineSegueIdentifier = @"goToUserTimeline";

/* Constants for NSUserDefaults keys */
NSString *const kSaveUserAccountKey = @"shareMe_saveUserAccount";
NSString *const kAutoLoginKey = @"shareMe_autoLogin";
NSString *const kUserNameKey = @"shareMe_userName";
NSString *const kPasswordKey = @"shareMe_password";

NSInteger const kMessagesViewControllerIndex = 2;

/* Constants for Notifications */
NSString *const kReceivedRequestNotification = @"%@ sent you a friend request.";

/* Constants for SubMenuViewController */
NSString *const kSubMenuReuseIdentifier = @"SubMenuCell";
NSString *const kSaveUserAccountTextLabel = @"Save Account";
NSString *const kAutoLoginTextLabel = @"Auto Login";

/* Constants for MenuItemViewController */
NSString *const kViewProfileReuseIdentifier = @"ViewProfileCell";
NSString *const kMenuItemReuseIdentifier = @"MenuItemCell";
NSString *const kLogOutReuseIdentifier = @"LogOutCell";
NSString *const kFindFriendsIconName = @"findfriends";
NSString *const kSettingsIconName = @"settingsitem";
NSString *const kAboutIconName = @"about";
NSString *const kFindFriendsTextLabel = @"Find Friends";
NSString *const kSettingsTextLabel = @"Settings";
NSString *const kAboutTextLabel= @"About";
NSString *const kLogOutMessage = @"Are you sure you want to log out?";
NSString *const kLogOutActionTitle = @"Log Out";
NSString *const kCancelActionTitle = @"Cancel";
NSString *const kGoToSubMenuSegueIdentifier = @"goToSubMenu";
NSString *const kGoToFindFriendSegueIdentifier = @"goToFindFriends";

/* Constants for MessageDetailViewController */
NSString *const kFriendMessageReuseIdentifier = @"FriendMessageCell";
NSString *const kConfirmMessageTitle = @"Confirm";
NSString *const kDefaultMessageTitle = @"Warning";
NSString *const kConfirmDiscardMessage = @"This message is unsaved! Are you sure to discard this message?";
NSString *const kAddNewMessageErrorMessage = @"Something went wrong! Can not send the message!";
NSString *const kSelfMessageReuseIdentifier = @"SelfMessageCell";
NSString *const kGetMessagesFormat = @"%ld-%ld-%ld-%ld";
NSString *const kEmptyMessagesTableViewMessage = @"No messages.";
NSInteger const kNumberOfMessages = 20;

/* Constants for MessagesViewController */
NSString *const kMessageReuseIdentifier = @"MessageCell";
NSString *const kGoToMessageDetailSegueIdentifier = @"goToMessageDetail";
NSString *const kEmptyRecentMessagesTableViewMessage = @"No recent messages.";
NSString *const kGetLatestMessagesFormat = @"%ld-%ld-%ld";
NSInteger const kNumberOfLatestMessages = 20;

/* Constants for TimelineViewController */
NSString *const kStoryReuseIdentifier = @"StoryCell";
NSString *const kGetTopStoriesRequestFormat = @"%ld-%.0f-%ld-%ld";
NSString *const kGetUserErrorMessage = @"Something went wrong! Can not get this user's information!";
NSString *const kGoToCommentSegueIdentifier = @"goToComment";
NSString *const kLikeRequestFormat = @"%ld-%ld";
NSString *const kTimelineHeaderLabelText = @"%@'s Timeline";
NSInteger const kNumberOfStories = 10;
NSString *const kFriendButtonTitle = @"Friends";
NSString *const kSelfButtonTitle = @"Update Profile";
NSString *const kSentRequestButtonTitle = @"Cancel Request";
NSString *const kReceivedRequestButtonTitle = @"Confirm Request";
NSString *const kNotFriendButtonTitle = @"Add Friend";
NSString *const kMessageButtonTitle = @"Message";
NSString *const kChangePasswordButtonTitle = @"Change Password";
NSString *const kRequestFormat = @"%ld-%ld";
NSString *const kAcceptRequestErrorMessage = @"Something went wrong! Can not accept friend request!";
NSString *const kDeclineRequestErrorMessage = @"Something went wrong! Can not decline friend request!";
NSString *const kCancelRequestErrorMessage = @"Something went wrong! Can not cancel friend request!";
NSString *const kSendRequestErrorMessage = @"Something went wrong! Can not send friend request!";
NSString *const kUnfriendErrorMessage = @"Something went wrong! Can not unfriend!";
NSString *const kConfirmUnfriendMessage = @"Do you really want to unfriend %@?";
NSString *const kConfirmCancelRequestMessage = @"Do you really want to cancel friend request to %@?";
NSString *const kConfirmAcceptMessage = @"Do you want to accept %@'s friend request?";
NSString *const kAcceptButtonTitle = @"Accept";
NSString *const kDeclineButtonTitle = @"Decline";
NSString *const kGoToUpdateProfileSegueIdentifier = @"goToUpdateProfile";
NSString *const kEmptyStoriesTableViewMessage = @"No stories to show.";
NSString *const kSelfTimelineHeaderLabelText = @"Your Timeline";
NSString *const kGoToStoryDetailSegueIdentifier = @"goToStoryDetail";

/* Constants for WhoLikeThisViewController */
NSString *const kLikedUserReuseIdentifier = @"LikedUserCell";
NSString *const kGetLikedUsersErrorMessage = @"Something went wrong! Can not get liked users!";

/* Constants for FriendsViewController */
NSString *const kFriendReuseIdentifier = @"FriendCell";
NSString *const kNoFriendsReuseIdentifier = @"NoFriendsCell";
NSString *const kEmptySearchMessage = @"Please enter friend's name or email to search!";
NSString *const kEmptySearchResultMessage = @"Could not find anything for \"%@\"!";
NSString *const kOnlineFriendsSectionHeader = @"Online Friends";
NSString *const kOfflineFriendsSectionHeader = @"Offline Friends";
NSString *const kEmptyFriendsTableViewMessage = @"You don't have any friends.";

/* Constants for CommentsViewController */
NSString *const kCommentReuseIdentifier = @"CommentCell";
NSString *const kGetTopCommentsMessageFormat = @"%ld-%ld-%ld";
NSString *const kConfirmDiscardComment = @"This comment is unsaved! Are you sure to discard this comment?";
NSString *const kAddNewCommentErrorMessage = @"Something went wrong! Can not add new comment!";
NSString *const kEmptyLikedUsersLabelText = @"Be the first to like this.";
NSString *const kSelfLikeLabelText = @"You like this.";
NSString *const kOneLikeLabelText = @"1 person like this.";
NSString *const kSelfLikeWithOthersLabelText = @"You and %ld other(s) like this.";
NSString *const kManyLikeLabelText = @"%ld people like this.";
NSInteger const kNumberOfComments = 20;
NSString *const kGoToWhoLikeThisSegueIdentifier = @"goToWhoLikeThis";
NSString *const kEmptyCommentsTableViewMessage = @"No comments.";

/* Constants for NewStoryViewController */
NSString *const kThumbnailReuseIdentifier = @"ThumbnailCell";
NSString *const kConfirmDiscardStory = @"This story is unsaved! Are you sure to discard this story?";
NSString *const kAddNewStoryErrorMessage = @"Something went wrong! Can not post new story!";
NSString *const kOpenCameraErrorMessage = @"Something went wrong! Can not open camera!";
NSString *const kImageMessageFormat = @"{%.0f, %.0f}-%@";
NSString *const kImagePickerTitle = @"Choose photos";
NSString *const kImagePickerMessage = @"Add photos to your story!";
CGFloat const kMaxImageWidth = 1920.0f;
CGFloat const kMaxImageHeight = 1080.0f;
NSInteger const kNumberOfCell = 4;

/* Constants for SearchFriendViewController */
NSString *const kSearchFriendReuseIdentifier = @"SearchFriendCell";
NSString *const kSearchLabelTitle = @"Search results for '%@':";

/* Constants for RequestsViewController */
NSString *const kReceivedRequestReuseIdentifier = @"ReceivedRequestCell";
NSString *const kSentRequestReuseIdentifier = @"SentRequestCell";
NSString *const kNoRequestsMessage = @"No new requests.";

/* Constants for NewsFeedViewController */
NSString *const kGoToSearchFriendSegueIdentifier = @"goToSearchFriend";
NSString *const kGoToNewStorySegueIdentifier = @"goToNewStory";
NSString *const kGoToImageDetailSegueIdentifier = @"goToImageDetail";

/* Constants for RegisterViewController */
NSString *const kDefaultDateFormat = @"dd-MM-yyyy";
NSString *const kDefaultDate = @"05-09-1994";
NSString *const kFailedRegisterMessage = @"UserName or email is already exist. Register failed!";
NSString *const kEmptyDateOfBirthTextFieldText = @"No date selected";
NSString *const kEmptyFirstNameMessage = @"First name can not be empty!";
NSString *const kEmptyLastNameMessage = @"Last name can not be empty!";
NSString *const kEmptyEmailMessage = @"Email can not be empty!";
NSString *const kEmailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
NSString *const kInvalidEmailMessage = @"Email format is invalid!";
NSString *const kEmptyUserNameMessage = @"UserName can not be empty!";
NSString *const kEmptyDateOfBirthMessage = @"Date of birth can not be empty!";
NSString *const kEmptyGenderMessage = @"Please choose your gender!";
NSString *const kUserNameRegex = @"[A-Z0-9a-z._]{6,50}";
NSString *const kInvalidUserNameMessage
    = @"Username can not be less than 6 characters and can not contain special characters!";
NSString *const kEmptyPasswordMessage = @"Password can not be empty!";
NSString *const kInvalidPasswordMessage = @"Password can not be less than 6 characters!";
NSString *const kEmptyRetypePasswordMessage = @"Retype password can not be empty!";
NSString *const kNotMatchRetypePasswordMessage = @"Password and retype password have to be the same!";
NSInteger const kMinimumPasswordLength = 6;
CGFloat const kMaxAvatarWidth = 500.0f;
CGFloat const kMaxAvatarHeight = 500.0f;

/* Constants for LoginViewController */
NSString *const kFailedLoginMessage = @"UserName or password is incorrect. Login failed!";
NSString *const kGoToMainTabBarSegueIdentifier = @"goToMainTabBar";
NSString *const kGoToRegisterSegueIdentifier = @"goToRegister";

/* Constants for FViewController */
NSString *const kTakeImageFromCameraActionTitle = @"Take from camera";
NSString *const kTakeImageFromLibraryActionTitle = @"Take from photo library";

/* Constants for Utils */
NSString *const kDateFormat = @"d MMM yy";
NSString *const kDefaultDateTimeFormat = @"yyyy-MM-dd HH:mm:ss";
NSString *const kDefaultMaleAvatar = @"default-male-avatar";
NSString *const kDefaultFemaleAvatar = @"default-female-avatar";
CGFloat const kSquareImageRatio = 1.0f;
CGFloat const kLandscapeImageRatio = 16.0f / 9.0f;
CGFloat const kPortraitImageRatio = 9.0f / 16.0f;
CGFloat const kLongWidthImageRatio = 2.0f;
CGFloat const kLongHeightImageRatio = 0.5f;
NSString *const kTimeWithHourMinuteFormat = @"HH:mm";
NSString *const kTimeWithDayOfWeekFormat = @"EEE";
NSString *const kTimeWithDayOfWeekFullFormat = @"EEE, HH:mm";
NSString *const kTimeInYearFormat = @"MMM dd";
NSString *const kTimeInYearFullFormat = @"MMM dd, HH:mm";
NSString *const kTimeNotInYearFormat = @"yyyy/MM/dd";
NSString *const kTimeNotInYearFullFormat = @"yyyy/MM/dd, HH:mm";
NSString *const kSentTimeTodayFullFormat = @"Today, %@";
NSString *const kSentTimeYesterdayFormat = @"Yesterday";
NSString *const kSentTimeYesterdayFullFormat = @"Yesterday, %@";

/* Constants for StoryDetailViewController */
NSString *const kStoryDetailTitle = @"%@'s Story";

/* Constants for ImageDetailsViewController*/
NSString *const kImageDetailReuseIdentifier = @"ImageDetailCell";

@end
