//
//  NewStoryViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 8/26/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "NewStoryViewController.h"
#import "MainTabBarViewController.h"
#import "ClientSocketController.h"
#import "UIViewController+ResponseHandler.h"
#import "ThumbnailCollectionViewCell.h"
#import "Utils.h"
#import "Story.h"
#import "FDateFormatter.h"
#import "NewsFeedViewController.h"

static NSString *const kThumbnailReuseIdentifier = @"ThumbnailCell";
static NSString *const kDefaultMessageTitle = @"Warning";
static NSString *const kConfirmMessageTitle = @"Confirm";
static NSString *const kConfirmDiscardStory = @"This story is unsaved! Are you sure to discard this story?";
static NSString *const kAddNewStoryErrorMessage = @"Something went wrong! Can not post new story!";
static CGFloat const kMaxImageWidth = 1920.0f;
static CGFloat const kMaxImageHeight = 1080.0f;
static NSInteger const kNumberOfCell = 4;
static NSString *const kImageMessageFormat = @"{%.0f, %.0f}-%@";

@interface NewStoryViewController () {
    NSMutableArray<UIImage *> *_images;
    CGFloat _cellWidth;
    NSDateFormatter *_dateFormatter;
    Story *_story;
    User *_currentUser;
    BOOL _isStoryUnsaved;
    NewsFeedViewController *_newsFeedViewController;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextView *txvContent;
@property (weak, nonatomic) IBOutlet UIView *vToolBar;
@property (weak, nonatomic) IBOutlet UILabel *lblPlaceHolder;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTextViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeightConstraint;

@end

@implementation NewStoryViewController

#pragma mark - UIView Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = self.navigationItem.titleView.frame;
    frame.size.width = [UIViewConstant screenWidth];
    self.navigationItem.titleView.frame = frame;
    [self.txvContent becomeFirstResponder];
    _images = [NSMutableArray array];
    _dateFormatter = [FDateFormatter sharedDateFormatter];
    _dateFormatter.dateFormat = kDefaultDateTimeFormat;
    _cellWidth = ([UIViewConstant screenWidth] - 8.0f * (kNumberOfCell + 1)) / kNumberOfCell;
    _currentUser = ((MainTabBarViewController *)self.navigationController.tabBarController).loggedInUser;
}

- (void)viewWillAppear:(BOOL)animated {
    _isStoryUnsaved = YES;
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
        name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
        name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.lblPlaceHolder.hidden = [self.txvContent hasText];
}

#pragma mark - IBAction

