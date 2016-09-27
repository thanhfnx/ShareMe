//
//  NewsFeedTableViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/24/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "NewsFeedViewController.h"
#import "ClientSocketController.h"
#import "StoryTableViewCell.h"
#import "UIViewController+ResponseHandler.h"
#import "UIViewController+RequestHandler.h"
#import "MainTabBarViewController.h"
#import "SearchFriendViewController.h"
#import "CommentsViewController.h"
#import "Utils.h"
#import "Story.h"
#import "User.h"

typedef NS_ENUM(NSInteger, UserResponseActions) {
    UserSearchFriendAction,
    UserGetTopStoriesAction,
    UserLikeStoryAction
};

typedef NS_ENUM(NSInteger, UserRequestActions) {
    AddImageToStoryAction,
    AddNewStoryToUserAction,
    UpdateLikedUsersAction,
    AddNewCommentToUserAction
};

static NSString *const kDefaultMessageTitle = @"Warning";
static NSString *const kStoryReuseIdentifier = @"StoryCell";
static NSString *const kEmptySearchMessage = @"Please enter friend's name or email to search!";
static NSString *const kEmptySearchResultMessage = @"Could not find anything for \"%@\"!";
static NSString *const kGoToSearchFriendSegueIdentifier = @"goToSearchFriend";
static NSString *const kGoToCommentSegueIdentifier = @"goToComment";
static NSString *const kGoToNewStorySegueIdentifier = @"goToNewStory";
static NSString *const kGetTopStoriesRequestFormat = @"%ld-%.0f-%ld-%ld";
static NSString *const kLikeRequestFormat = @"%ld-%ld";
static NSInteger const kNumberOfStories = 10;

@interface NewsFeedViewController () {
    User *_currentUser;
    NSArray<User *> *_searchResult;
    NSArray<NSString *> *_responseActions;
    NSArray<NSString *> *_requestActions;
    NSInteger _startIndex;
    NSInteger _selectedIndex;
    NSMutableDictionary<NSIndexPath *, NSNumber *> *heightForIndexPath;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchTextFieldLeadingConstraint;

@end

@implementation NewsFeedViewController

#pragma mark - UIView Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = self.navigationItem.titleView.frame;
    frame.size.width = [UIViewConstant screenWidth];
    self.navigationItem.titleView.frame = frame;
    _currentUser = ((MainTabBarViewController *)self.navigationController.tabBarController).loggedInUser;
    _responseActions = @[
        kUserSearchFriendAction,
        kUserGetTopStoriesAction,
        kUserLikeStoryAction
    ];
    _requestActions = @[
        kAddImageToStoryAction,
        kAddNewStoryToUserAction,
        kUpdateLikedUsersAction,
        kAddNewCommentToUserAction
    ];
    [self registerRequestHandler];
    _startIndex = 0;
    self.topStories = [NSMutableArray array];
    heightForIndexPath = [NSMutableDictionary dictionary];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAllData:)
        name:kUpdateNewsFeedNotificationName object:nil];
    [self loadTopStories];
}

- (void)didReceiveMemoryWarning {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateNewsFeedNotificationName object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - IBAction

- (void)loadTopStories {
    [ClientSocketController sendData:[NSString stringWithFormat:kGetTopStoriesRequestFormat,
        _currentUser.userId.integerValue, [UIViewConstant screenWidth] * [UIViewConstant screenScale], _startIndex,
        kNumberOfStories]
        messageType:kSendingRequestSignal actionName:kUserGetTopStoriesAction sender:self];
}

- (IBAction)btnSearchTapped:(UIButton *)sender {
    if (self.lblTitle.alpha == 1.0f) {
        [self.searchTextFieldLeadingConstraint setConstant:-CGRectGetWidth(self.lblTitle.frame)];
        [self.navigationItem.titleView setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.4 animations:^{
            self.lblTitle.alpha = 0.0f;
            [self.navigationItem.titleView layoutIfNeeded];
        }];
        [self.txtSearch becomeFirstResponder];
        return;
    }
    if ([self.txtSearch.text isEqualToString:@""]) {
        [self showMessage:kEmptySearchMessage title:kDefaultMessageTitle complete:^(UIAlertAction *action) {
            [self.txtSearch becomeFirstResponder];
        }];
        return;
    }
    [self.txtSearch resignFirstResponder];
    [ClientSocketController sendData:self.txtSearch.text messageType:kSendingRequestSignal
        actionName:kUserSearchFriendAction sender:self];
}

- (IBAction)btnReloadTapped:(UIButton *)sender {
    [self dismissKeyboard];
    [self.tableView reloadData];
}

- (IBAction)btnLikeTapped:(UIButton *)sender {
    [self dismissKeyboard];
    NSInteger storyId = self.topStories[sender.superview.tag].storyId.integerValue;
    [ClientSocketController sendData:[NSString stringWithFormat:kLikeRequestFormat, storyId,
        _currentUser.userId.integerValue] messageType:kSendingRequestSignal actionName:kUserLikeStoryAction
        sender:self];
}

- (IBAction)btnNewStoryTapped:(UIButton *)sender {
    [self.navigationController.tabBarController.tabBar setHidden:YES];
    [self performSegueWithIdentifier:kGoToNewStorySegueIdentifier sender:self];
}

- (IBAction)btnCommentTapped:(UIButton *)sender {
    _selectedIndex = sender.superview.tag;
    [self performSegueWithIdentifier:kGoToCommentSegueIdentifier sender:self];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.txtSearch) {
        [self btnSearchTapped:nil];
        return YES;
    }
    return NO;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self dissmissKeyboard];
}

