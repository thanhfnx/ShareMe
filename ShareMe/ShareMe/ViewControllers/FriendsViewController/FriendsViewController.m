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
#import "MessageDetailViewController.h"
#import "User.h"

typedef NS_ENUM(NSInteger, UserRequestActions) {
    UpdateOnlineStatusToUserAction
};

static NSString *const kDefaultMessageTitle = @"Warning";
static NSString *const kFriendReuseIdentifier = @"FriendCell";
static NSString *const kEmptySearchMessage = @"Please enter friend's name or email to search!";
static NSString *const kEmptySearchResultMessage = @"Could not find anything for \"%@\"!";
static NSString *const kGoToMessageDetailSegueIdentifier = @"goToMessageDetail";

@interface FriendsViewController () {
    User *_currentUser;
    NSArray<NSString *> *_requestActions;
    NSInteger _selectedIndex;
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

#pragma mark - UITableViewDatasource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _currentUser.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendReuseIdentifier
        forIndexPath:indexPath];
    if (!cell) {
        return [UITableViewCell new];
    }
    [cell setUser:_currentUser.friends[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:kGoToMessageDetailSegueIdentifier sender:self];
}

- (void)reloadDataWithAnimated:(BOOL)animated {
    [self.tableView reloadData];
    NSIndexPath *lastRowIndex = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastRowIndex atScrollPosition:UITableViewScrollPositionBottom
        animated:animated];
}

#pragma mark - IBAction

- (IBAction)btnBackTapped:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    // TODO: Search friend
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
        case UpdateOnlineStatusToUserAction: {
            [self.tableView reloadData];
            break;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:kGoToMessageDetailSegueIdentifier]) {
        MessageDetailViewController *messageDetailViewController = [segue destinationViewController];
        messageDetailViewController.receiver = _currentUser.friends[_selectedIndex];
    }
}

@end
