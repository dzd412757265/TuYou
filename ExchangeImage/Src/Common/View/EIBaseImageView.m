//
//  EIBaseImageView.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/7.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIBaseImageView.h"
#import "EIDefines.h"
#import "UIView+Extension.h"
#import <objc/runtime.h>

#define kMaxImgWidth (kScreen_Width*0.5)

/**
    最长的边为KmaxImgWidth
**/
@interface EIBaseImageView()


@end

@implementation EIBaseImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = [UIColor whiteColor];
    [self.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.layer setShadowOffset:CGSizeMake(0, 0)];
    [self.layer setShadowRadius:2.0f];
    [self.layer setShadowOpacity:.24f];
    
    self.userInteractionEnabled = YES;
    
    _contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kPhotoFramePadding, kPhotoFramePadding, kMaxImgWidth, kMaxImgWidth)];
    [self addSubview:_contentImageView];
}

- (void)setContentImage:(UIImage *)image{
    _contentImageView.image = image;
    [self reFrame];
}

- (void)reFrame{
    CGSize desSize = [[self class] calulateImageSize:_contentImageView.image];
    
    [_contentImageView setWidth:desSize.width];
    [_contentImageView setHeight:desSize.height];
    
    [self setContentSize:desSize];
}

- (void)setContentSize:(CGSize)size{
    [self setWidth:size.width + kPhotoFramePadding * 2];
    [self setHeight:size.height + kPhotoFramePadding * 2];
    
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

+ (CGSize)calulateImageSize:(UIImage *)image{
    CGFloat desWidth = 0;
    CGFloat desHeight = 0;
    CGSize scrSize = image.size;
    
    if (scrSize.width > scrSize.height) {
        desWidth = kMaxImgWidth;
        desHeight = scrSize.height/scrSize.width * desWidth;
    }else{
        desHeight = kMaxImgWidth;
        desWidth = scrSize.width/scrSize.height * desHeight;
    }
    return CGSizeMake(desWidth, desHeight);
}

+ (CGSize)calculateViewSize:(UIImage *)image{
    
    CGSize imageSize = [[self class] calulateImageSize:image];
    return [[self class] calculateTotalSize:imageSize];
}

+ (CGSize)calculateTotalSize:(CGSize )size{
    return CGSizeMake(size.width + kPhotoFramePadding * 2, size.height + kPhotoFramePadding * 2);
}

- (BOOL)canBecomeFirstResponder{
    if (self.longpressBlock) {
        return YES;
    }else{
        return [super canBecomeFirstResponder];
    }
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (self.longpressBlock) {
        for (int i=0; i<self.longPressTitles.count; i++) {
            if (action == NSSelectorFromString([NSString stringWithFormat:@"easeLongPressMenuClicked_%d:", i])) {
                return YES;
            }
        }
        return NO;
    }else{
        return [super canPerformAction:action withSender:sender];
    }
}

- (void)addLongPressMenu:(NSArray *)titles clickBlock:(void(^)(NSInteger index, NSString *title))block{
    self.longpressBlock = block;
    self.longPressTitles = titles;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:longPress];
}

- (void)addClickAction:(void (^)())block
{
    self.singleClickBlock = block;
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    tap.numberOfTapsRequired =1;
    tap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tap];
}

- (void)tapAction:(UIGestureRecognizer *)recognizer
{
    if (self.singleClickBlock) {
        self.singleClickBlock();
    }
}

-(void)handleLongPress:(UIGestureRecognizer*)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        NSMutableArray *menuItems = [[NSMutableArray alloc] initWithCapacity:self.longPressTitles.count];
        Class cls = [self class];
        SEL imp = @selector(longPressMenuClicked:);
        for (int i=0; i<self.longPressTitles.count; i++) {
            NSString *title = [self.longPressTitles objectAtIndex:i];
            //            注册名添加方法sel，sel的具体实现在imp(longPressMenuClicked:)
            SEL sel = sel_registerName([[NSString stringWithFormat:@"easeLongPressMenuClicked_%d:", i] UTF8String]);
            class_addMethod(cls, sel, [cls instanceMethodForSelector:imp], "v@");
            UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:title action:sel];
            [menuItems addObject:menuItem];
        }
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:menuItems];
        [menu setTargetRect:self.frame inView:self.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}
- (void)longPressMenuClicked:(id)sender {
    NSString *selStr = NSStringFromSelector(_cmd);
    NSString *preFix = @"easeLongPressMenuClicked_";
    NSString *indexStr = [selStr substringFromIndex:preFix.length];
    NSInteger index = indexStr.integerValue;
    if (index >=0 && index<self.longPressTitles.count) {
        NSString *title = [self.longPressTitles objectAtIndex:index];
        if (self.longpressBlock) {
            self.longpressBlock(index, title);
        }
    }
}

@end
