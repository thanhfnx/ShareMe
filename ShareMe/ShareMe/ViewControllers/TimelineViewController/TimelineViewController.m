//
//  TimelineViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/23/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <CCBottomRefreshControl/UIScrollView+BottomRefreshControl.h>
#import "TimelineViewController.h"
#import "MainTabBarViewController.h"
#import "StoryTableViewCell.h"
#import "ApplicationConstants.h"
#import "ClientSocketController.h"
#import "CommentsViewController.h"
#import "User.h"
#import "Story.h"
#import "Utils.h"

typedef NS_ENUM(NSInteger, Relations) {
    FriendRelation,
    SentRequestRelation,
    ReceivedRequestRelation,
    NotFriendRelation,
    SelfRelation
};

typedef NS_ENUM(NSInteger, UserResponseActions) {
    GetUserByIdAction,
    UserGetStoriesOnTimelineAction,
    UserLikeStoryAction,
    UserAcceptRequestAction,
    UserDeclineRequestAction,
    UserCancelRequestAction,
    UserSendRequestAction,
    UserUnfriendAction
};

typedef NS_ENUM(NSInteger, UserRequestActions) {
    AddImageToStoryAction,
    AddNewStoryToUserAction,
    UpdateLikedUsersAction,
    AddNewCommentToUserAction,
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

static NSString *const kStoryReuseIdentifier = @"StoryCell";
static NSString *const kDefaultMessageTitle = @"Warning";
static NSString *const kGetTopStoriesRequestFormat = @"%ld-%.0f-%ld-%ld";
static NSString *const kGetUserErrorMessage = @"Something went wrong! Can not get this user's information!";
static NSString *const kGoToCommentSegueIdentifier = @"goToComment";
static NSString *const kLikeRequestFormat = @"%ld-%ld";
static NSString *const kTimelineHeaderLabelText = @"%@'s Timeline";
static NSInteger const kNumberOfStories = 2;
static NSString *const kFriendButtonTitle = @"Friends";
static NSString *const kSelfButtonTitle = @"Update Profile";
static NSString *const kSentRequestButtonTitle = @"Cancel Request";
static NSString *const kReceivedRequestButtonTitle = @"Confirm Request";
static NSString *const kNotFriendButtonTitle = @"Add Friend";
static NSString *const kRequestFormat = @"%ld-%ld";
static NSString *const kAcceptRequestErrorMessage = @"Something went wrong! Can not accept friend request!";
static NSString *const kDeclineRequestErrorMessage = @"Something went wrong! Can not decline friend request!";
static NSString *const kCancelRequestErrorMessage = @"Something went wrong! Can not cancel friend request!";
static NSString *const kSendRequestErrorMessage = @"Something went wrong! Can not send friend request!";
static NSString *const kUnfriendErrorMessage = @"Something went wrong! Can not unfriend!";
static NSString *const kConfirmMessageTitle = @"Confirm";
static NSString *const kConfirmUnfriendMessage = @"Do you really want to unfriend %@?";
static NSString *const kConfirmCancelRequestMessage = @"Do you really want to cancel friend request to %@?";
static NSString *const kConfirmAcceptMessage = @"Do you want to accept %@'s friend request?";
static NSString *const kAcceptButtonTitle = @"Accept";
static NSString *const kDeclineButtonTitle = @"Decline";

@interface TimelineViewController () {
    NSMutableDictionary<NSIndexPath *, NSNumber *> *heightForIndexPath;
    NSArray<NSString *> *_responseActions;
    NSArray<NSString *> *_requestActions;
    User *_user;
    User *_currentUser;
    NSMutableArray<Story *> *_topStories;
    NSInteger _startIndex;
    NSInteger _selectedIndex;
    NSInteger _relationStatus;
    UIRefreshControl *_topRefreshControl;
    UIRefreshControl *_bottomRefreshControl;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *imvCover;
@property (weak, nonatomic) IBOutlet UIImageView *imvAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblFullName;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *btnAction;
@property (weak, nonatomic) IBOutlet UILabel *lblTimelineHeader;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = self.navigationItem.titleView.frame;
    frame.size.width = [UIViewConstant screenWidth];
    self.navigationItem.titleView.frame = frame;
    _topStories = [NSMutableArray array];
    _responseActions = @[
        kGetUserByIdAction,
        kUserGetStoriesOnTimelineAction,
        kUserLikeStoryAction,
        kUserAcceptRequestAction,
        kUserDeclineRequestAction,
        kUserCancelRequestAction,
        kUserSendRequestAction,
        kUserUnfriendAction
    ];
    _requestActions = @[
        kAddImageToStoryAction,
        kAddNewStoryToUserAction,
        kUpdateLikedUsersAction,
        kAddNewCommentToUserAction,
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
    _currentUser = ((MainTabBarViewController *)self.navigationController.tabBarController).loggedInUser;
    [self registerRequestHandler];
    [self loadUserById];
    [self.view layoutIfNeeded];
    CGRect headerViewFrame = self.headerView.frame;
    headerViewFrame.size.height = self.btnAction.frame.origin.y + self.btnAction.frame.size.height + 16.0f;
    self.headerView.frame = headerViewFrame;
    [self loadTopStoriesOnTimeline];
    _topRefreshControl = [[UIRefreshControl alloc] init];
    [_topRefreshControl addTarget:self action:@selector(reloadAllStoriesOnTimeline)
        forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_topRefreshControl];
    _bottomRefreshControl = [UIRefreshControl new];
    _bottomRefreshControl.triggerVerticalOffset = 50.0f;
    [_bottomRefreshControl addTarget:self action:@selector(loadTopStoriesOnTimeline)
        forControlEvents:UIControlEventValueChanged];
    self.tableView.bottomRefreshControl = _bottomRefreshControl;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController && ![self.navigationController.viewControllers containsObject:self]) {
        [self resignRequestHandler];
    }
}

- (void)loadUserById {
    [ClientSocketController sendData:[@(self.userId) stringValue] messageType:kSendingRequestSignal
        actionName:kGetUserByIdAction sender:self];
}

- (void)reloadAllStoriesOnTimeline {
    NSString *message = [NSString stringWithFormat:kGetTopStoriesRequestFormat, self.userId,
        [UIViewConstant screenWidth] * [UIViewConstant screenScale], (long)0, kNumberOfStories];
    [ClientSocketController sendData:message messageType:kSendingRequestSignal
        actionName:kUserGetStoriesOnTimelineAction sender:self];
}

- (void)loadTopStoriesOnTimeline {
    _startIndex = _topStories.count;
    NSString *message = [NSString stringWithFormat:kGetTopStoriesRequestFormat, self.userId,
        [UIViewConstant screenWidth] * [UIViewConstant screenScale], _startIndex, kNumberOfStories];
    [ClientSocketController sendData:message messageType:kSendingRequestSignal
        actionName:kUserGetStoriesOnTimelineAction sender:self];
}

#pragma mark - IBAction

- (IBAction)btnBackTapped:(UIButton *)sender {
    [self dismissKeyboard];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateUser {
    self.imvAvatar.image = [Utils getAvatar:_user.avatarImage gender:_user.gender];
    self.lblFullName.text = [_user fullName];
    self.lblUserName.text = [@"@" stringByAppendingString:_user.userName];
    self.lblTimelineHeader.text = [NSString stringWithFormat:kTimelineHeaderLabelText, [_user fullName]];
    if (_user.userId == _currentUser.userId) {
        _relationStatus = SelfRelation;
        [self.btnAction setTitle:kSelfButtonTitle forState:UIControlStateNormal];
        return;
    }
    for (User *temp in _currentUser.friends) {
        if (_user.userId == temp.userId) {
            _relationStatus = FriendRelation;
            [self.btnAction setTitle:kFriendButtonTitle forState:UIControlStateNormal];
            return;
        }
    }
    for (User *temp in _currentUser.sentRequests) {
        if (_user.userId == temp.userId) {
            _relationStatus = SentRequestRelation;
            [self.btnAction setTitle:kSentRequestButtonTitle forState:UIControlStateNormal];
            return;
        }
    }
    for (User *temp in _currentUser.receivedRequests) {
        if (_user.userId == temp.userId) {
            _relationStatus = ReceivedRequestRelation;
            [self.btnAction setTitle:kReceivedRequestButtonTitle forState:UIControlStateNormal];
            return;
        }
    }
    _relationStatus = NotFriendRelation;
    [self.btnAction setTitle:kNotFriendButtonTitle forState:UIControlStateNormal];
}

- (IBAction)btnLikeTapped:(UIButton *)sender {
    [self dismissKeyboard];
    NSInteger storyId = _topStories[sender.superview.tag].storyId.integerValue;
    [ClientSocketController sendData:[NSString stringWithFormat:kLikeRequestFormat, storyId,
        _currentUser.userId.integerValue] messageType:kSendingRequestSignal actionName:kUserLikeStoryAction
        sender:self];
}

- (IBAction)btnCommentTapped:(UIButton *)sender {
    _selectedIndex = sender.superview.tag;
    [self performSegueWithIdentifier:kGoToCommentSegueIdentifier sender:self];
}

- (IBAction)btnActionTapped:(UIButton *)sender {
    switch (_relationStatus) {
        case FriendRelation: {
            NSString *fullName = [_user fullName];
            NSString *data = [NSString stringWithFormat:kRequestFormat, _currentUser.userId.integerValue,
                _user.userId.integerValue];
            [self showConfirmDialog:[NSString stringWithFormat:kConfirmUnfriendMessage, fullName]
                title:kConfirmMessageTitle handler:^(UIAlertAction *action) {
                [ClientSocketController sendData:data messageType:kSendingRequestSignal actionName:kUserUnfriendAction
                    sender:self];
            }];
            break;
        }
        case SentRequestRelation: {
            NSString *fullName = [_user fullName];
            NSString *data = [NSString stringWithFormat:kRequestFormat, _currentUser.userId.integerValue,
                _user.userId.integerValue];
            [self showConfirmDialog:[NSString stringWithFormat:kConfirmCancelRequestMessage, fullName]
                title:kConfirmMessageTitle handler:^(UIAlertAction *action) {
                [ClientSocketController sendData:data messageType:kSendingRequestSignal
                actionName:kUserCancelRequestAction sender:self];
            }];
            break;
        }
        case ReceivedRequestRelation: {
            NSString *fullName = [_user fullName];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kConfirmMessageTitle
                message:[NSString stringWithFormat:kConfirmAcceptMessage, fullName]
                preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:kAcceptButtonTitle
                style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSString *data = [NSString stringWithFormat:kRequestFormat, _currentUser.userId.integerValue,
                    _user.userId.integerValue];
                [ClientSocketController sendData:data messageType:kSendingRequestSignal
                    actionName:kUserAcceptRequestAction sender:self];
            }];
            UIAlertAction *declineAction = [UIAlertAction actionWithTitle:kDeclineButtonTitle
                style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSString *data = [NSString stringWithFormat:kRequestFormat, _currentUser.userId.integerValue,
                    _user.userId.integerValue];
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
                _user.userId.integerValue];
            [ClientSocketController sendData:data messageType:kSendingRequestSignal actionName:kUserSendRequestAction
                sender:self];
            break;
        }
    }
}

