//
//  WhoLikeThisViewController.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/21/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FViewController.h"

@interface WhoLikeThisViewController : FViewController <UITextFieldDelegate, UITableViewDataSource,
    UITableViewDelegate>

@property (nonatomic) NSInteger storyId;

@end
