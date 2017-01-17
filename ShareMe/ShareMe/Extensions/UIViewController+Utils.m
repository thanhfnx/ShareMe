//
//  UIViewController+Utils.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 12/27/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "UIViewController+Utils.h"

@implementation UIViewController (Utils)

+ (UIViewController *)findBestViewController:(UIViewController *)viewController {
    if (viewController.presentedViewController) {
        return [UIViewController findBestViewController:viewController.presentedViewController];
    } else if ([viewController isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *splitViewController = (UISplitViewController*) viewController;
        if (splitViewController.viewControllers.count > 0) {
            return [UIViewController findBestViewController:splitViewController.viewControllers.lastObject];
        } else {
            return viewController;
        }
    } else if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController *)viewController;
        if (navigationController.viewControllers.count > 0) {
            return [UIViewController findBestViewController:navigationController.topViewController];
        } else {
            return viewController;
        }
    } else if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarViewController = (UITabBarController*) viewController;
        if (tabBarViewController.viewControllers.count > 0) {
            return [UIViewController findBestViewController:tabBarViewController.selectedViewController];
        } else {
            return viewController;
        }
    } else {
        return viewController;
    }
}

+ (UIViewController *)currentViewController {
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [UIViewController findBestViewController:viewController];
}

@end