- (IBAction)btnMessageTapped:(UIButton *)sender {
}

#pragma mark - UITableViewDatasource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _topStories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStoryReuseIdentifier
        forIndexPath:indexPath];
    if (!cell) {
        return [UITableViewCell new];
    }
    cell.contentView.tag = indexPath.row;
    [cell setStory:_topStories[indexPath.row]];
    [self setTapGestureRecognizer:@[cell.imvAvatar, cell.lblFullName, cell.lblUserName]
        userId:_topStories[indexPath.row].creator.userId.integerValue];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!heightForIndexPath[indexPath]) {
        return UITableViewAutomaticDimension;
    } else {
        return heightForIndexPath[indexPath].floatValue;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath {
    heightForIndexPath[indexPath] = @(cell.frame.size.height);
    // TODO: Load more news feed
}

- (void)reloadSingleCell:(Story *)story {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[_topStories indexOfObject:story] inSection:0];
    CGPoint offset = self.tableView.contentOffset;
    [UIView setAnimationsEnabled:NO];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    [UIView setAnimationsEnabled:YES];
    self.tableView.contentOffset = offset;
}

- (void)reloadAllData:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:kGoToCommentSegueIdentifier]) {
        CommentsViewController *commentsViewController = [segue destinationViewController];
        commentsViewController.story = _topStories[_selectedIndex];
    }
}

