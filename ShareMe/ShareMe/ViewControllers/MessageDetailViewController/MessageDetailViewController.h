//
//  MessageDetailViewController.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/28/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FViewController.h"

@class User;

@interface MessageDetailViewController : FViewController <UITableViewDelegate, UITableViewDataSource,
    UITextViewDelegate>

@property (strong, nonatomic) User *receiver;

@end
