//
//  FTBadgeView.h
//  FTImagePickerController
//
//  Created by 方焘 on 16/5/29.
//  Copyright © 2016年 taofang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FTBadgeViewAlignment) {
    FTBadgeViewAlignmentLeft = 0,
    FTBadgeViewAlignmentCenter,
    FTBadgeViewAlignmentRight
};

typedef NS_ENUM(NSInteger, FTBadgeViewType) {
    FTBadgeViewTypeDefault = 0,
    FTBadgeViewTypeWhiteBorder
};

@interface FTBadgeView : UIView

/**
 *  A rectangle defining the frame of the SCBadgeView object. The size components of this rectangle are ignored.
 */
- (instancetype)initWithFrame:(CGRect)frame alignment:(FTBadgeViewAlignment)alignment type:(FTBadgeViewType)type NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

#if TARGET_INTERFACE_BUILDER
@property (nonatomic, assign) IBInspectable NSInteger alignment;
@property (nonatomic, assign) IBInspectable NSInteger type;
#else
@property (nonatomic, assign, readonly) FTBadgeViewAlignment alignment;
@property (nonatomic, assign, readonly) FTBadgeViewType type;
#endif

@property (nonatomic, assign) IBInspectable NSInteger number;
@property (nonatomic, strong) IBInspectable UIColor *backgroundColor;
@property (nonatomic, strong) IBInspectable UIColor *textColor;

@end
