//
//  FTAlbumsViewCell.m
//  FTImagePickerController
//
//  Created by 方焘 on 16/5/29.
//  Copyright © 2016年 taofang. All rights reserved.
//

#import "FTAlbumsViewCell.h"

@implementation FTAlbumsViewCell
- (void)prepareForReuse {
    [super prepareForReuse];
    self.thumbnailView.image = nil;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        // thumbnailView
        _thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAlbumThumbnailSize.width, kAlbumThumbnailSize.height)];
        _thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailView.clipsToBounds = YES;
        [self.contentView addSubview:_thumbnailView];
        
        self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView]-(offset)-[textLabel]-|"
                                                                                 options:0
                                                                                 metrics:@{@"offset": @(5)}
                                                                                   views:@{@"textLabel": self.textLabel,
                                                                                           @"imageView": self.thumbnailView}]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[textLabel]-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{@"textLabel": self.textLabel}]];
    }
    return self;
}

@end
