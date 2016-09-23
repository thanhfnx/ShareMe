//
//  TimelineViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/23/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "TimelineViewController.h"
#import "StoryTableViewCell.h"
#import "ApplicationConstants.h"
#import "ClientSocketController.h"
#import "User.h"
#import "Utils.h"

typedef NS_ENUM(NSInteger, UserRequestActions) {
    GetUserByIdAction
};

static NSString *const kStoryReuseIdentifier = @"StoryCell";
static NSString *const kDefaultMessageTitle = @"Warning";
static NSString *const kGetUserErrorMessage = @"Something went wrong! Can not get this user's information!";

@interface TimelineViewController () {
    NSMutableDictionary<NSIndexPath *, NSNumber *> *heightForIndexPath;
    NSArray<NSString *> *_responseActions;
    NSArray<NSString *> *_requestActions;
    User *_user;
    NSMutableArray<Story *> *_topStories;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *imvCover;
@property (weak, nonatomic) IBOutlet UIImageView *imvAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblFullName;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *btnAction;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = self.navigationItem.titleView.frame;
    frame.size.width = [UIViewConstant screenWidth];
    self.navigationItem.titleView.frame = frame;
    _responseActions = @[kGetUserByIdAction];
    [self loadUserById];
    [self.view layoutIfNeeded];
    CGRect headerViewFrame = self.headerView.frame;
    headerViewFrame.size.height = self.btnAction.frame.origin.y + self.btnAction.frame.size.height + 16.0f;
    self.headerView.frame = headerViewFrame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUserById {
    [ClientSocketController sendData:[@(self.userId) stringValue] messageType:kSendingRequestSignal
        actionName:kGetUserByIdAction sender:self];
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
    }
}

@end
