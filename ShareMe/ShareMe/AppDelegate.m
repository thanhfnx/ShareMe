//
//  AppDelegate.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/18/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "AppDelegate.h"
#import "ClientSocketController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self.window endEditing:YES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[ClientSocketController sharedController] sendData:kEmptyMessage messageType:kSendingRequestSignal
        actionName:kCloseConnection sender:nil];
    [[ClientSocketController sharedController] closeSocket];
}

@end
