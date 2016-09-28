//
//  Message.h
//  SocialNetwork
//
//  Created by Nguyen Xuan Thanh on 8/19/16.
//  Copyright © 2016 Nguyen Xuan Thanh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@class User;

@protocol Message

@end

@interface Message : JSONModel

@property (strong, nonatomic) NSNumber *messageId;
@property (strong, nonatomic) User<Optional> *sender;
@property (strong, nonatomic) User<Optional> *receiver;
@property (strong, nonatomic) NSString<Optional> *content;
@property (strong, nonatomic) NSString<Optional> *sentTime;

@end
