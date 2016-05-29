//
//  FTGridViewController.h
//  FTImagePickerController
//
//  Created by 方焘 on 16/5/29.
//  Copyright © 2016年 taofang. All rights reserved.
//

#import "FTImagePickerController.h"

@interface FTGridViewController : UICollectionViewController
@property (nonatomic, strong) PHFetchResult *assets;

- (instancetype)initWithPicker:(FTImagePickerController *)picker;
@end
