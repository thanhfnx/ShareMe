//
//  StoryDetailViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 10/17/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "StoryDetailViewController.h"
#import "ApplicationConstants.h"
#import "Comment.h"
#import "Story.h"
#import "User.h"
#import "Utils.h"
#import "UIViewController+RequestHandler.h"
#import "UIViewController+ResponseHandler.h"
#import "MainTabBarViewController.h"
#import "FDateFormatter.h"
#import "ClientSocketController.h"
#import "CommentTableViewCell.h"
#import "TimelineViewController.h"
#import "NewsFeedViewController.h"
#import "WhoLikeThisViewController.h"
#import "StoryTableViewCell.h"

typedef NS_ENUM(NSInteger, UserResponseActions) {
    UserGetTopCommentsAction,
    UserCreateNewCommentAction,
    UserLikeStoryAction
};

typedef NS_ENUM(NSInteger, UserRequestActions) {
    AddNewCommentToUserAction,
    UpdateLikedUsersAction
};

typedef NS_ENUM(NSInteger, StoryDetailSections) {
    StoryDetailSection,
    CommentsSection,
    NumberOfSections
};

@interface StoryDetailViewController () {
    Comment *_comment;
    NSInteger _startIndex;
    NSArray<NSString *> *_responseActions;
    NSArray<NSString *> *_requestActions;
    NSMutableArray<Comment *> *_topComments;
    User *_currentUser;
    NSDateFormatter *_dateFormatter;
    UIRefreshControl *_topRefreshControl;
}

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextView *txvAddComment;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblPlaceHolder;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addCommentViewBottomConstraint;

@end

@implementation StoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = self.navigationItem.titleView.frame;
    frame.size.width = [UIViewConstant screenWidth];
    self.navigationItem.titleView.frame = frame;
    [self.txvAddComment becomeFirstResponder];
    _topComments = [NSMutableArray array];
    _responseActions = @[
        kUserGetTopCommentsAction,
        kUserCreateNewCommentAction,
        kUserLikeStoryAction
    ];
    _requestActions = @[
        kAddNewCommentToUserAction,
        kUpdateLikedUsersAction
    ];
    [self registerRequestHandler];
    _currentUser = ((MainTabBarViewController *)self.navigationController.tabBarController).loggedInUser;
    _dateFormatter = [FDateFormatter sharedDateFormatter];
    _dateFormatter.dateFormat = kDefaultDateTimeFormat;
    [self loadComments];
    _topRefreshControl = [[UIRefreshControl alloc] init];
    [_topRefreshControl addTarget:self action:@selector(loadComments) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_topRefreshControl];
    self.lblTitle.text = [NSString stringWithFormat:@"%@'s Story", [self.story.creator fullName]];
}

- (void)loadComments {
    _startIndex = _topComments.count;
    [[ClientSocketController sharedController] sendData:[NSString stringWithFormat:kGetTopCommentsMessageFormat,
        self.story.storyId.integerValue, _startIndex, kNumberOfComments] messageType:kSendingRequestSignal
        actionName:kUserGetTopCommentsAction sender:self];
}

- (void)updateLikedUsers {
    //TODO: Update Liked users
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.lblPlaceHolder.hidden = [self.txvAddComment hasText];
}

#pragma mark - UITableViewDatasource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case StoryDetailSection: {
            return 1;
        }
        case CommentsSection: {
            if (!_topComments.count) {
                return 1;
            }
            return _topComments.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case StoryDetailSection: {
            StoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStoryReuseIdentifier
                forIndexPath:indexPath];
            if (!cell) {
                return [UITableViewCell new];
            }
            cell.contentView.tag = indexPath.row;
            [cell setStory:self.story];
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                action:@selector(imagesTapGestureRecognizer:)];
            tapGestureRecognizer.numberOfTapsRequired = 1;
            [cell.vContentImages  addGestureRecognizer:tapGestureRecognizer];
            [cell.vContentImages setUserInteractionEnabled:YES];
            [self setTapGestureRecognizer:@[cell.imvAvatar, cell.lblFullName, cell.lblUserName]
                userId:self.story.creator.userId.integerValue];
            return cell;
        }
        case CommentsSection: {
            if (!_topComments.count) {
                return [Utils emptyTableCell:kEmptyCommentsTableViewMessage];
            }
            CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommentReuseIdentifier
                forIndexPath:indexPath];
            if (!cell) {
                return [UITableViewCell new];
            }
            [cell setComment:_topComments[indexPath.row]];
            [self setTapGestureRecognizer:@[cell.imvAvatar, cell.lblFullName]
                userId:_topComments[indexPath.row].creator.userId.integerValue];
            return cell;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (void)reloadDataWithAnimated:(BOOL)animated {
    [self.tableView reloadData];
    NSIndexPath *lastRowIndex = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastRowIndex atScrollPosition:UITableViewScrollPositionBottom
        animated:animated];
}

- (void)imagesTapGestureRecognizer:(UITapGestureRecognizer *)sender {
    // TODO: Display images view
}

#pragma mark - Packing entity

- (void)getComment {
    _comment = [[Comment alloc] init];
    User *creator = [[User alloc] init];
    creator.userId = _currentUser.userId;
    _comment.creator = creator;
    _comment.content = self.txvAddComment.text;
    _comment.createdTime = [_dateFormatter stringFromDate:[NSDate date]];
    Story *story = [[Story alloc] init];
    story.storyId = @(self.story.storyId.integerValue);
    _comment.story = story;
}

