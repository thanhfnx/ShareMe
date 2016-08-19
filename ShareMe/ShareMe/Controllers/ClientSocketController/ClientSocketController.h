//
//  MainAppController.h
//  SocialNetwork
//
//  Created by Nguyen Xuan Thanh on 8/10/16.
//  Copyright © 2016 Nguyen Xuan Thanh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketConstant.h"

@interface ClientSocketController : NSObject <NSStreamDelegate>

- (void)openSocket;
- (void)closeSocket;
+ (void)sendData:(id)object messageType:(NSString *)messageType actionName:(NSString *)actionName
          sender:(UIViewController *)sender;
+ (void)registerRequestHandler:(NSString *)actionName receiver:(UIViewController *)receiver;

@end
