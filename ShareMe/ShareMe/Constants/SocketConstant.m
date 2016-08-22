//
//  SocketConstant.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/19/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "SocketConstant.h"

@implementation SocketConstant

NSString *const kSendingRequestSignal = @"TO";
NSString *const kReceivingRequestSignal = @"RE";
NSString *const kServerHost = @"127.0.0.1";
int const kServerPort = 1994;
NSString *const kMessageFormat = @"%@~%@~%@!";
NSString *const kEndOfStream = @"!";
NSString *const kDelim = @"~";
NSString *const kSuccessMessage = @"TRUE";
NSString *const kFailureMessage = @"FALSE";
NSString *const kUserLoginAction = @"USER_LOGIN";

@end
