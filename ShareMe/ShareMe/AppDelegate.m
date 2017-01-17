//
//  AppDelegate.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/18/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "AppDelegate.h"
#import "ClientSocketController.h"
#import "UIViewController+Utils.h"
#import "StoryDetailViewController.h"
@import GoogleMaps;
@import GooglePlaces;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupLocalNotifications];
    [self setupGoogleMaps];
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

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    // TODO: Handle notification
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kDefaultMessageTitle
            message:kConnectionErrorMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [[UIViewController currentViewController] presentViewController:alertController animated:YES completion:nil];
    } else if (state == UIApplicationStateInactive) {
        UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
        for (UIViewController *vc in nav.viewControllers) {
            NSLog(@"%@", vc);
        }
    }
}

- (void)setupLocalNotifications {
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
        settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound
        categories:nil]];
}

- (void)setupGoogleMaps {
    [GMSServices provideAPIKey:kGoogleMapsAPIKey];
    [GMSPlacesClient provideAPIKey:kGoogleMapsAPIKey];
}

@end
