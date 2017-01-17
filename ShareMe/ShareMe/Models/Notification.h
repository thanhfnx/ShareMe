//
//  Notification.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 12/20/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@class User;
@class Story;

@protocol Notification

@end

@interface Notification : JSONModel

@property (strong, nonatomic) NSNumber *notificationId;
@property (strong, nonatomic) NSNumber<Optional> *notificationType;
@property (strong, nonatomic) User<Optional> *sender;
@property (strong, nonatomic) User<Optional> *targetUser;
@property (strong, nonatomic) Story<Optional> *targetStory;
@property (strong, nonatomic) NSString<Optional> *content;
@property (strong, nonatomic) NSString<Optional> *sentTime;

@end
