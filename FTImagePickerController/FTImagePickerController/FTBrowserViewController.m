//
//  FTBrowserViewController.m
//  FTImagePickerController
//
//  Created by 方焘 on 16/5/29.
//  Copyright © 2016年 taofang. All rights reserved.
//

#import "FTBrowserViewController.h"
#import "FTBadgeView.h"
#import "FTBrowserViewCell.h"
#import "FTAssetsImageManager.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
@interface FTBrowserViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) FTImagePickerController *picker;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) FTBadgeView *badgeView;
@property (nonatomic) CGRect previousPreheatRect;
@property (nonatomic, strong) PHImageRequestOptions *options;

@end


@implementation FTBrowserViewController
{
    UICollectionView *_collectionView;
    UIPageControl *_pageControl;
    UIButton *_selectionButton;
    CGFloat screenWidth;
    CGFloat screenHeight;
}
NSString * const FTBrowserViewCellIdentifier = @"FTBrowserViewCellIdentifier";

- (void)initializeCollectionView {
    
    CGRect frame = self.view.frame;
    frame.size.width += FTBrowserRightMargin;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = frame.size;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsZero;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[FTBrowserViewCell class] forCellWithReuseIdentifier:FTBrowserViewCellIdentifier];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.pagingEnabled = YES;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.contentOffset = CGPointMake(self.currentIndex * _collectionView.frame.size.width, 0);
    [self.view addSubview:_collectionView];
}

- (void)initializePageControl {
    
    _pageControl = [[UIPageControl alloc] init];
    [self setPageControlHidden:YES];
    _pageControl.numberOfPages = self.assets.count;
    _pageControl.currentPage = self.currentIndex;
    CGPoint center = _pageControl.center;
    center.x = self.view.center.x;
    center.y = CGRectGetMaxY(self.view.frame) - _pageControl.frame.size.height / 2 - 20;
    _pageControl.center = center;
    [self.view addSubview:_pageControl];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _selectionButton.selected = [self imageIsSelectedWithIndex:self.currentIndex];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializePageControl];
    [self initializeCollectionView];
    self.view.backgroundColor = [UIColor blackColor];
    UIButton *selectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    selectionButton.bounds = CGRectMake(0,0,27,27);
    selectionButton.contentMode = UIViewContentModeTopRight;
    selectionButton.adjustsImageWhenHighlighted = NO;
    [selectionButton setImage:[UIImage imageNamed:[@"FTImagePickerController.bundle" stringByAppendingPathComponent:@"tickw.png"]] forState:UIControlStateNormal];
    [selectionButton setImage:[UIImage imageNamed:[@"FTImagePickerController.bundle" stringByAppendingPathComponent:@"tickH.png"]] forState:UIControlStateSelected];
    selectionButton.hidden = NO;
    _selectionButton = selectionButton;
    [selectionButton addTarget:self action:@selector(didClickSelectionButton) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:selectionButton];
}

- (void)didClickSelectionButton {
    _selectionButton.selected = !_selectionButton.isSelected;
    NSAssert(self.imageIsSelectedBlock, @"imageIsSelectedBlock cannot be nil");
    self.imageIsSelectedBlock(self.currentIndex, _selectionButton.isSelected);
}

- (instancetype)initWithPicker:(FTImagePickerController *)picker {

    if (self = [super init]) {
        self.picker = picker;
        self.options = [[PHImageRequestOptions alloc]init];
        
    }
    return self;
}

- (void)setPageControlHidden:(BOOL)hidden {
    if (hidden) {
        _pageControl.hidden = YES;
    } else {
        if (self.assets.count > 1 && !self.alwaysPageControlHidden) {
            _pageControl.hidden = NO;
        }
    }
}
#pragma mark - collectionView dataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FTBrowserViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:FTBrowserViewCellIdentifier forIndexPath:indexPath];
    
    PHAsset *asset = self.assets[indexPath.item];
    __weak typeof(cell) WeakCell = cell;
    __weak typeof(collectionView) weakCollectionView = collectionView;
     CGFloat scale = [UIScreen mainScreen].scale;
    [[FTAssetsImageManager sharedInstance]requestImageWithAsset:asset
                                                      targetSize:CGSizeMake(kScreenWidth * scale, kScreenWidth * scale)
                                                     contentMode:PHImageContentModeAspectFit options:self.options
                                                   resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                       [WeakCell setImage:result];
                                                       [weakCollectionView reloadItemsAtIndexPaths:@[indexPath]];
                                                   }];
    
    //缓存旁边图片
    NSMutableArray *nums = [NSMutableArray array];
    if (indexPath.item - 1 > 0) {
        [nums addObject:@(indexPath.item - 1)];
    }
    if (indexPath.item + 1 < self.assets.count) {
        [nums addObject:@(indexPath.item + 1)];
    }
    [self cacheImageWithIndex:nums.copy];
    return cell;
}

- (void)cacheImageWithIndex:(NSArray<NSNumber *> *)indexs {
    NSMutableArray *temAssets = [NSMutableArray arrayWithCapacity:indexs.count];
    for (NSNumber *num in indexs) {
        [temAssets addObject:self.assets[[num integerValue]]];
    }
    CGFloat scale = [UIScreen mainScreen].scale;
    [[FTAssetsImageManager sharedInstance].phCachingImageManager startCachingImagesForAssets:temAssets.copy targetSize:CGSizeMake(kScreenWidth * scale, kScreenWidth * scale) contentMode:PHImageContentModeAspectFill options:self.options];
}

#pragma mark scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger index = (NSInteger)(scrollView.contentOffset.x / scrollView.bounds.size.width);
    if (self.currentIndex != index) {
        self.currentIndex = index;
        _selectionButton.selected = [self imageIsSelectedWithIndex:self.currentIndex];
        NSAssert(self.shouldSelectItemBlock, @"shouldSelectItemBlock cannot be nil");
        _selectionButton.enabled = self.shouldSelectItemBlock();
    }
}

#pragma mark 判断是否是被选中的
- (BOOL)imageIsSelectedWithIndex:(NSInteger)index {
    if ([self.picker.selectedAssets containsObject:self.assets[index]]) {
        return YES;
    }
    return NO;
}

@end
