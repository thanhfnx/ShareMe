//
//  RequestHandler.h
//  SocialNetwork
//
//  Created by Nguyen Xuan Thanh on 8/17/16.
//  Copyright © 2016 Nguyen Xuan Thanh. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RequestHandler <NSObject>

- (void)registerRequestHandler;
- (void)resignRequestHandler;
- (void)handleRequest:(NSString *)actionName message:(NSString *)message;

@end
