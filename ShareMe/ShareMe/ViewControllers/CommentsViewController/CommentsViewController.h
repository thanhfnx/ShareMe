//
//  CommentsViewController.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/12/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FViewController.h"

@interface CommentsViewController : FViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (nonatomic) NSInteger storyId;

@end
