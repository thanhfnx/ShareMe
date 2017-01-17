//
//  MainAppController.h
//  SocialNetwork
//
//  Created by Nguyen Xuan Thanh on 8/10/16.
//  Copyright © 2016 Nguyen Xuan Thanh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplicationConstants.h"

@interface ClientSocketController : NSObject <NSStreamDelegate>

+ (instancetype)sharedController;
- (BOOL)isConnected;
- (void)openSocket;
- (void)closeSocket;
- (void)sendData:(NSString *)message messageType:(NSString *)messageType actionName:(NSString *)actionName
    sender:(UIViewController *)sender;
- (void)registerRequestHandler:(NSString *)actionName receiver:(UIViewController *)receiver;
- (void)resignRequestHandler:(NSString *)actionName receiver:(UIViewController *)receiver;

@end
