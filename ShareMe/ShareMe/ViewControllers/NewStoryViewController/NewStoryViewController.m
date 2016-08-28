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
#import "Utils.h"
#import "Story.h"

static NSString *const kDefaultDateTimeFormat = @"yyyy-MM-dd hh:mm:ss";
static NSString *const kImageReuseIdentifier = @"ImageCell";
static NSString *const kDeleteButtonImage = @"delete";
static NSString *const kDefaultMessageTitle = @"Warning";
static NSString *const kConfirmMessageTitle = @"Confirm";
static NSString *const kConfirmDiscardStory = @"Are you sure to discard this story?";
static NSString *const kAddNewStoryErrorMessage = @"Something went wrong! Can not post new story!";
static NSInteger const kNumberOfCell = 4;

@interface NewStoryViewController () {
    NSMutableArray<UIImage *> *_images;
    UICollectionView *_imagesCollectionView;
    CGFloat _cellWidth;
    NSDateFormatter *_dateFormatter;
}

@property (weak, nonatomic) IBOutlet UITextView *txvContent;
@property (weak, nonatomic) IBOutlet UIView *vToolBar;
@property (weak, nonatomic) IBOutlet UILabel *lblPlaceHolder;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTextViewBottomConstraint;

@end

@implementation NewStoryViewController

#pragma mark - UIView Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = self.navigationItem.titleView.frame;
    frame.size.width = [Utils screenWidth];
    self.navigationItem.titleView.frame = frame;
    [self.txvContent becomeFirstResponder];
    _images = [NSMutableArray array];
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateFormat = kDefaultDateTimeFormat;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
        name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
        name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (![textView hasText]) {
        self.lblPlaceHolder.hidden = NO;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if (![textView hasText]) {
        self.lblPlaceHolder.hidden = NO;
    } else {
        self.lblPlaceHolder.hidden = YES;
    }
}

#pragma mark - IBAction

- (IBAction)btnBackTapped:(UIButton *)sender {
    if ([self.txvContent hasText] || _images.count > 0) {
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
        [ClientSocketController sendData:[self getStory] messageType:kSendingRequestSignal
            actionName:kUserCreateNewStoryAction sender:self];
        // TODO: Send images to server
    }
}

- (void)btnDeleteImageTapped:(UIButton *)sender {
    NSInteger index = sender.tag;
    [_images removeObjectAtIndex:index];
    [_imagesCollectionView reloadData];
}

#pragma mark - Packing entity

- (Story *)getStory {
    Story *story = [[Story alloc] init];
    User *creator = [[User alloc] init];
    creator.userId = ((MainTabBarViewController *)self.navigationController.tabBarController).loggedInUser.userId;
    story.creator = creator;
    story.content = self.txvContent.text;
    story.createdTime = [_dateFormatter stringFromDate:[NSDate date]];
    // TODO: Packing images
    return story;
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

#pragma mark - QBImagePickerControllerDelegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController
    didFinishPickingAssets:(NSArray *)assets {
    [_images removeAllObjects];
    for (PHAsset *asset in assets) {
        [_images addObject:[self getUIImageFromAsset:asset]];
    }
    [self initImagesCollectionView];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [self dismissViewControllerAnimated:YES completion:NULL];
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
    return image;
}

- (void)initImagesCollectionView {
    if (!_imagesCollectionView) {
        _cellWidth = ([Utils screenWidth] - 8.0f * (kNumberOfCell + 1)) / kNumberOfCell;
        self.contentTextViewBottomConstraint.constant += (_cellWidth + 16.0f);
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _imagesCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _imagesCollectionView.backgroundColor = [UIColor whiteColor];
        _imagesCollectionView.dataSource = self;
        _imagesCollectionView.delegate = self;
        [_imagesCollectionView registerClass:[UICollectionViewCell class]
            forCellWithReuseIdentifier:kImageReuseIdentifier];
        _imagesCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_imagesCollectionView];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_imagesCollectionView
            attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view
            attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_imagesCollectionView
            attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view
            attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_imagesCollectionView
            attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0f constant:_cellWidth + 16.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_imagesCollectionView
            attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.vToolBar
            attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f]];
    } else {
        [_imagesCollectionView reloadData];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _images.count;
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
    cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kImageReuseIdentifier
        forIndexPath:indexPath];
    UIImageView *imvThumbnail = [[UIImageView alloc] initWithFrame:CGRectZero];
    imvThumbnail.image = _images[indexPath.row];
    imvThumbnail.contentMode = UIViewContentModeScaleAspectFill;
    imvThumbnail.clipsToBounds = YES;
    imvThumbnail.translatesAutoresizingMaskIntoConstraints = NO;
    [cell addSubview:imvThumbnail];
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:imvThumbnail attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:imvThumbnail attribute:NSLayoutAttributeHeight
        relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f]];
    UIButton *btnDeleteImage = [[UIButton alloc] init];
    [btnDeleteImage setImage:[UIImage imageNamed:kDeleteButtonImage] forState:UIControlStateNormal];
    [btnDeleteImage addTarget:self action:@selector(btnDeleteImageTapped:)
        forControlEvents:UIControlEventTouchUpInside];
    btnDeleteImage.tag = indexPath.row;
    btnDeleteImage.translatesAutoresizingMaskIntoConstraints = NO;
    [cell addSubview:btnDeleteImage];
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:btnDeleteImage attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeWidth multiplier:0.25f constant:0.0f]];
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:btnDeleteImage attribute:NSLayoutAttributeHeight
        relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeHeight multiplier:0.25f constant:0.0f]];
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:btnDeleteImage attribute:NSLayoutAttributeTop
        relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f]];
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:btnDeleteImage attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(_cellWidth, _cellWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
    insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 8.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
    minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 8.0f;
}

#pragma mark - Response Handler

- (void)handleResponse:(NSString *)actionName message:(NSString *)message {
    if ([message isEqualToString:kFailureMessage]) {
        [self showMessage:kAddNewStoryErrorMessage title:kDefaultMessageTitle complete:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        // TODO
    }
}

@end
