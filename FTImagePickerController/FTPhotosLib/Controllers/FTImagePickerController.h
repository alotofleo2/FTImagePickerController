//
//  FTImagePickerController.h
//  FTImagePickerController
//
//  Created by 方焘 on 16/5/29.
//  Copyright © 2016年 taofang. All rights reserved.
//

@import UIKit;
@import Photos;

typedef NS_ENUM(NSInteger, FTImagePickerControllerSourceType) {
    FTImagePickerControllerSourceTypePhotoLibrary,
    FTImagePickerControllerSourceTypeSavedPhotosAlbum
};

@protocol FTImagePickerControllerDelegate;

@interface FTImagePickerController : UIViewController
@property (nonatomic, strong) NSMutableArray <PHAsset *>*selectedAssets;

@property (nonatomic) FTImagePickerControllerSourceType sourceType;

@property (nonatomic, strong) NSArray *mediaTypes; // default value is an array containing PHAssetMediaTypeImage.

@property (nonatomic) BOOL allowsMultipleSelection; // default value is NO.
@property (nonatomic) NSInteger maxMultipleCount; // default is unlimited and value is 0.

// These two properties are available when allowsMultipleSelection value is NO.
@property (nonatomic) BOOL allowsEditing; // default value is NO.
@property (nonatomic) CGSize cropSize; // default value is {[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width}

@property (nonatomic, strong) UINavigationController *navigationController;

// Managing Asset Selection
- (void)selectAsset:(PHAsset *)asset;
- (void)deselectAsset:(PHAsset *)asset;

// User finish Actions
- (void)finishPickingAssets:(id)sender;
- (void)dismiss:(id)sender;

@property (nonatomic, weak) id <FTImagePickerControllerDelegate> delegate;

@end

@protocol FTImagePickerControllerDelegate <NSObject>

@optional

- (void)assetsPickerController:(FTImagePickerController *)picker didFinishPickingAssets:(NSArray <PHAsset *>*)assets;

- (void)assetsPickerController:(FTImagePickerController *)picker didFinishPickingImages:(NSArray <UIImage *>*)images;

- (void)assetsPickerControllerDidCancel:(FTImagePickerController *)picker;

- (void)assetsPickerVontrollerDidOverrunMaxMultipleCount:(FTImagePickerController *)picker;

// This method is called when allowsMultipleSelection is NO and allowsEditing is YES.
- (void)assetsPickerController:(FTImagePickerController *)picker didFinishPickingImage:(UIImage *)image;

@end