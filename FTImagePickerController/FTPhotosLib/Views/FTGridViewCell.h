//
//  FTGridViewCell.h
//  FTImagePickerController
//
//  Created by 方焘 on 16/5/29.
//  Copyright © 2016年 taofang. All rights reserved.
//

@import UIKit;

@interface FTGridViewCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *thumbnailView;
@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic, weak) UIButton *selectionButton;
// Selection overlay
@property (nonatomic) BOOL allowsSelection;

@property (nonatomic, copy) void(^itemSelectedBlock)(BOOL isSelected);
@property (nonatomic, copy) BOOL(^shouldSelectItemBlock)();
@end
