//
//  FTBrowserCell.m
//  FTImagePickerController
//
//  Created by 方焘 on 16/5/30.
//  Copyright © 2016年 taofang. All rights reserved.
//

#import "FTBrowserViewCell.h"


CGFloat const FTBrowserRightMargin = 20;
@interface FTBrowserViewCell ()
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation FTBrowserViewCell
- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        
        _imageView = [UIImageView new];
        _imageView.frame = self.contentView.bounds;

        _imageView.contentMode = UIViewContentModeScaleAspectFill;

        [self.contentView addSubview:_imageView];
        
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
    self.imageView.frame = [self imageViewRectWithImageSize:image.size];
}

- (CGRect)imageViewRectWithImageSize:(CGSize)imageSize {
    CGFloat heightRatio = imageSize.height / [UIScreen mainScreen].bounds.size.height;
    CGFloat widthRatio = imageSize.width / [UIScreen mainScreen].bounds.size.width;
    CGSize size = CGSizeZero;
    if (heightRatio > 1 && widthRatio <= 1) {
        size = [self ratioSize:imageSize ratio:heightRatio];
    }
    if (heightRatio <= 1 && widthRatio > 1) {
        size = [self ratioSize:imageSize ratio:widthRatio];
    }
    size = [self ratioSize:imageSize ratio:MAX(heightRatio, widthRatio)];
    CGFloat x = ([UIScreen mainScreen].bounds.size.width - size.width) / 2;
    CGFloat y = ([UIScreen mainScreen].bounds.size.height - size.height) / 2;
    return CGRectMake(x, y, size.width, size.height);
}

- (CGSize)ratioSize:(CGSize)originSize ratio:(CGFloat)ratio {
    return CGSizeMake(originSize.width / ratio, originSize.height / ratio);
}


@end
