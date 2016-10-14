//
//  MenuItemsViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 9/30/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "MenuItemsViewController.h"
#import "ClientSocketController.h"
#import "MenuItemTableViewCell.h"
#import "MainTabBarViewController.h"
#import "Utils.h"
#import "User.h"

typedef NS_ENUM(NSInteger, MenuSections) {
    ViewProfileMenuSection,
    FunctionMenuSection,
    LogOutMenuSection,
    NumberOfSections
};

typedef NS_ENUM(NSInteger, FunctionMenuItems) {
    FindFriendsMenuItem,
    SettingsMenuItem,
    AboutMenuItem,
    NumberOfFunctionMenuItems
};

static NSString *const kViewProfileReuseIdentifier = @"ViewProfileCell";
static NSString *const kMenuItemReuseIdentifier = @"MenuItemCell";
static NSString *const kLogOutReuseIdentifier = @"LogOutCell";
static NSString *const kFindFriendsIconName = @"findfriends";
static NSString *const kSettingsIconName = @"settingsitem";
static NSString *const kAboutIconName = @"about";
static NSString *const kFindFriendsTextLabel = @"Find Friends";
static NSString *const kSettingsTextLabel = @"Settings";
static NSString *const kAboutTextLabel= @"About";
static NSString *const kLogOutMessage = @"Are you sure you want to log out?";
static NSString *const kLogOutActionTitle = @"Log Out";
static NSString *const kCancelActionTitle = @"Cancel";
static NSString *const kGoToSubMenuSegueIdentifier = @"goToSubMenu";

@interface MenuItemsViewController () {
    User *_currentUser;
    NSDictionary<NSString *, NSString *> *_functionMenuItems;
}

@end

@implementation MenuItemsViewController

- (void)viewDidLoad {
    _isSwipeGestureDisable = YES;
    [super viewDidLoad];
    _currentUser = ((MainTabBarViewController *)self.navigationController.tabBarController).loggedInUser;
    _functionMenuItems = @{
        kFindFriendsIconName : kFindFriendsTextLabel,
        kSettingsIconName : kSettingsTextLabel,
        kAboutIconName : kAboutTextLabel
    };
}

#pragma mark - UITableViewDatasource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case ViewProfileMenuSection:
            return 1;
            break;
        case FunctionMenuSection:
            return NumberOfFunctionMenuItems;
            break;
        case LogOutMenuSection:
            return 1;
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == ViewProfileMenuSection) {
        return 0.01f;
    } else {
        return 16.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case ViewProfileMenuSection: {
            MenuItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kViewProfileReuseIdentifier
                forIndexPath:indexPath];
            if (!cell) {
                return [UITableViewCell new];
            }
            cell.imvMenuItemIcon.image = [Utils getAvatar:_currentUser.avatarImage gender:_currentUser.gender];
            cell.lblMenuItemName.text = [_currentUser fullName];
            return cell;
        }
        case FunctionMenuSection: {
            MenuItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMenuItemReuseIdentifier
                forIndexPath:indexPath];
            if (!cell) {
                return [UITableViewCell new];
            }
            cell.imvMenuItemIcon.image = [UIImage imageNamed:_functionMenuItems.allKeys[indexPath.row]];
            cell.lblMenuItemName.text = _functionMenuItems.allValues[indexPath.row];
            return cell;
        }
        case LogOutMenuSection: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLogOutReuseIdentifier
                forIndexPath:indexPath];
            return cell;
        }
    }
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == LogOutMenuSection) {
        return 44.0f;
    }
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case ViewProfileMenuSection: {
            _preparedUserId = _currentUser.userId.integerValue;
            [self performSegueWithIdentifier:kGoToUserTimelineSegueIdentifier sender:self];
            break;
        }
        case FunctionMenuSection: {
            switch (indexPath.row) {
                case FindFriendsMenuItem:
                    [self performSegueWithIdentifier:@"goToFindFriends" sender:self];
                    break;
                case SettingsMenuItem:
                    [self performSegueWithIdentifier:kGoToSubMenuSegueIdentifier sender:self];
                    break;
                case AboutMenuItem:
                    // TODO: Optional function
                    break;
            }
            break;
        }
        case LogOutMenuSection: {
            [self showLogOutDialog];
            break;
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)showLogOutDialog {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:kLogOutMessage
        preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *logOutAction = [UIAlertAction actionWithTitle:kLogOutActionTitle
        style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[ClientSocketController sharedController] sendData:kEmptyMessage messageType:kSendingRequestSignal
                actionName:kCloseConnection sender:nil];
            [[ClientSocketController sharedController] closeSocket];
            [self.navigationController.tabBarController dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kCancelActionTitle
        style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:logOutAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
}

@end
