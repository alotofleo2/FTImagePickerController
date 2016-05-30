//
//  FTGridViewCell.m
//  FTImagePickerController
//
//  Created by 方焘 on 16/5/29.
//  Copyright © 2016年 taofang. All rights reserved.
//

#import "FTGridViewCell.h"

@interface FTGridViewCell ()

//@property (nonatomic, weak) UIView *selectedCoverView;


@property (nonatomic, getter=isBtnSelected) BOOL btnSelected;

@end

@implementation FTGridViewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.thumbnailView.image = nil;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        CGFloat cellSize = self.contentView.bounds.size.width;
        
        _btnSelected = NO;
        
        _thumbnailView = [UIImageView new];
        _thumbnailView.frame = CGRectMake(0, 0, cellSize, cellSize);
        _thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailView.clipsToBounds = YES;
        _thumbnailView.translatesAutoresizingMaskIntoConstraints = NO;
        _thumbnailView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_thumbnailView];
        
    }
    return self;
}

- (void)setAllowsSelection:(BOOL)allowsSelection {
    if (_allowsSelection != allowsSelection) {
        _allowsSelection = allowsSelection;

        if (_allowsSelection) {
            
            UIButton *selectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            selectionButton.frame = CGRectMake(2*self.bounds.size.width/3, 0*self.bounds.size.width/3, self.bounds.size.width/3, self.bounds.size.width/3);
            selectionButton.contentMode = UIViewContentModeTopRight;
            selectionButton.adjustsImageWhenHighlighted = NO;
            [selectionButton setImage:nil forState:UIControlStateNormal];
            selectionButton.translatesAutoresizingMaskIntoConstraints = NO;
            selectionButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            [selectionButton setImage:[UIImage imageNamed:[@"FTImagePickerController.bundle" stringByAppendingPathComponent:@"tickw.png"]] forState:UIControlStateNormal];
            [selectionButton setImage:[UIImage imageNamed:[@"FTImagePickerController.bundle" stringByAppendingPathComponent:@"tickH.png"]] forState:UIControlStateSelected];
            selectionButton.hidden = NO;
            [self.contentView addSubview:selectionButton];
            [selectionButton addTarget:self action:@selector(didClickSelectionButton) forControlEvents:UIControlEventTouchUpInside];
            _selectionButton = selectionButton;
            
        } else {
            
            
            [_selectionButton removeFromSuperview];
        }
    }
}

- (void)didClickSelectionButton {
    NSAssert(self.shouldSelectItemBlock, @"shouldSelectItemBlock cannot be nil");
    if (self.shouldSelectItemBlock() || _selectionButton.isSelected) {
        self.selectionButton.selected = !self.selectionButton.isSelected;
        if (self.itemSelectedBlock) {
            self.itemSelectedBlock(self.selectionButton.isSelected);
        }
    } 

}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
//    if (self.allowsSelection) {
//        _selectedCoverView.hidden = !selected;
//        _selectionButton.selected = selected;
//    }
}

@end
