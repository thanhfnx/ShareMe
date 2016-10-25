//
//  StoryDetailViewController.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 10/17/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FViewController.h"

@class Story;

@interface StoryDetailViewController : FViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (strong, nonatomic) Story *story;

@end
