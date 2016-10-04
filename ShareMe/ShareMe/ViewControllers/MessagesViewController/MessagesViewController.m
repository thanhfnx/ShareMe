//
//  MessagesViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/28/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "MessagesViewController.h"
#import "User.h"
#import "Message.h"
#import "ClientSocketController.h"
#import "UIViewConstant.h"
#import "MainTabBarViewController.h"
#import "FDateFormatter.h"
#import "MessageTableViewCell.h"
#import "MessageDetailViewController.h"
#import "Utils.h"

typedef NS_ENUM(NSInteger, UserResponseActions) {
    UserGetLatestMessagesAction
};

typedef NS_ENUM(NSInteger, UserRequestActions) {
    AddNewMessageToUserAction
};

static NSString *const kMessageReuseIdentifier = @"MessageCell";
static NSString *const kGoToMessageDetailSegueIdentifier = @"goToMessageDetail";
static NSString *const kGetLatestMessagesFormat = @"%ld-%ld-%ld";
static NSInteger const kNumberOfLatestMessages = 20;

@interface MessagesViewController () {
    NSMutableArray<Message *> *_latestMessages;
    NSArray<NSString *> *_responseActions;
    NSArray<NSString *> *_requestActions;
    User *_currentUser;
    NSInteger _startIndex;
    UIRefreshControl *_topRefreshControl;
    NSInteger _selectedIndex;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = self.navigationItem.titleView.frame;
    frame.size.width = [UIViewConstant screenWidth];
    self.navigationItem.titleView.frame = frame;
    _latestMessages = ((MainTabBarViewController *)self.navigationController.tabBarController).latestMessages;
    _requestActions = @[kAddNewMessageToUserAction];
    [self registerRequestHandler];
    _currentUser = ((MainTabBarViewController *)self.navigationController.tabBarController).loggedInUser;
    _topRefreshControl = [[UIRefreshControl alloc] init];
    [_topRefreshControl addTarget:self action:@selector(loadLatestMessages)
        forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_topRefreshControl];
}

- (void)loadLatestMessages {
    _startIndex = _latestMessages.count;
    NSString *message = [NSString stringWithFormat:kGetLatestMessagesFormat, _currentUser.userId.integerValue,
        _startIndex, kNumberOfLatestMessages];
    [[ClientSocketController sharedController] sendData:message messageType:kSendingRequestSignal
        actionName:kUserGetMessagesAction sender:self];
}

#pragma mark - UITableViewDatasource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _latestMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMessageReuseIdentifier
        forIndexPath:indexPath];
    if (!cell) {
        return [UITableViewCell new];
    }
    [cell setMessage:_latestMessages[indexPath.row] currentUser:_currentUser];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:kGoToMessageDetailSegueIdentifier sender:self];
}

#pragma mark - Response Handler

- (void)handleResponse:(NSString *)actionName message:(NSString *)message {
    NSInteger index = [_responseActions indexOfObject:actionName];
    switch (index) {
        case UserGetLatestMessagesAction: {
            if (![message isEqualToString:kFailureMessage]) {
                NSError *error;
                // TODO: Handle error
                [_latestMessages addObjectsFromArray:[Message arrayOfModelsFromString:message error:&error]];
            }
            break;
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
        case UserGetLatestMessagesAction: {
            NSError *error;
            Message *receivedMessage = [[Message alloc] initWithString:message error:&error];
            // TODO: Handle error
            if (receivedMessage) {
                [_latestMessages insertObject:receivedMessage atIndex:0];
                [self.tableView reloadData];
            }
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
