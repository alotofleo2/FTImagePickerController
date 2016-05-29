//
//  FTAlbumsViewCell.h
//  FTImagePickerController
//
//  Created by 方焘 on 16/5/29.
//  Copyright © 2016年 taofang. All rights reserved.
//

@import UIKit;

static CGSize const kAlbumThumbnailSize = {57.0, 57.0};

@interface FTAlbumsViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *thumbnailView;
@property (nonatomic, copy) NSString *representedAlbumIdentifier;

@end
