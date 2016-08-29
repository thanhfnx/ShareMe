//
//  AppDelegate.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/18/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "AppDelegate.h"
#import "ClientSocketController.h"

@interface AppDelegate () {
    ClientSocketController *_clientSocketController;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _clientSocketController = [[ClientSocketController alloc] init];
    [_clientSocketController openSocket];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [ClientSocketController sendData:kEmptyMessage messageType:kSendingRequestSignal actionName:kCloseConnection
        sender:nil];
    [_clientSocketController closeSocket];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [_clientSocketController openSocket];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [_clientSocketController closeSocket];
}

@end
