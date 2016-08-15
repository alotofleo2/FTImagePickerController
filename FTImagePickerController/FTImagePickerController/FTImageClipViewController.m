//
//  FTImageClipViewController.m
//  FTImagePickerController
//
//  Created by 方焘 on 16/5/29.
//  Copyright © 2016年 taofang. All rights reserved.
//

#import "FTImageClipViewController.h"
#import "UIImage+FTHelper.h"

@interface FTImageClipViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) FTImagePickerController *picker;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation FTImageClipViewController 

- (instancetype)initWithPicker:(FTImagePickerController *)picker {
    self.picker = picker;
    if (self = [super init]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (CGSizeEqualToSize(self.picker.cropSize, CGSizeZero)) {
        self.picker.cropSize = CGSizeMake(screenSize.width, screenSize.width);
    }
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:[self centerFitRectWithContentSize:self.picker.cropSize containerSize:[UIScreen mainScreen].bounds.size]];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.scrollView addSubview:self.imageView];
    PHAsset *asset = self.picker.selectedAssets.firstObject;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset
                                                      targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)
                                                     contentMode:PHImageContentModeDefault
                                                         options:options
                                                   resultHandler:^(UIImage *result, NSDictionary *info) {
                                                       // 这里会调多次，需重置transform得出正确的frame
                                                       self.imageView.transform = CGAffineTransformIdentity;
                                                       self.imageView.image = result;
                                                       [self.imageView sizeToFit];
                                                       CGFloat scaleWidth = self.scrollView.frame.size.width / self.imageView.frame.size.width;
                                                       CGFloat scaleHeight = self.scrollView.frame.size.height / self.imageView.frame.size.height;
                                                       if (self.imageView.frame.size.width <= self.scrollView.frame.size.width ||
                                                           self.imageView.frame.size.height <= self.scrollView.frame.size.height) {
                                                           self.scrollView.maximumZoomScale = MAX(scaleWidth, scaleHeight);
                                                       } else {
                                                           self.scrollView.maximumZoomScale = 1;
                                                       }
                                                       self.scrollView.minimumZoomScale = MAX(scaleWidth, scaleHeight);
                                                       self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
                                                   }];
    
    // mask
    UIImageView *mask = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[@"SCImagePickerController.bundle" stringByAppendingPathComponent:@"photo_rule.png"]]];
    mask.frame = self.scrollView.frame;
    [self.view addSubview:mask];
    UIView *topMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, self.scrollView.frame.origin.y)];
    UIView *bottomMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scrollView.frame), screenSize.width, topMaskView.frame.size.height)];
    topMaskView.backgroundColor = [UIColor blackColor];
    bottomMaskView.backgroundColor = [UIColor blackColor];
    topMaskView.alpha = 0.7;
    bottomMaskView.alpha = 0.7;
    [self.view addSubview:topMaskView];
    [self.view addSubview:bottomMaskView];
    
    // button
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.frame = CGRectMake(0, screenSize.height - 120, screenSize.width / 2, 120);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.view addSubview:cancelButton];
    
    UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectButton addTarget:self action:@selector(selectButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    selectButton.frame = CGRectMake(screenSize.width / 2, screenSize.height - 120, screenSize.width / 2, 120);
    [selectButton setTitle:@"选取" forState:UIControlStateNormal];
    [self.view addSubview:selectButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Action

- (void)cancelButtonPressed:(id)sender {
    [self.picker.selectedAssets removeObjectAtIndex:0];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectButtonPressed:(id)sender {
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingImage:)]) {
        [self.picker.delegate assetsPickerController:self.picker didFinishPickingImage:[self clibImage:self.imageView.image]];
    }
}

#pragma mark - Private Method

- (UIImage *)clibImage:(UIImage *)image {
    CGFloat dirveScale = [[UIScreen mainScreen] scale];
    CGFloat scale  = self.scrollView.zoomScale;
    CGPoint offset = self.scrollView.contentOffset;
    CGFloat orignalScale = scale * dirveScale / (self.scrollView.frame.size.width * dirveScale) * self.picker.cropSize.width;
    CGPoint orignalOffset = CGPointMake(offset.x * dirveScale, offset.y * dirveScale);
    CGRect cropRect = CGRectMake(orignalOffset.x, orignalOffset.y, self.picker.cropSize.width, self.picker.cropSize.height);
    UIImage *resultImage = [image crop:cropRect scale:orignalScale];
    return resultImage;
}

- (CGRect)centerFitRectWithContentSize:(CGSize)contentSize containerSize:(CGSize)containerSize {
    CGFloat heightRatio = contentSize.height / containerSize.height;
    CGFloat widthRatio = contentSize.width / containerSize.width;
    CGSize size = CGSizeZero;
    if (heightRatio > 1 && widthRatio <= 1) {
        size = [self ratioSize:contentSize ratio:heightRatio];
    } else if (heightRatio <= 1 && widthRatio > 1) {
        size = [self ratioSize:contentSize ratio:widthRatio];
    } else {
        size = [self ratioSize:contentSize ratio:MAX(heightRatio, widthRatio)];
    }
    CGFloat x = (containerSize.width - size.width) / 2;
    CGFloat y = (containerSize.height - size.height) / 2;
    return CGRectMake(x, y, size.width, size.height);
}

- (CGSize)ratioSize:(CGSize)originSize ratio:(CGFloat)ratio {
    return CGSizeMake(originSize.width / ratio, originSize.height / ratio);
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
    self.imageView.center = actualCenter;
}


@end
