//
//  Story.h
//  SocialNetwork
//
//  Created by Nguyen Xuan Thanh on 8/1/16.
//  Copyright © 2016 Nguyen Xuan Thanh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "User.h"
#import "Comment.h"

@protocol Story

@end

@interface Story : JSONModel

@property (strong, nonatomic) NSNumber *storyId;
@property (strong, nonatomic) User<Optional> *creator;
@property (strong, nonatomic) NSString<Optional> *content;
@property (strong, nonatomic) NSString<Optional> *createdTime;
@property (strong, nonatomic) NSMutableArray<Optional> *images;
@property (strong, nonatomic) NSMutableArray<Comment, Optional> *comments;
@property (strong, nonatomic) NSMutableArray<User, Optional> *likedUsers;

@end
