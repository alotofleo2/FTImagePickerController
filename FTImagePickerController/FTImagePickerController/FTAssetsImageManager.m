//
//  FTImageManager.m
//  FTImagePickerController
//
//  Created by 方焘 on 16/5/29.
//  Copyright © 2016年 taofang. All rights reserved.
//

#import "FTAssetsImageManager.h"

@interface FTAssetsImageManager ()
@property (nonatomic, strong) NSCache *imageCache;

@end


@implementation FTAssetsImageManager
- (void)removeAllObjects {
    [self.imageCache removeAllObjects];
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [self.phCachingImageManager stopCachingImagesForAllAssets];
    }
    
    
}

+ (instancetype)sharedInstance {
    static FTAssetsImageManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[FTAssetsImageManager alloc]init];
    });
    return _instance;
}



- (void)requestImageWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize contentMode:(PHImageContentMode)contextMode options:(PHImageRequestOptions *)options resultHandler:(void (^)(UIImage *, NSDictionary *))resultHandler {
    NSString *ID = [self identifierWithAssset:asset targetSize:targetSize];
    if ([self.imageCache objectForKey:ID]) {
        resultHandler([self.imageCache objectForKey:ID], nil);
        return;
    } else {
       [self.phCachingImageManager requestImageForAsset:asset targetSize:targetSize contentMode:contextMode options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            // 排除取消，错误，低清图三种情况，即已经获取到了高清图时，把这张高清图缓存到 _previewImage 中
            BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (downloadFinined) {
                [self.imageCache setObject:result forKey:ID];
            }
            if (resultHandler) {
                resultHandler(result, info);
            }
        }];
        return;
    }
}

- (NSString *)identifierWithAssset:(PHAsset *)asset targetSize:(CGSize)targetSize {
    return [NSString stringWithFormat:@"%@%@",asset.localIdentifier, NSStringFromCGSize(targetSize)];
}

- (NSCache *)imageCache {
    if (!_imageCache) {
        _imageCache = [NSCache new];
    }
    return _imageCache;
}

- (PHCachingImageManager *)phCachingImageManager {
    if (!_phCachingImageManager) {
        _phCachingImageManager = [PHCachingImageManager new];
    }
    return _phCachingImageManager;
}

@end