- (IBAction)btnBackTapped:(UIButton *)sender {
    [self dismissKeyboard];
    if (_isStoryUnsaved && ([self.txvContent hasText] || _images.count > 0)) {
        [self showConfirmDialog:kConfirmDiscardStory title:kConfirmMessageTitle handler:^(UIAlertAction *action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)btnAddImageTapped:(UIButton *)sender {
    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.maximumNumberOfSelection = 20;
    imagePickerController.showsNumberOfSelectedAssets = YES;
    imagePickerController.assetCollectionSubtypes = @[@(PHAssetCollectionSubtypeSmartAlbumUserLibrary)];
    imagePickerController.mediaType = QBImagePickerMediaTypeImage;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (IBAction)btnAddEmoticonTapped:(UIButton *)sender {
    // TODO: Optional function
}

- (IBAction)btnAddLocationTapped:(UIButton *)sender {
    // TODO: Optional function
}

- (IBAction)btnPostTapped:(UIButton *)sender {
    if ([self.txvContent hasText] || _images.count > 0) {
        _newsFeedViewController = self.navigationController.viewControllers[0];
        _isStoryUnsaved = NO;
        [self dismissKeyboard];
        CGRect frame = [[UIScreen mainScreen] bounds];
        frame.origin.y -= 44.0f;
        [self showActitvyIndicator:self.view frame:frame];
        [self getStory];
        [ClientSocketController sendData:[_story toJSONString] messageType:kSendingRequestSignal
            actionName:kUserCreateNewStoryAction sender:self];
    }
}

- (IBAction)btnDeleteImageTapped:(UIButton *)sender {
    NSInteger index = sender.tag;
    [_images removeObjectAtIndex:index];
    [self.collectionView reloadData];
    [self hideCollectionViewIfNeeded];
}

#pragma mark - Packing entity

- (void)getStory {
    if (!_story) {
        _story = [[Story alloc] init];
    }
    User *creator = [[User alloc] init];
    creator.userId = _currentUser.userId;
    _story.creator = creator;
    _story.content = self.txvContent.text;
    _story.createdTime = [_dateFormatter stringFromDate:[NSDate date]];
    _story.images = [NSMutableArray<Optional> array];
    for (UIImage *imageData in _images) {
        [_story.images addObject:[NSString stringWithFormat:kImageMessageFormat,
            imageData.size.width * [UIViewConstant screenScale], imageData.size.height * [UIViewConstant screenScale],
            [UIImageJPEGRepresentation(imageData, 0.9f) base64EncodedStringWithOptions:kNilOptions]]];
    }
}

#pragma mark - Show / hide keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{
        CGFloat offset = keyboardSize.height;
        self.toolBarViewBottomConstraint.constant += offset;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        self.toolBarViewBottomConstraint.constant = 0.0f;
    }];
}

#pragma mark - Show / hide collection view

- (void)showCollectionView {
    self.contentTextViewBottomConstraint.constant += (_cellWidth + 24.0f);
    self.collectionViewHeightConstraint.constant = _cellWidth + 16.0f;
    [self.collectionView reloadData];
}

- (void)hideCollectionViewIfNeeded {
    if (_images.count == 0) {
        self.contentTextViewBottomConstraint.constant = 8.0f;
        self.collectionViewHeightConstraint.constant = 0.0f;
    }
}

#pragma mark - QBImagePickerControllerDelegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController
    didFinishPickingAssets:(NSArray *)assets {
    [_images removeAllObjects];
    for (PHAsset *asset in assets) {
        [_images addObject:[self getUIImageFromAsset:asset]];
    }
    [self showCollectionView];
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.txvContent becomeFirstResponder];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self hideCollectionViewIfNeeded];
    [self.txvContent becomeFirstResponder];
}

- (UIImage *)getUIImageFromAsset:(PHAsset *)asset {
    PHImageManager *manager = [PHImageManager defaultManager];
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    __block UIImage *image = [[UIImage alloc] init];
    option.synchronous = true;
    [manager requestImageForAsset:asset targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)
        contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result,
        NSDictionary * _Nullable info) {
        image = result;
    }];
    NSInteger width, height;
    if (asset.pixelWidth < kMaxImageWidth && asset.pixelHeight < kMaxImageHeight) {
        width = asset.pixelWidth;
        height = asset.pixelHeight;
    } else {
        float ratio;
        if (asset.pixelWidth > asset.pixelHeight) {
            ratio = kMaxImageWidth / asset.pixelWidth;
        } else {
            ratio = kMaxImageHeight / asset.pixelHeight;
        }
        width = asset.pixelWidth * ratio;
        height = asset.pixelHeight * ratio;
    }
    image = [Utils resize:image scaledToSize:CGSizeMake(width / [UIViewConstant screenScale], height / [UIViewConstant screenScale])];
    return image;
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
    cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ThumbnailCollectionViewCell *cell = [collectionView
        dequeueReusableCellWithReuseIdentifier:kThumbnailReuseIdentifier forIndexPath:indexPath];
    cell.imvThumbnail.image = _images[indexPath.row];
    cell.btnDelete.tag = indexPath.row;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(_cellWidth, _cellWidth);
}

#pragma mark - Response Handler

- (void)handleResponse:(NSString *)actionName message:(NSString *)message {
    if ([message isEqualToString:kFailureMessage]) {
        [self showMessage:kAddNewStoryErrorMessage title:kDefaultMessageTitle complete:nil];
    } else {
        _story.storyId = @(message.integerValue);
        _story.creator = _currentUser;
        _story.images = _images;
        [_newsFeedViewController.topStories insertObject:_story atIndex:0];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateNewsFeedNotificationName object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
