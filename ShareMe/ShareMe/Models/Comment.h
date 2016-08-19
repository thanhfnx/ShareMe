//
//  Comment.h
//  SocialNetwork
//
//  Created by Nguyen Xuan Thanh on 8/1/16.
//  Copyright © 2016 Nguyen Xuan Thanh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@class User;
@class Story;

@protocol Comment

@end

@interface Comment : JSONModel

@property (strong, nonatomic) NSNumber *commentId;
@property (strong, nonatomic) User<Optional> *creator;
@property (strong, nonatomic) Story<Optional> *story;
@property (strong, nonatomic) NSString<Optional> *content;
@property (strong, nonatomic) NSString<Optional> *createdTime;

@end
