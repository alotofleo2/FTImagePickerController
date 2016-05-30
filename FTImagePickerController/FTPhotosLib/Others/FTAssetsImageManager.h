//
//  FTImageManager.h
//  FTImagePickerController
//
//  Created by 方焘 on 16/5/29.
//  Copyright © 2016年 taofang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Photos;
NS_ASSUME_NONNULL_BEGIN

@interface FTAssetsImageManager : NSObject
@property (nonatomic, strong) PHCachingImageManager *phCachingImageManager;

+ (instancetype)sharedInstance;
- (void)removeAllObjects;
- (void)requestImageWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize contentMode:(PHImageContentMode)contextMode options:(PHImageRequestOptions *)options resultHandler:(void (^)(UIImage *__nullable result, NSDictionary *__nullable info))resultHandler;

NS_ASSUME_NONNULL_END
@end
