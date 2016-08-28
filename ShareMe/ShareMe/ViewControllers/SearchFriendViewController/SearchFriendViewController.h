//
//  SearchFriendTableViewController.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/25/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FViewController.h"

@class User;

@interface SearchFriendViewController : FViewController <UITextFieldDelegate, UITableViewDataSource,
    UITableViewDelegate>

@property (strong, nonatomic) NSArray<User *> *users;
@property (strong, nonatomic) NSString *keyword;

@end