- (void)dissmissKeyboard {
    [self.txtSearch resignFirstResponder];
    [self.searchTextFieldLeadingConstraint setConstant:-10.0f];
    [self.navigationItem.titleView setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.4 animations:^{
        [self.navigationItem.titleView layoutIfNeeded];
        self.lblTitle.alpha = 1.0f;
    }];
}

#pragma mark - UITableViewDatasource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.topStories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStoryReuseIdentifier
        forIndexPath:indexPath];
    if (!cell) {
        return [UITableViewCell new];
    }
    cell.contentView.tag = indexPath.row;
    [cell setStory:self.topStories[indexPath.row]];
    [self setTapGestureRecognizer:@[cell.imvAvatar, cell.lblFullName, cell.lblUserName]
        userId:self.topStories[indexPath.row].creator.userId.integerValue];
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
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.topStories indexOfObject:story] inSection:0];
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

#pragma mark - Response Handler

- (void)handleResponse:(NSString *)actionName message:(NSString *)message {
    NSInteger index = [_responseActions indexOfObject:actionName];
    switch (index) {
        case UserSearchFriendAction: {
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:[NSString stringWithFormat:kEmptySearchResultMessage, self.txtSearch.text]
                    title:kDefaultMessageTitle complete:nil];
            } else {
                NSError *error;
                _searchResult = [User arrayOfModelsFromString:message error:&error];
                // TODO: Handle error
                [self dissmissKeyboard];
                [self performSegueWithIdentifier:kGoToSearchFriendSegueIdentifier sender:self];
                self.txtSearch.text = @"";
            }
            break;
        }
        case UserGetTopStoriesAction: {
            if ([message isEqualToString:kFailureMessage]) {
                // TODO: Replace blank table view
            } else {
                NSError *error;
                [self.topStories addObjectsFromArray:[Story arrayOfModelsFromString:message error:&error]];
                _startIndex += kNumberOfStories;
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
    }
}

- (void)updateLikeStory:(NSString *)likeMessage userId:(NSInteger)userId storyId:(NSInteger)storyId
    numberOfLikedUsers:(NSInteger)numberOfLikedUsers {
    if ([likeMessage isEqualToString:kLikedMessageAction]) {
        for (Story *story in self.topStories) {
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
        for (Story *story in self.topStories) {
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:kGoToSearchFriendSegueIdentifier]) {
        SearchFriendViewController *searchFriendTableViewController = [segue destinationViewController];
        searchFriendTableViewController.users = _searchResult;
        searchFriendTableViewController.keyword = self.txtSearch.text;
    } else if ([segue.identifier isEqualToString:kGoToCommentSegueIdentifier]) {
        CommentsViewController *commentsViewController = [segue destinationViewController];
        commentsViewController.story = _topStories[_selectedIndex];
    }
}

#pragma mark - Request Handler

- (void)registerRequestHandler {
    for (NSString *action in _requestActions) {
        [ClientSocketController registerRequestHandler:action receiver:self];
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
            [self.topStories insertObject:story atIndex:0];
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
    }
}

- (void)addCommentToStory:(Comment *)comment {
    for (Story *story in self.topStories) {
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
    for (Story *story in self.topStories) {
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
