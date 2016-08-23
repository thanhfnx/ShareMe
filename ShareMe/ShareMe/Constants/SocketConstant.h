//
//  SocketConstant.h
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/19/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocketConstant : NSObject

extern NSString *const kSendingRequestSignal;
extern NSString *const kReceivingRequestSignal;
extern NSString *const kServerHost;
extern int const kServerPort;
extern NSString *const kMessageFormat;
extern NSString *const kEndOfStream;
extern NSString *const kDelim;
extern NSString *const kSuccessMessage;
extern NSString *const kFailureMessage;
extern NSString *const kUserLoginAction;
extern NSString *const kUserRegisterAction;

@end
