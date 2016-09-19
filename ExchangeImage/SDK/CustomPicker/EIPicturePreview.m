//
//  EIPicturePreview.m
//  自定义相机
//
//  Created by 张博成 on 16/7/9.
//  Copyright © 2016年 张博成. All rights reserved.
//

#import "EIPicturePreview.h"
#import "EIDefines.h"

@implementation EIPicturePreview

- (void)awakeFromNib
{
    self.picture.contentMode = UIViewContentModeScaleAspectFill;
    
    self.picture.layer.masksToBounds = YES;
    
}

+ (instancetype)createPreview:(UsePhotoBlock)block{
    EIPicturePreview *picturePreview = [[[NSBundle mainBundle]loadNibNamed:@"EIPicturePreview" owner:nil options:nil] firstObject];
    picturePreview.usePhotoBlock = block;
    return picturePreview;
}

- (IBAction)usePhoto:(id)sender {
    
    if (self.originImage) {
        if (self.usePhotoBlock) {
            self.usePhotoBlock(self.originImage);
        }
    }else{
        [self removeSelf];
    }
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    self.frame = self.superview.bounds;
}

- (IBAction)retake:(id)sender {
    [self removeSelf];
}

- (void)removeSelf{
    [self removeFromSuperview];
}

- (void)dealloc{
    self.originImage = nil;
}

- (void)setPhotoWith:(UIImage *)image
{
    if (image) {
        
        self.originImage = image;
        
        if (image.size.width >= image.size.height) {
            self.picture.contentMode = UIViewContentModeScaleAspectFit;
        }else{
            self.picture.contentMode = UIViewContentModeScaleAspectFill;
        }
        
        [self.picture setImage:image];
    }
}

- (void)setPhotoWithAlbum:(UIImage *)image{
    if (image) {
        self.originImage = image;
        self.picture.contentMode = UIViewContentModeScaleAspectFit;
        self.picture.image = image;
        
        NSArray *constrains = self.contentView.constraints;
        for (NSLayoutConstraint *constraint in constrains) {
            if (constraint.firstAttribute == NSLayoutAttributeTop && constraint.firstItem == self.picture) {
                constraint.constant = 0;
            }
            
            if (constraint.firstItem == self.toolBar && constraint.secondItem == self.picture) {
                constraint.constant = 0;
            }
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
