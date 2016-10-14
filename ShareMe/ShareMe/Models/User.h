//
//  User.h
//  SocialNetwork
//
//  Created by Nguyen Xuan Thanh on 7/18/16.
//  Copyright © 2016 Nguyen Xuan Thanh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@protocol User

@end

@interface User : JSONModel

@property (strong, nonatomic) NSNumber *userId;
@property (strong, nonatomic) NSString<Optional> *userName;
@property (strong, nonatomic) NSString<Optional> *password;
@property (strong, nonatomic) NSString<Optional> *firstName;
@property (strong, nonatomic) NSString<Optional> *lastName;
@property (strong, nonatomic) NSString<Optional> *email;
@property (strong, nonatomic) NSString<Optional> *dateOfBirth;
@property (strong, nonatomic) NSNumber<Optional> *gender;
@property (strong, nonatomic) NSNumber<Optional> *status;
@property (strong, nonatomic) NSMutableArray<User, Optional> *friends;
@property (strong, nonatomic) NSMutableArray<User, Optional> *sentRequests;
@property (strong, nonatomic) NSMutableArray<User, Optional> *receivedRequests;
@property (strong, nonatomic) NSMutableArray<Optional> *avatarImage;
@property (strong, nonatomic) NSMutableArray<Optional> *coverImage;
@property (strong, nonatomic) NSNumber<Optional> *lastLatitude;
@property (strong, nonatomic) NSNumber<Optional> *lastLongitude;

- (NSString *)fullName;

@end
