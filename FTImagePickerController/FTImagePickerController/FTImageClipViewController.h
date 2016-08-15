//
//  FTImageClipViewController.h
//  FTImagePickerController
//
//  Created by 方焘 on 16/5/29.
//  Copyright © 2016年 taofang. All rights reserved.
//

#import "FTImagePickerController.h"

@interface FTImageClipViewController : UIViewController

- (instancetype)initWithPicker:(FTImagePickerController *)picker;

@property (nonatomic, strong) UIImage *image;

@end
