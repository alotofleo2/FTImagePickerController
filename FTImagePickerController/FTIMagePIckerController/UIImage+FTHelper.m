//
//  UIImage+FTHelper.m
//  FTImagePickerController
//
//  Created by 方焘 on 16/5/29.
//  Copyright © 2016年 taofang. All rights reserved.
//

#import "UIImage+FTHelper.h"

@implementation UIImage (FTHelper)

+ (CGSize)resizeForSend:(CGSize)size {
    
    CGSize targetSize = size;
    
    CGFloat regularLength = 1280;
    CGFloat regularFactor = 2;
    CGFloat factor = size.width >= size.height ? size.width / size.height : size.height / size.width;
    
    // 1.宽小于等于regularLength，高小于等于regularLength
    // 2.宽小于等于regularLength，高大于regularLength，且factor大于regularFactor
    // 3.宽大于regularLength，高小于等于regularLength，且factor大于regularFactor
    if ((size.width <= regularLength && size.height <= regularLength) ||
        (size.width <= regularLength && size.height >  regularLength && factor > regularFactor) ||
        (size.width >  regularLength && size.height <= regularLength && factor > regularFactor)) {
        // 保持尺寸
    }
    else {
        // 等比缩小
        // 按宽=regularLength等比缩小
        // 1.宽大于regularLength，高小于等于regularLength，且factor小于等于regularFactor
        // 2.宽大于regularLength，高大于regularLength，且宽大于等于高
        if ((size.width > regularLength && size.height <= regularLength && factor <= regularFactor) ||
            (size.width > regularLength && size.height >  regularLength && size.width >= size.height)) {
            targetSize = CGSizeMake(regularLength, regularLength * size.height / size.width);
        }
        // 按高=regularLength等比缩小
        // 1.宽小于等于regularLength，高大于regularLength，且factor小于等于regularFactor
        // 2.宽大于regularLength，高大于regularLength，且宽小于高
        else {
            targetSize = CGSizeMake(regularLength * size.width / size.height, regularLength);
        }
    }
    return targetSize;
}

- (UIImage*)crop:(CGRect)rect scale:(CGFloat)scale {
    CGPoint origin = CGPointMake(-rect.origin.x, -rect.origin.y);
    UIImage *image = nil;
    UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.height));
    [self drawInRect:CGRectMake(origin.x, origin.y, self.size.width * scale, self.size.height * scale)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