#pragma mark - Response Handler

- (void)handleResponse:(NSString *)actionName message:(NSString *)message {
    NSInteger index = [_responseActions indexOfObject:actionName];
    switch (index) {
        case GetUserByIdAction: {
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kGetUserErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                _user = [[User alloc] initWithString:message error:&error];
                // TODO: Handle error
                if (_user) {
                    [self updateUser];
                }
            }
            break;
        }
        case UserGetStoriesOnTimelineAction: {
            if ([_topRefreshControl isRefreshing]) {
                [_topRefreshControl endRefreshing];
            }
            if ([_bottomRefreshControl isRefreshing]) {
                [_bottomRefreshControl endRefreshing];
            }
            if ([message isEqualToString:kFailureMessage]) {
                // TODO: Replace blank table view
            } else {
                NSError *error;
                if ([_topRefreshControl isRefreshing]) {
                    [_topStories removeAllObjects];
                }
                [_topStories addObjectsFromArray:[Story arrayOfModelsFromString:message error:&error]];
                // TODO: Handle error
                [self.tableView reloadData];
            }
            break;
        }
        case UserLikeStoryAction: {
            if (![message isEqualToString:kFailureMessage]) {
                NSArray *array = [message componentsSeparatedByString:@"-"];
                if ([array containsObject:@""]) {
                    return;
                }
                NSString *likeMessage = array[0];
                NSInteger storyId = [array[1] integerValue];
                NSInteger numberOfLikedUsers = [array[2] integerValue];
                [self updateLikeStory:likeMessage userId:_currentUser.userId.integerValue storyId:storyId
                    numberOfLikedUsers:numberOfLikedUsers];
            }
            break;
        }
        case UserAcceptRequestAction: {
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kAcceptRequestErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                User *user = [[User alloc] initWithString:message error:&error];
                // TODO: Handle error
                [Utils removeUser:_currentUser.receivedRequests user:user];
                [Utils addUserIfNotExist:_currentUser.friends user:user];
                [self updateUser];
            }
            break;
        }
        case UserDeclineRequestAction: {
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kDeclineRequestErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                User *user = [[User alloc] initWithString:message error:&error];
                // TODO: Handle error
                [Utils removeUser:_currentUser.receivedRequests user:user];
                [self updateUser];
            }
            break;
        }
        case UserCancelRequestAction: {
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kCancelRequestErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                User *user = [[User alloc] initWithString:message error:&error];
                // TODO: Handle error
                [Utils removeUser:_currentUser.sentRequests user:user];
                [self updateUser];
            }
            break;
        }
        case UserSendRequestAction: {
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kSendRequestErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                User *user = [[User alloc] initWithString:message error:&error];
                // TODO: Handle error
                [Utils addUserIfNotExist:_currentUser.sentRequests user:user];
                [self updateUser];
            }
            break;
        }
        case UserUnfriendAction: {
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kUnfriendErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                User *user = [[User alloc] initWithString:message error:&error];
                // TODO: Handle error
                [Utils removeUser:_currentUser.friends user:user];
                [self updateUser];
            }
            break;
        }
    }
}

