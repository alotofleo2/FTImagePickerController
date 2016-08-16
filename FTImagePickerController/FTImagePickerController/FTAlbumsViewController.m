//
//  FTAlbumsViewController.m
//  FTImagePickerController
//
//  Created by 方焘 on 16/5/29.
//  Copyright © 2016年 taofang. All rights reserved.
//

#import "FTAlbumsViewController.h"
#import "FTImagePickerController.h"
#import "FTGridViewController.h"
#import "FTAlbumsViewCell.h"
#import "FTBadgeView.h"

static NSString * const FTAlbumsViewCellReuseIdentifier = @"FTAlbumsViewCellReuseIdentifier";

@interface FTAlbumsViewController () <PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) NSArray <PHFetchResult *>*fetchResults;
@property (nonatomic, strong) NSArray <PHAssetCollection *>*assetCollections;
@property (nonatomic, weak) FTImagePickerController *picker;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) FTBadgeView *badgeView;

@end

@implementation FTAlbumsViewController
- (instancetype)init {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.title = @"相册";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self.picker
                                                                            action:@selector(dismiss:)];
    self.tableView.rowHeight = kAlbumThumbnailSize.height + 0.5;
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    [self showAlbums];
                    [self.tableView reloadData];
                } else {
                    [self showNoAuthority];
                }
            });
        }];
    } else if (status == PHAuthorizationStatusAuthorized) {
        [self showAlbums];
    } else {
        [self showNoAuthority];
    }
}

// 无权限
- (void)showNoAuthority {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 150)];
    label.textColor = [UIColor darkTextColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16.0];
    label.text = @"请在\"设置\"->\"隐私\"->\"相册\"开启访问权限";
    self.tableView.tableHeaderView = label;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.bounces = NO;
}

// 有权限
- (void)showAlbums {
    self.imageManager = [[PHCachingImageManager alloc] init];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    self.fetchResults = @[smartAlbums, topLevelUserCollections];
    
    if (self.picker.allowsMultipleSelection) {
        [self attachRightBarButton];
    }
    
    if (self.picker.sourceType == FTImagePickerControllerSourceTypeSavedPhotosAlbum) {
        [self pushCameraRollViewController];
    }
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)dealloc {
    
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    
}

- (void)attachRightBarButton {
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self.picker
                                                                      action:@selector(finishPickingAssets:)];
    doneButtonItem.enabled = self.picker.selectedAssets.count > 0;
    
    self.badgeView = [[FTBadgeView alloc] init];
    self.badgeView.number = self.picker.selectedAssets.count;
    UIBarButtonItem *badgeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.badgeView];
    
    self.navigationItem.rightBarButtonItems = @[doneButtonItem, badgeButtonItem];
}

- (void)pushCameraRollViewController {
    PHFetchResult *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    
    if (collections.count > 0) {
        PHAssetCollection *collection = collections[0];
        
        FTGridViewController *cameraRollViewController = [[FTGridViewController alloc] initWithPicker:[self picker]];
        cameraRollViewController.assets = [self assetsInAssetCollection:collection];
        cameraRollViewController.title = collection.localizedTitle;
        
        [self.navigationController pushViewController:cameraRollViewController animated:NO];
    }
}

- (FTImagePickerController *)picker {
    return (FTImagePickerController *)self.navigationController.parentViewController;
}

- (void)setFetchResults:(NSArray<PHFetchResult *> *)fetchResults {
    _fetchResults = fetchResults;
    
    NSMutableArray *assetCollections = [NSMutableArray array];
    
    for (PHFetchResult *fetchResult in fetchResults)
    {
        for (PHCollection *collection in fetchResult) {
            if ([collection isKindOfClass:[PHAssetCollection class]])
            {
                PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                PHFetchResult *assets = [self assetsInAssetCollection:assetCollection];
                if (assets.count > 0) {
                    if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                        [assetCollections insertObject:assetCollection atIndex:0];
                    } else {
                        [assetCollections addObject:assetCollection];
                    }
                }
            }
        }
    }
    
    self.assetCollections = [assetCollections copy];
}

- (PHFetchResult *)assetsInAssetCollection:(PHAssetCollection *)collection {
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", self.picker.mediaTypes];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    return [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:options];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    /*
     Change notifications may be made on a background queue. Re-dispatch to the
     main queue before acting on the change as we'll be updating the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        // Loop through the section fetch results, replacing any fetch results that have been updated.
        NSMutableArray *updatedSectionFetchResults = [self.fetchResults mutableCopy];
        __block BOOL reloadRequired = NO;
        
        [self.fetchResults enumerateObjectsUsingBlock:^(PHFetchResult *collectionsFetchResult, NSUInteger index, BOOL *stop) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
            
            if (changeDetails != nil) {
                [updatedSectionFetchResults replaceObjectAtIndex:index withObject:[changeDetails fetchResultAfterChanges]];
                reloadRequired = YES;
            }
        }];
        
        if (reloadRequired) {
            self.fetchResults = updatedSectionFetchResults;
            [self.tableView reloadData];
        }
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.assetCollections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PHAssetCollection *assetCollection = self.assetCollections[indexPath.row];
    PHFetchResult *assets = [self assetsInAssetCollection:assetCollection];
    
    // Dequeue an SCAlbumsViewCell.
    FTAlbumsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FTAlbumsViewCellReuseIdentifier];
    if (cell == nil) {
        cell = [[FTAlbumsViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:FTAlbumsViewCellReuseIdentifier];
    }
    NSString *currentAlbumIdentifier = [NSString stringWithFormat:@"section -> %zd, row -> %zd", indexPath.section, indexPath.row];
    cell.representedAlbumIdentifier = currentAlbumIdentifier;
    
    // Set the cell's title.
    NSString *text = assetCollection.localizedTitle;
    NSMutableAttributedString *attrStrM = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:16]}];
    [attrStrM appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)", assets.count] attributes:@{NSForegroundColorAttributeName : [UIColor grayColor]}]];
    cell.textLabel.attributedText = [attrStrM copy];
    
    // Request an image for the collection from the PHCachingImageManager.
    CGFloat scale = [UIScreen mainScreen].scale;
    PHAsset *asset = assets.firstObject;
    [self.imageManager requestImageForAsset:asset
                                 targetSize:CGSizeMake(self.tableView.rowHeight * scale, self.tableView.rowHeight * scale)
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  // Set the cell's thumbnail image if it's still showing the same album.
                                  if ([cell.representedAlbumIdentifier isEqualToString:currentAlbumIdentifier]) {
                                      cell.thumbnailView.image = result;
                                  }
                              }];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PHAssetCollection *assetCollection = self.assetCollections[indexPath.row];
    
    FTGridViewController *gridViewController = [[FTGridViewController alloc] initWithPicker:[self picker]];
    gridViewController.assets = [self assetsInAssetCollection:assetCollection];
    gridViewController.title = assetCollection.localizedTitle;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:gridViewController animated:YES];
}
@end
