//
//  UIImage+FTHelper.h
//  FTImagePickerController
//
//  Created by 方焘 on 16/5/29.
//  Copyright © 2016年 taofang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FTHelper)
+ (CGSize)resizeForSend:(CGSize)size;

- (UIImage *)crop:(CGRect)rect scale:(CGFloat)scale;
@end
