//
//  FTBrowserViewController.h
//  FTImagePickerController
//
//  Created by 方焘 on 16/5/29.
//  Copyright © 2016年 taofang. All rights reserved.
//

#import "FTImagePickerController.h"

@interface FTBrowserViewController : UIViewController
@property (nonatomic, strong) PHFetchResult *assets;
@property (nonatomic, assign) NSInteger currentIndex;

//回调Block
@property (nonatomic, copy) void(^imageIsSelectedBlock)(NSInteger index, BOOL IsSelected);
@property (nonatomic, copy) BOOL(^shouldSelectItemBlock)();
/**
 *  总是隐藏pageControl，默认为NO
 */
@property (nonatomic) BOOL alwaysPageControlHidden;

- (instancetype)initWithPicker:(FTImagePickerController *)picker;
@end
