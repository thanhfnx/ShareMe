//
//  UITableView+ScrollHelpers.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 10/21/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "UITableView+ScrollHelpers.h"

@implementation UITableView (ScrollHelpers)

- (void)scrollToBottom:(BOOL)animated {
    NSInteger lastSection = [self.dataSource numberOfSectionsInTableView:self] - 1;
    NSInteger lastRow = [self.dataSource tableView:self numberOfRowsInSection:lastSection] - 1;
    if (lastRow >= 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastRow inSection:lastSection];
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

@end
