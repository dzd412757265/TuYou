//
//  EISubRichTextView.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/7.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EISubRichTextView.h"
#import "EIDefines.h"
#import "UIView+Extension.h"

static const CGFloat kPadding = 4.f;

@interface EISubRichTextView()

@property (nonatomic , strong)UIImageView *iconView;
@property (nonatomic , strong)UILabel *textLabel;

@end

@implementation EISubRichTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithImage:(UIImage *)icon
               text:(NSString *)text
             rect:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.icon = icon;
        self.textStr = text;
        [self setupUI];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    _iconView = [[UIImageView alloc] initWithImage:self.icon];
    [self addSubview:_iconView];
    
    _textLabel = [[UILabel alloc] init];
    _textLabel.font = EIFont(10);
    _textLabel.textColor = RGBCOLOR(155, 158, 166);
    _textLabel.text = self.textStr;
    [self addSubview:_textLabel];
    
    [self reFrame];
}

- (void)reFrame{
    CGFloat offsetX = 0;
    
    if (self.textLabel.text.length > 0) {
        self.hidden = NO;
        if (self.iconView.image) {
            [self.iconView setSize:self.iconView.image.size];
            [self.iconView setCenterY:self.height/2];
            offsetX += self.iconView.width;
            offsetX += kPadding;
        }
        
        [self.textLabel sizeToFit];
        self.textLabel.x = offsetX;
        self.textLabel.centerY = self.height/2;
        offsetX += self.textLabel.width;
    }else{
        self.hidden = YES;
        self.width = 0;
    }
    self.width = offsetX;
}

- (void)setFont:(UIFont *)textFont{
    self.textLabel.font = textFont;
    //[self setNeedsLayout];
    [self reFrame];
}

- (void)setImage:(UIImage *)icon text:(NSString *)text{
    self.icon = icon;
    self.textStr = text;
}

//- (void)layoutSubviews{
//    [super layoutSubviews];
//}

- (void)setIcon:(UIImage *)icon{
    _icon = icon;
    self.iconView.image = _icon;
    
    //[self setNeedsLayout];
    [self reFrame];
}

- (void)setTextStr:(NSString *)textStr{
    _textStr = textStr;
    self.textLabel.text = textStr;
    
    //[self setNeedsLayout];
    [self reFrame];
}

@end
