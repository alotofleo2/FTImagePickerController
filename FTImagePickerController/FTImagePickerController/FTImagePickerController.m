//
//  FTImagePickerController.m
//  FTImagePickerController
//
//  Created by 方焘 on 16/5/29.
//  Copyright © 2016年 taofang. All rights reserved.
//

#import "FTImagePickerController.h"
#import "FTAlbumsViewController.h"
#import "FTImageClipViewController.h"
#import "FTBadgeView.h"
#import "FTAssetsImageManager.h"

@import Photos;
@implementation FTImagePickerController
- (void)dealloc {
    NSLog(@"dealloc");
    
//    [[FTAssetsImageManager sharedInstance] removeAllObjects];
    
}

- (instancetype)init {
    if (self = [super init]) {
        _selectedAssets = [[NSMutableArray alloc] init];
        _mediaTypes = @[@(PHAssetMediaTypeImage)];
        _navigationController = [[UINavigationController alloc] initWithRootViewController:[[FTAlbumsViewController alloc] init]];
        _navigationController.navigationBar.barTintColor = [UIColor colorWithRed:71/255.0f green:71/255.0f blue:89/255.0f alpha:0.8f];
        _navigationController.navigationBar.tintColor = [UIColor whiteColor];
        _navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSForegroundColorAttributeName  :   [UIColor whiteColor],
                                                                    NSFontAttributeName             :   [UIFont systemFontOfSize:18]
                                                                    };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController willMoveToParentViewController:self];
    [self.navigationController.view setFrame:self.view.frame];
    [self.view addSubview:self.navigationController.view];
    [self addChildViewController:self.navigationController];
    [self.navigationController didMoveToParentViewController:self];
}

- (void)selectAsset:(PHAsset *)asset {
    [self.selectedAssets insertObject:asset atIndex:self.selectedAssets.count];
    if (self.allowsMultipleSelection) {
        [self updateDoneButton];
    } else {
        if (self.allowsEditing) {
            FTImageClipViewController *controller = [[FTImageClipViewController alloc] initWithPicker:self];
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            [self finishPickingAssets:self];
        }
    }
}

- (void)deselectAsset:(PHAsset *)asset {
    [self.selectedAssets removeObjectAtIndex:[self.selectedAssets indexOfObject:asset]];
    [self updateDoneButton];
}

- (void)finishPickingAssets:(id)sender {
    if ([self.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)]) {
        [self.delegate assetsPickerController:self didFinishPickingAssets:self.selectedAssets];
    }
    if ([self.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingImages:)]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSArray *arr = [self selectedImages];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate assetsPickerController:self  didFinishPickingImages:arr];
            });
        });
    }
}

- (void)dismiss:(id)sender {
    if ([self.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)]) {
        [self.delegate assetsPickerControllerDidCancel:self];
    }
    [[FTAssetsImageManager sharedInstance]removeAllObjects];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateDoneButton {
    UINavigationController *nav = (UINavigationController *)self.childViewControllers[0];
    for (UIViewController *viewController in nav.viewControllers) {
        viewController.navigationItem.rightBarButtonItem.enabled = self.selectedAssets.count > 0;
        if (viewController.navigationItem.rightBarButtonItems.count > 1) {
            UIBarButtonItem *badgeButtonItem = viewController.navigationItem.rightBarButtonItems[1];
            FTBadgeView *badgeView = badgeButtonItem.customView;
            badgeView.number = self.selectedAssets.count;
        }
    }
}

- (NSArray<UIImage *> *)selectedImages {
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = YES;
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:self.selectedAssets.count];
    for (PHAsset *asset in self.selectedAssets) {
        CGFloat scale = [UIScreen mainScreen].scale;
        [[FTAssetsImageManager sharedInstance].phCachingImageManager requestImageForAsset:asset targetSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * scale, [UIScreen mainScreen].bounds.size.height * scale) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (downloadFinined) {
                [images addObject:result];
            }
        }];
    }
    return images;
}
@end
