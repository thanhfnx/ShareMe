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
#import "SearchFriendTableViewController.h"
#import "Utils.h"
#import "Story.h"
#import "User.h"

static NSString *const kDefaultMessageTitle = @"Warning";
static NSString *const kStoryReuseIdentifier = @"StoryCell";
static NSString *const kEmptySearchMessage = @"Please enter friend's name or email to search!";
static NSString *const kEmptySearchResultMessage = @"Could not find anything for \"%@\"!";
static NSString *const kGoToSearchFriendSegueIdentifier = @"goToSearchFriend";
static NSString *const kGoToNewStorySegueIdentifier = @"goToNewStory";

@interface NewsFeedViewController () {
    NSArray<User *> *_searchResult;
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
    self.tableView.estimatedRowHeight = 350;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    CGRect frame = self.navigationItem.titleView.frame;
    frame.size.width = [Utils screenWidth];
    self.navigationItem.titleView.frame = frame;
    // Create sample data
    NSArray *firstNames = @[@"Thanh", @"Linh", @"Lan", @"Nhung", @"Tuan", @"Duong"];
    NSArray *lastNames = @[@"Nguyen", @"Tran", @"Le", @"Ly"];
    NSArray *contents = @[
        @"\nKeep giggling, remembering the memories of our short shoot in Paris",
        @"\nGetting poutine asap when I get to Canada",
        @"\nLook WHO DID come over for lunch... Wow.",
        @"\nThe team fought their way out of the Colony's lair! \nSee their next move in DETECTIVE COMICS #939! #DCRecap",
        @"\n레드 립 레드 립 레드 립 레드 립 레드 립 레드 립 레드 립 레드 립 "
    ];
    NSString *content = @"SAMPLE CONTENT: ";
    self.topStories = [NSMutableArray array];
    Story *story;
    User *creator;
    for (int i = 0; i < 20; i++) {
        story = [[Story alloc] init];
        creator = [[User alloc] init];
        creator.firstName = firstNames[arc4random() % firstNames.count];
        creator.lastName = lastNames[arc4random() % lastNames.count];
        creator.userName = [NSString stringWithFormat:@"%@%@", creator.firstName, creator.lastName].lowercaseString;
        story.creator = creator;
        content = [content stringByAppendingString:contents[arc4random() % contents.count]];
        story.content = content;
        [self.topStories addObject:story];
    }
}

- (void)showMessage:(NSString *)message title:(NSString *)title
        complete:(void (^ _Nullable)(UIAlertAction *action))complete {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message
        preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:complete];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - IBAction

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
    [ClientSocketController sendData:self.txtSearch.text messageType:kSendingRequestSignal
        actionName:kUserSearchFriendAction sender:self];
}

- (IBAction)btnReloadTapped:(UIButton *)sender {
    // TODO: Reload news feed
}

- (IBAction)btnNewStoryTapped:(id)sender {
    [self.navigationController.tabBarController.tabBar setHidden:YES];
    [self performSegueWithIdentifier:kGoToNewStorySegueIdentifier sender:self];
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
    [cell setStory:self.topStories[indexPath.row]];
    return cell;
}

#pragma mark - Response Handler

- (void)handleResponse:(NSString *)actionName message:(NSString *)message {
    if ([message isEqualToString:kFailureMessage]) {
        [self showMessage:[NSString stringWithFormat:kEmptySearchResultMessage, self.txtSearch.text]
            title:kDefaultMessageTitle complete:nil];
    } else {
        NSError *error;
        _searchResult = [User arrayOfModelsFromString:message error:&error];
        self.txtSearch.text = @"";
        [self performSegueWithIdentifier:kGoToSearchFriendSegueIdentifier sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kGoToSearchFriendSegueIdentifier]) {
        SearchFriendTableViewController *searchFriendTableViewController = [segue destinationViewController];
        searchFriendTableViewController.users = _searchResult;
    }
}

@end
