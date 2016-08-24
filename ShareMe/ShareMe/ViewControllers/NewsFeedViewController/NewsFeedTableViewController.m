//
//  NewsFeedTableViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/24/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "NewsFeedTableViewController.h"
#import "StoryTableViewCell.h"
#import "Story.h"
#import "User.h"

static NSString *const kStoryReuseIdentifier = @"StoryCell";

@interface NewsFeedTableViewController ()

@end

@implementation NewsFeedTableViewController

#pragma mark - UIView Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 350;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
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

@end
