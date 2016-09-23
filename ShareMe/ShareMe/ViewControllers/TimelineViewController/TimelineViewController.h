//
//  TimelineViewController.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/23/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FViewController.h"

@class Story;
@class Comment;

@interface TimelineViewController : FViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSInteger userId;

@end
