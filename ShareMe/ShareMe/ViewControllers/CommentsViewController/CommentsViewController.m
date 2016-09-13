//
//  CommentsViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/12/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "CommentsViewController.h"
#import "MainTabBarViewController.h"
#import "ClientSocketController.h"
#import "CommentTableViewCell.h"
#import "FDateFormatter.h"
#import "Utils.h"
#import "Comment.h"
#import "User.h"
#import "Story.h"

typedef NS_ENUM(NSInteger, UserResponseActions) {
    UserGetTopCommentsAction,
    UserCreateNewCommentAction
};

static NSString *const kCommentReuseIdentifier = @"CommentCell";
static NSString *const kGetTopCommentsMessageFormat = @"%ld-%ld-%ld";
static NSString *const kDefaultMessageTitle = @"Warning";
static NSString *const kConfirmMessageTitle = @"Confirm";
static NSString *const kConfirmDiscardComment = @"This comment is unsaved! Are you sure to discard this comment?";
static NSString *const kAddNewCommentErrorMessage = @"Something went wrong! Can not post new story!";
static NSInteger const kNumberOfComments = 10;

@interface CommentsViewController () {
    Comment *_comment;
    NSInteger _startIndex;
    NSArray<NSString *> *_responseActions;
    NSArray<NSString *> *_requestActions;
    NSMutableArray<Comment *> *_topComments;
    User *_currentUser;
    NSDateFormatter *_dateFormatter;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *txvAddComment;
@property (weak, nonatomic) IBOutlet UILabel *lblPlaceHolder;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addCommentViewBottomConstraint;

@end

@implementation CommentsViewController

#pragma mark - UIView Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = self.navigationItem.titleView.frame;
    frame.size.width = [UIViewConstant screenWidth];
    self.navigationItem.titleView.frame = frame;
    [self.txvAddComment becomeFirstResponder];
    self.tableView.estimatedRowHeight = 44.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    _startIndex = 0;
    _topComments = [NSMutableArray array];
    _responseActions = @[
        kUserGetTopCommentsAction,
        kUserCreateNewCommentAction
    ];
    _currentUser = ((MainTabBarViewController *)self.navigationController.tabBarController).loggedInUser;
    _dateFormatter = [FDateFormatter sharedDateFormatter];
    _dateFormatter.dateFormat = kDefaultDateTimeFormat;
    [self loadComments];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
        name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
        name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)loadComments {
    [ClientSocketController sendData:[NSString stringWithFormat:kGetTopCommentsMessageFormat, self.storyId,
        _startIndex, kNumberOfComments] messageType:kSendingRequestSignal
        actionName:kUserGetTopCommentsAction sender:self];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.lblPlaceHolder.hidden = [self.txvAddComment hasText];
}

#pragma mark - UITableViewDatasource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _topComments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommentReuseIdentifier
        forIndexPath:indexPath];
    if (!cell) {
        return [UITableViewCell new];
    }
    [cell setComment:_topComments[indexPath.row]];
    return cell;
}

#pragma mark - Packing entity

- (void)getComment {
    if (!_comment) {
        _comment = [[Comment alloc] init];
    }
    User *creator = [[User alloc] init];
    creator.userId = _currentUser.userId;
    _comment.creator = creator;
    _comment.content = self.txvAddComment.text;
    _comment.createdTime = [_dateFormatter stringFromDate:[NSDate date]];
    Story *story = [[Story alloc] init];
    story.storyId = @(self.storyId);
    _comment.story = story;
}

#pragma mark - IBAction

- (IBAction)btnBackTapped:(UIButton *)sender {
    if ([self.txvAddComment hasText]) {
        [self showConfirmDialog:kConfirmDiscardComment title:kConfirmMessageTitle handler:^(UIAlertAction *action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)btnPostTapped:(UIButton *)sender {
    if ([self.txvAddComment hasText]) {
        [self dismissKeyboard];
        [self getComment];
        [ClientSocketController sendData:[_comment toJSONString] messageType:kSendingRequestSignal
            actionName:kUserCreateNewCommentAction sender:self];
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
        case UserGetTopCommentsAction:
            if ([message isEqualToString:kFailureMessage]) {
                // TODO: Replace blank table view
            } else {
                NSError *error;
                NSMutableArray *array = [Comment arrayOfModelsFromString:message error:&error];
                [_topComments addObjectsFromArray:[[[array reverseObjectEnumerator] allObjects] mutableCopy]];
                _startIndex += kNumberOfComments;;
                // TODO: Handle error
                [self.tableView reloadData];
            }
            break;
        case UserCreateNewCommentAction:
            if ([message isEqualToString:kFailureMessage]) {
                [self showMessage:kAddNewCommentErrorMessage title:kDefaultMessageTitle complete:nil];
            } else {
                _comment.commentId = @(message.integerValue);
                _comment.creator = _currentUser;
                [_topComments addObject:_comment];
                [self.txvAddComment setText:nil];
                [self.tableView reloadData];
            }
            break;
    }
}

@end
