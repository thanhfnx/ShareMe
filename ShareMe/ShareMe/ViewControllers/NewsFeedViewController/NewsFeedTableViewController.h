//
//  NewsFeedTableViewController.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/24/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsFeedTableViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *topStories;

@end
