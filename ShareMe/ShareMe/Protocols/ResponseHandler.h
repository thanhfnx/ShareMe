//
//  RequestHandler.h
//  SocialNetwork
//
//  Created by Nguyen Xuan Thanh on 8/10/16.
//  Copyright © 2016 Nguyen Xuan Thanh. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ResponseHandler <NSObject>

- (void)handleResponse:(NSString *)actionName message:(NSString *)message;

@end
