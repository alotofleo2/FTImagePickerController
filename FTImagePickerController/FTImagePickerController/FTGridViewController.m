//
//  FTGridViewController.m
//  FTImagePickerController
//
//  Created by 方焘 on 16/5/29.
//  Copyright © 2016年 taofang. All rights reserved.
//

#import "FTGridViewController.h"
#import "FTImagePickerController.h"
#import "FTAlbumsViewController.h"
#import "FTGridViewCell.h"
#import "FTBadgeView.h"
#import "FTBrowserViewController.h"

@implementation NSIndexSet (Convenience)

- (NSArray *)aapl_indexPathsFromIndexesWithSection:(NSUInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    return indexPaths;
}

@end

@implementation UICollectionView (Convenience)

- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}

@end

@interface FTGridViewController () <PHPhotoLibraryChangeObserver>

@property (nonatomic, weak) FTImagePickerController *picker;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) FTBadgeView *badgeView;
@property (nonatomic) CGRect previousPreheatRect;

@end

static CGSize AssetGridThumbnailSize;
NSString * const FTGridViewCellIdentifier = @"FTGridViewCellIdentifier";
@implementation FTGridViewController
{
    CGFloat screenWidth;
    CGFloat screenHeight;
}

- (instancetype)initWithPicker:(FTImagePickerController *)picker {
    //Custom init. The picker contains custom information to create the FlowLayout
    
    
    screenWidth = CGRectGetWidth(picker.view.bounds);
    screenHeight = CGRectGetHeight(picker.view.bounds);
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 1;
    NSInteger cellTotalUsableWidth = screenWidth - 3;
    layout.itemSize = CGSizeMake(cellTotalUsableWidth / 4, cellTotalUsableWidth / 4);
    CGFloat cellTotalUsedWidth = layout.itemSize.width * 4;
    CGFloat spaceTotalWidth = screenWidth - cellTotalUsedWidth;
    CGFloat spaceWidth = spaceTotalWidth / 3;
    layout.minimumLineSpacing = spaceWidth;
    
    if (self = [super initWithCollectionViewLayout:layout]) {
        self.picker = picker;
        CGFloat scale = [UIScreen mainScreen].scale;
        AssetGridThumbnailSize = CGSizeMake(layout.itemSize.width * scale, layout.itemSize.height * scale);
        self.collectionView.allowsMultipleSelection = picker.allowsMultipleSelection;
        [self.collectionView registerClass:FTGridViewCell.class
                forCellWithReuseIdentifier:FTGridViewCellIdentifier];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageManager = [[PHCachingImageManager alloc] init];
    [self resetCachedAssets];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(1, 0, 1, 0);
    
    if (self.picker.allowsMultipleSelection) {
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
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:(UIBarButtonItemStylePlain) target:nil action:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Begin caching assets in and around collection view's visible rect.
    [self updateCachedAssets];
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (BOOL)shouldSelectItem {
    if (self.picker.maxMultipleCount > 0 && self.picker.maxMultipleCount == self.picker.selectedAssets.count) {
        if ([self.picker.delegate respondsToSelector:@selector(assetsPickerVontrollerDidOverrunMaxMultipleCount:)]) {
            [self.picker.delegate assetsPickerVontrollerDidOverrunMaxMultipleCount:self.picker];
        }
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // Check if there are changes to the assets we are showing.
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assets];
    if (collectionChanges == nil) {
        return;
    }
    
    /*
     Change notifications may be made on a background queue. Re-dispatch to the
     main queue before acting on the change as we'll be updating the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        // Get the new fetch result.
        self.assets = [collectionChanges fetchResultAfterChanges];
        
        UICollectionView *collectionView = self.collectionView;
        
        if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
            // Reload the collection view if the incremental diffs are not available
            [collectionView reloadData];
            
        } else {
            /*
             Tell the collection view to animate insertions and deletions if we
             have incremental diffs.
             */
            [collectionView performBatchUpdates:^{
                NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                if ([removedIndexes count] > 0) {
                    [collectionView deleteItemsAtIndexPaths:[removedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
                
                NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                if ([insertedIndexes count] > 0) {
                    [collectionView insertItemsAtIndexPaths:[insertedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
                
                NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                if ([changedIndexes count] > 0) {
                    [collectionView reloadItemsAtIndexPaths:[changedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
            } completion:nil];
        }
        
        [self resetCachedAssets];
    });
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = self.assets[indexPath.item];
    
    // Dequeue an SCGridViewCell.
    FTGridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:FTGridViewCellIdentifier forIndexPath:indexPath];
    cell.representedAssetIdentifier = asset.localIdentifier;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    // Request an image for the asset from the PHCachingImageManager.
    [self.imageManager requestImageForAsset:asset
                                 targetSize:AssetGridThumbnailSize
                                contentMode:PHImageContentModeAspectFill
                                    options:options
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  // Set the cell's thumbnail image if it's still showing the same asset.
                                  if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                      cell.thumbnailView.image = result;
                                  }
                              }];
    
    __weak typeof(self) weakSelf = self;
    [cell setItemSelectedBlock:^(BOOL isSelected) {
        PHAsset *asset = weakSelf.assets[indexPath.item];
        if (isSelected) {
            [weakSelf.picker selectAsset:asset];
        } else {
            [weakSelf.picker deselectAsset:asset];
        }
    }];
    
    [cell setShouldSelectItemBlock:^BOOL(){
       return [weakSelf shouldSelectItem];
    }];
    cell.allowsSelection = self.picker.allowsMultipleSelection;
    cell.selectionButton.selected = [self.picker.selectedAssets containsObject:asset]? YES : NO;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    FTBrowserViewController *browserVC = [[FTBrowserViewController alloc]initWithPicker:self.picker];
    browserVC.assets = self.assets;
    browserVC.currentIndex = indexPath.item;
    
    __weak typeof(self) weakSelf = self;
    [browserVC setImageIsSelectedBlock:^(NSInteger index, BOOL isSelected) {
        FTGridViewCell *cell = (FTGridViewCell *)[weakSelf.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        cell.selectionButton.selected = isSelected;
        PHAsset *asset = self.assets[index];
        if (isSelected) {
            [weakSelf.picker selectAsset:asset];
        } else {
            [weakSelf.picker deselectAsset:asset];
        }
    }];
    
    [browserVC setShouldSelectItemBlock:^BOOL{
        return [weakSelf shouldSelectItem];
    }];
    [self.navigationController pushViewController:browserVC animated:YES];
    
    
}



#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update cached assets for the new visible area.
    [self updateCachedAssets];
}

#pragma mark - Asset Caching

- (void)resetCachedAssets {
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets {
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:AssetGridThumbnailSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:AssetGridThumbnailSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = self.assets[indexPath.item];
        [assets addObject:asset];
    }
    
    return assets;
}

@end
