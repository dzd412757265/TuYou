//
//  EIPicturePreview.h
//  自定义相机
//
//  Created by 张博成 on 16/7/9.
//  Copyright © 2016年 张博成. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol EIPicturePreviewDelegate <NSObject>

//@optional
//
//- (void)retakePhoto;
//
//- (void)usePhoto:(UIImage *)photo;
//
//@end
typedef void(^UsePhotoBlock)(UIImage *);

@interface EIPicturePreview : UIView

@property (weak, nonatomic) IBOutlet UIImageView *picture;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *userPhoto;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *retake;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@property (nonatomic,strong)UIImage *originImage;

//@property (nonatomic,weak)id<EIPicturePreviewDelegate>delegate;

@property (nonatomic , copy)UsePhotoBlock usePhotoBlock;

+ (instancetype)createPreview:(UsePhotoBlock) block;

- (void)setPhotoWith:(UIImage *)image;

- (void)setPhotoWithAlbum:(UIImage *)image;

@end
