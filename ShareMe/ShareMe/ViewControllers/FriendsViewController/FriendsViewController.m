//
//  FriendsViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/20/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "FriendsViewController.h"
#import "FriendTableViewCell.h"
#import "MainTabBarViewController.h"
#import "ClientSocketController.h"
//#import "MessagesViewController.h"
#import "MessageDetailViewController.h"
#import "User.h"
#import "Utils.h"

typedef NS_ENUM(NSInteger, FriendSections) {
    OnlineFriendsSection,
    OfflineFriendsSection,
    NumberOfFriendSections
};

typedef NS_ENUM(NSInteger, UserRequestActions) {
    UpdateOnlineStatusToUserAction
};

static NSString *const kDefaultMessageTitle = @"Warning";
static NSString *const kFriendReuseIdentifier = @"FriendCell";
static NSString *const kNoFriendsReuseIdentifier = @"NoFriendsCell";
static NSString *const kEmptySearchMessage = @"Please enter friend's name or email to search!";
static NSString *const kEmptySearchResultMessage = @"Could not find anything for \"%@\"!";
static NSString *const kGoToMessageDetailSegueIdentifier = @"goToMessageDetail";
static NSString *const kOnlineFriendsSectionHeader = @"Online Friends";
static NSString *const kOfflineFriendsSectionHeader = @"Offline Friends";
static NSString *const kEmptyFriendsTableViewMessage = @"You don't have any friends.";

@interface FriendsViewController () {
    User *_currentUser;
    NSArray<NSString *> *_requestActions;
    NSMutableArray<User *> *_onlineFriends;
    NSMutableArray<User *> *_offlineFriends;
    NSIndexPath *_selectedIndexPath;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchTextFieldLeadingConstraint;
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = self.navigationItem.titleView.frame;
    frame.size.width = [UIViewConstant screenWidth];
    self.navigationItem.titleView.frame = frame;
    _currentUser = ((MainTabBarViewController *)self.navigationController.tabBarController).loggedInUser;
    _requestActions = @[kUpdateOnlineStatusToUserAction];
    [self registerRequestHandler];
    _onlineFriends = [NSMutableArray array];
    _offlineFriends = [NSMutableArray array];
    [self detachFriendsByOnlineStatus];
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

- (void)detachFriendsByOnlineStatus {
    for (User *user in _currentUser.friends) {
        if (user.status.integerValue) {
            [_onlineFriends addObject:user];
        } else {
            [_offlineFriends addObject:user];
        }
    }
}

#pragma mark - UITableViewDatasource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!_onlineFriends.count || !_offlineFriends.count) {
        return 1;
    }
    return NumberOfFriendSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!_currentUser.friends.count) {
        return 1;
    }
    if (!_onlineFriends.count) {
        return _offlineFriends.count;
    }
    if (!_offlineFriends.count) {
        return _onlineFriends.count;
    }
    switch (section) {
        case OnlineFriendsSection: {
            return _onlineFriends.count;
        }
        case OfflineFriendsSection: {
            return _offlineFriends.count;
        }
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (!_currentUser.friends.count) {
        return @"";
    }
    if (!_onlineFriends.count) {
        return kOfflineFriendsSectionHeader;
    }
    if (!_offlineFriends.count) {
        return kOnlineFriendsSectionHeader;
    }
    switch (section) {
        case OnlineFriendsSection:
            return kOnlineFriendsSectionHeader;
        case OfflineFriendsSection:
            return kOfflineFriendsSectionHeader;
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_currentUser.friends.count) {
        return [Utils emptyTableCell:kEmptyFriendsTableViewMessage];
    }
    FriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendReuseIdentifier
        forIndexPath:indexPath];
    if (!cell) {
        return [UITableViewCell new];
    }
    if (!_onlineFriends.count) {
        [cell setUser:_offlineFriends[indexPath.row]];
        return cell;
    }
    if (!_offlineFriends.count) {
        [cell setUser:_onlineFriends[indexPath.row]];
        return cell;
    }
    switch (indexPath.section) {
        case OnlineFriendsSection: {
            [cell setUser:_onlineFriends[indexPath.row]];
            break;
        }
        case OfflineFriendsSection: {
            [cell setUser:_offlineFriends[indexPath.row]];
            break;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!_currentUser.friends.count) {
        return 0.01f;
    }
    return 32.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!_currentUser.friends.count) {
        return;
    }
    _selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:kGoToMessageDetailSegueIdentifier sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_currentUser.friends.count) {
        return tableView.frame.size.height;
    }
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - IBAction

- (IBAction)btnBackTapped:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
        case UpdateOnlineStatusToUserAction: {
            NSArray *array = [message componentsSeparatedByString:@"-"];
            if ([array containsObject:@""]) {
                return;
            }
            NSInteger userId = [array[0] integerValue];
            NSString *onlineStatus = array[1];
            [self updateOnlineStatus:onlineStatus userId:userId];
            [self.tableView reloadData];
            break;
        }
    }
}

- (void)updateOnlineStatus:(NSString *)onlineStatus userId:(NSInteger)userId {
    if ([onlineStatus isEqualToString:kFailureMessage]) {
        for (User *user in _onlineFriends) {
            if (userId == user.userId.integerValue) {
                if (!user.status.integerValue) {
                    [_onlineFriends removeObject:user];
                    [_offlineFriends insertObject:user atIndex:0];
                }
                return;
            }
        }
    } else {
        for (User *user in _offlineFriends) {
            if (userId == user.userId.integerValue) {
                [_offlineFriends removeObject:user];
                [_onlineFriends insertObject:user atIndex:0];
                return;
            }
        }
        for (User *user in _onlineFriends) {
            if (userId == user.userId.integerValue) {
                return;
            }
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:kGoToMessageDetailSegueIdentifier]) {
        User *selectedUser;
        if (!_onlineFriends.count) {
            selectedUser = _offlineFriends[_selectedIndexPath.row];
        } else if (!_offlineFriends.count) {
            selectedUser = _onlineFriends[_selectedIndexPath.row];
        } else if (_onlineFriends.count && _offlineFriends.count) {
            switch (_selectedIndexPath.section) {
                case OnlineFriendsSection: {
                    selectedUser = _onlineFriends[_selectedIndexPath.row];
                    break;
                }
                case OfflineFriendsSection: {
                    selectedUser = _offlineFriends[_selectedIndexPath.row];
                    break;
                }
            }
        }
        MessageDetailViewController *messageDetailViewController = segue.destinationViewController;
        messageDetailViewController.receiver = selectedUser;
    }
}

@end
