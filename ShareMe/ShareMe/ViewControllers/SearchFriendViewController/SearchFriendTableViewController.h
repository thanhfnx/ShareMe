//
//  SearchFriendTableViewController.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/25/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface SearchFriendTableViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) NSArray<User *> *users;

@end