#pragma mark - IBAction

- (IBAction)btnBackTapped:(UIButton *)sender {
    if ([self.txvAddComment hasText]) {
        [self showConfirmDialog:kConfirmDiscardComment title:kConfirmMessageTitle handler:^(UIAlertAction *action) {
            [self dismissKeyboard];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        [self dismissKeyboard];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)btnPostTapped:(UIButton *)sender {
    if ([self.txvAddComment hasText]) {
        [self dismissKeyboard];
        [self getComment];
        [[ClientSocketController sharedController] sendData:[_comment toJSONString] messageType:kSendingRequestSignal
            actionName:kUserCreateNewCommentAction sender:self];
    }
}

- (IBAction)btnLikeTapped:(UIButton *)sender {
    [[ClientSocketController sharedController] sendData:[NSString stringWithFormat:kLikeRequestFormat,
        self.story.storyId.integerValue, _currentUser.userId.integerValue] messageType:kSendingRequestSignal
        actionName:kUserLikeStoryAction sender:self];
}

- (IBAction)btnCommentTapped:(UIButton *)sender {
}

- (IBAction)btnWhoLikeThisTapped:(UIButton *)sender {
    if (self.story.numberOfLikedUsers.integerValue) {
        [self dismissKeyboard];
        [self performSegueWithIdentifier:kGoToWhoLikeThisSegueIdentifier sender:self];
    }
}

#pragma mark - Show / hide keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{
        CGFloat offset = keyboardSize.height;
        self.addCommentViewBottomConstraint.constant += offset;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        self.addCommentViewBottomConstraint.constant = 0.0f;
    }];
}

#pragma mark - Response Handler

- (void)handleResponse:(NSString *)actionName message:(NSString *)message {
    NSInteger index = [_responseActions indexOfObject:actionName];
    switch (index) {
        case UserGetTopCommentsAction: {
            if (![message isEqualToString:kFailureMessage]) {
                NSError *error;
                NSMutableArray *array = [[[[Comment arrayOfModelsFromString:message error:&error]
                    reverseObjectEnumerator] allObjects] mutableCopy];
                [array addObjectsFromArray:_topComments];
                [_topComments removeAllObjects];
                [_topComments addObjectsFromArray:array];
                _startIndex += kNumberOfComments;;
                if (error) {
                    return;
                }
                [self reloadDataWithAnimated:NO];
            }
            [_topRefreshControl endRefreshing];
            break;
        }
        case UserCreateNewCommentAction: {
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kAddNewCommentErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                _comment.commentId = @(message.integerValue);
                _comment.creator = _currentUser;
                [_topComments addObject:_comment];
                [self.txvAddComment setText:@""];
                self.lblPlaceHolder.hidden = NO;
                [self reloadDataWithAnimated:YES];
                NSUInteger index = [self.navigationController.viewControllers indexOfObject:self] - 1;
                if ([self.navigationController.viewControllers[index] isKindOfClass:[NewsFeedViewController
                    class]]) {
                    NewsFeedViewController *newsFeedViewController = self.navigationController.viewControllers[index];
                    [newsFeedViewController addCommentToStory:_comment];
                } else if ([self.navigationController.viewControllers[index] isKindOfClass:[TimelineViewController
                    class]]) {
                    TimelineViewController *timelineViewController = self.navigationController.viewControllers[index];
                    [timelineViewController addCommentToStory:_comment];
                }
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
                [self updateLikedUsers];
            }
            break;
        }
    }
}

- (void)updateLikeStory:(NSString *)likeMessage userId:(NSInteger)userId storyId:(NSInteger)storyId
    numberOfLikedUsers:(NSInteger)numberOfLikedUsers {
    if ([likeMessage isEqualToString:kLikedMessageAction]) {
        if (self.story.storyId.integerValue == storyId) {
            self.story.numberOfLikedUsers = @(numberOfLikedUsers);
            if (userId == _currentUser.userId.integerValue && !self.story.likedUsers) {
                self.story.likedUsers = (NSMutableArray<User, Optional> *)[NSMutableArray arrayWithObject:_currentUser];
            } else if (userId == _currentUser.userId.integerValue && self.story.likedUsers) {
                [self.story.likedUsers addObject:_currentUser];
            }
        }
    } else if ([likeMessage isEqualToString:kUnlikedMessageAction]) {
        if (self.story.storyId.integerValue == storyId) {
            self.story.numberOfLikedUsers = @(numberOfLikedUsers);
            if (userId == _currentUser.userId.integerValue) {
                [self.story.likedUsers removeAllObjects];
            }
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
    NSInteger index = [_requestActions indexOfObject:actionName];
    switch (index) {
        case AddNewCommentToUserAction: {
            NSError *error;
            Comment *comment = [[Comment alloc] initWithString:message error:&error];
            if (error) {
                return;
            }
            if (comment) {
                [_topComments addObject:comment];
                [self reloadDataWithAnimated:YES];
            }
            break;
        }
        case UpdateLikedUsersAction: {
            [self updateLikedUsers];
            break;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:kGoToWhoLikeThisSegueIdentifier]) {
        WhoLikeThisViewController *whoLikeThisViewController = [segue destinationViewController];
        whoLikeThisViewController.storyId = self.story.storyId.integerValue;
    }
}

@end
