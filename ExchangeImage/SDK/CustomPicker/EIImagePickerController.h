//
//  EIImagePickerController.h
//  自定义相机
//
//  Created by 张博成 on 16/7/8.
//  Copyright © 2016年 张博成. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^DidFinishDissmissWithImageBlock)(UIImage *);
typedef void(^OpenAlbumBlock)(UIViewController *);

@interface EIImagePickerController : UIViewController

@property (nonatomic , copy) DidFinishDissmissWithImageBlock didmissBlock ;
@property (nonatomic , copy) OpenAlbumBlock openAlbumBlock;

+ (instancetype)createImagePickerController:(DidFinishDissmissWithImageBlock)dismissBlock openAlbum:(OpenAlbumBlock) openAlbumBlock;

+ (void)openAlbum:(UIViewController *)presentingVC didFinishPhotoBlock:(void(^)(UIImage *))block;

@end
