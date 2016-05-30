//
//  ViewController.m
//  FTImagePickerController
//
//  Created by 方焘 on 16/5/29.
//  Copyright © 2016年 taofang. All rights reserved.
//

#import "ViewController.h"
#import "FTImagePickerController.h"

@interface ViewController () <FTImagePickerControllerDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 100, 200, 200)];
    [self.view addSubview:self.imageView];
}
- (IBAction)didClickStart:(id)sender {
    FTImagePickerController *picker = [[FTImagePickerController alloc] init];
    picker.delegate = self;
    
    picker.sourceType = FTImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    picker.allowsMultipleSelection = YES;
    picker.maxMultipleCount = 10;
    
    picker.allowsEditing = YES;
    //返回图片大小
    picker.cropSize = CGSizeMake(750, 750);
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - FTImagePickerControllerDelegate

- (void)assetsPickerController:(FTImagePickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"当前选择图片集合 -> %@", assets);
}

- (void)assetsPickerController:(FTImagePickerController *)picker didFinishPickingImage:(UIImage *)image {
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"当前编辑图片 -> %@", image);
    self.imageView.image = image;
}

- (void)assetsPickerControllerDidCancel:(FTImagePickerController *)picker {
    NSLog(@"结束选择图片");
}

- (void)assetsPickerVontrollerDidOverrunMaxMultipleCount:(FTImagePickerController *)picker {
    NSLog(@"超过最大可选数量 -> %zd", picker.maxMultipleCount);
}

@end
