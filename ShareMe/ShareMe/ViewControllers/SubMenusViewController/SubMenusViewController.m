//
//  SubMenusViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 10/4/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "SubMenusViewController.h"
#import "SubMenuTableViewCell.h"
#import "ApplicationConstants.h"

typedef NS_ENUM(NSInteger, SubMenus) {
    SaveUserAccountSubMenu,
    AutoLoginSubMenu,
    NumberOfSubMenus
};

static NSString *const kSubMenuReuseIdentifier = @"SubMenuCell";
static NSString *const kSaveUserAccountTextLabel = @"Save Account";
static NSString *const kAutoLoginTextLabel = @"Auto Login";

@interface SubMenusViewController () {
    NSArray<NSString *> *_subMenuTextLabels;
    NSNumber *_isSaveUserAccount;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SubMenusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _subMenuTextLabels = @[kSaveUserAccountTextLabel, kAutoLoginTextLabel];
    CGRect frame = self.navigationItem.titleView.frame;
    frame.size.width = [UIViewConstant screenWidth];
    self.navigationItem.titleView.frame = frame;
}

#pragma mark - UITableViewDatasource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return NumberOfSubMenus;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SubMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSubMenuReuseIdentifier
        forIndexPath:indexPath];
    if (!cell) {
        return [UITableViewCell new];
    }
    switch (indexPath.row) {
        case SaveUserAccountSubMenu: {
            _isSaveUserAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kSaveUserAccountKey];
            if (!_isSaveUserAccount || _isSaveUserAccount.boolValue) {
                [cell.switchMenu setOn:YES];
            } else {
                [cell.switchMenu setOn:NO];
            }
            break;
        }
        case AutoLoginSubMenu: {
            NSNumber *isAutoLogin = [[NSUserDefaults standardUserDefaults] objectForKey:kAutoLoginKey];
            if (!isAutoLogin || !isAutoLogin.boolValue) {
                [cell.switchMenu setOn:NO];
            } else {
                [cell.switchMenu setOn:YES];
            }
            if (!_isSaveUserAccount.boolValue) {
                [cell.switchMenu setOn:NO];
                [cell.switchMenu setEnabled:NO];
            } else {
                [cell.switchMenu setEnabled:YES];
            }
            break;
        }
    }
    cell.switchMenu.tag = indexPath.row;
    cell.lblSubMenuName.text = _subMenuTextLabels[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - IBAction

- (IBAction)switchValueChanged:(UISwitch *)sender {
    switch (sender.tag) {
        case SaveUserAccountSubMenu:
            _isSaveUserAccount = @(sender.isOn);
            [self.tableView reloadData];
            [[NSUserDefaults standardUserDefaults] setObject:@(sender.isOn) forKey:kSaveUserAccountKey];
            break;
        case AutoLoginSubMenu:
            [[NSUserDefaults standardUserDefaults] setObject:@(sender.isOn) forKey:kAutoLoginKey];
            break;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)btnBackTapped:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