- (void)updateLikeStory:(NSString *)likeMessage userId:(NSInteger)userId storyId:(NSInteger)storyId
    numberOfLikedUsers:(NSInteger)numberOfLikedUsers {
    if ([likeMessage isEqualToString:kLikedMessageAction]) {
        for (Story *story in _topStories) {
            if (story.storyId.integerValue == storyId) {
                story.numberOfLikedUsers = @(numberOfLikedUsers);
                if (userId == _currentUser.userId.integerValue && !story.likedUsers) {
                    story.likedUsers = (NSMutableArray<User, Optional> *)[NSMutableArray
                        arrayWithObject:_currentUser];
                } else if (userId == _currentUser.userId.integerValue && story.likedUsers) {
                    [story.likedUsers addObject:_currentUser];
                }
                [self reloadSingleCell:story];
                break;
            }
        }
    } else if ([likeMessage isEqualToString:kUnlikedMessageAction]) {
        for (Story *story in _topStories) {
            if (story.storyId.integerValue == storyId) {
                story.numberOfLikedUsers = @(numberOfLikedUsers);
                if (userId == _currentUser.userId.integerValue) {
                    [story.likedUsers removeAllObjects];
                }
                [self reloadSingleCell:story];
                break;
            }
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
    NSInteger index = [_requestActions indexOfObject:actionName];
    switch (index) {
        case AddImageToStoryAction: {
            NSArray *array = [message componentsSeparatedByString:@"-"];
            if ([array containsObject:@""]) {
                return;
            }
            NSInteger storyId = [array[0] integerValue];
            NSString *imageString = array[1];
            [self addImageToStory:storyId imageString:imageString];
            break;
        }
        case AddNewStoryToUserAction: {
            NSError *error;
            Story *story = [[Story alloc] initWithString:message error:&error];
            [_topStories insertObject:story atIndex:0];
            // TODO: Handle error
            [self.tableView reloadData];
            break;
        }
        case UpdateLikedUsersAction: {
            NSArray *array = [message componentsSeparatedByString:@"-"];
            if ([array containsObject:@""]) {
                return;
            }
            NSInteger userId = [array[0] integerValue];
            NSString *likeMessage = array[1];
            NSInteger storyId = [array[2] integerValue];
            NSInteger numberOfLikedUsers = [array[3] integerValue];
            [self updateLikeStory:likeMessage userId:userId storyId:storyId numberOfLikedUsers:numberOfLikedUsers];
            break;
        }
        case AddNewCommentToUserAction: {
            NSError *error;
            Comment *comment = [[Comment alloc] initWithString:message error:&error];
            // TODO: Handle error
            if (comment) {
                [self addCommentToStory:comment];
            }
            break;
        }
        default: {
            [self updateUser];
            break;
        }
    }
}

- (void)addCommentToStory:(Comment *)comment {
    for (Story *story in _topStories) {
        if (story.storyId.integerValue == comment.story.storyId.integerValue) {
            story.numberOfComments = @(story.numberOfComments.integerValue + 1);
            if (comment.creator.userId.integerValue == _currentUser.userId.integerValue && !story.comments) {
                story.comments = (NSMutableArray<Comment, Optional> *)[NSMutableArray arrayWithObject:comment];
            } else if (comment.creator.userId.integerValue == _currentUser.userId.integerValue && story.comments) {
                [story.comments addObject:comment];
            }
            [self reloadSingleCell:story];
            break;
        }
    }
}

- (void)addImageToStory:(NSInteger)storyId imageString:(NSString *)imageString {
    for (Story *story in _topStories) {
        if (story.storyId.integerValue == storyId) {
            for (id image in story.images) {
                if (![image isKindOfClass:[UIImage class]]) {
                    UIImage *decodedImage = [Utils decodeBase64String:imageString];
                    if (decodedImage) {
                        story.images[[story.images indexOfObject:image]] = decodedImage;
                        [self reloadSingleCell:story];
                    }
                    break;
                }
            }
            break;
        }
    }
}

@end
