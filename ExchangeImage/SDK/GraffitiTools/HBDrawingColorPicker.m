//
//  HBDrawingColorPicker.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/8/5.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "HBDrawingColorPicker.h"
#import "UIColor+help.h"

@interface HBDrawingColorMenu()

@property (nonatomic , strong)UIView *contentColor;
@property (nonatomic , strong)UIView *borderColor;

@end

@implementation HBDrawingColorMenu

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    self.backgroundColor = [UIColor clearColor];
    _borderColor = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
    _borderColor.backgroundColor = [UIColor clearColor];
    [_borderColor.layer setCornerRadius:9.f];
    [_borderColor.layer setBorderWidth:2.f];
    [_borderColor.layer setBorderColor:[UIColor clearColor].CGColor];
    _borderColor.userInteractionEnabled = NO;
    [self addSubview:_borderColor];
    
    _borderColor.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    _contentColor = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [_contentColor.layer setCornerRadius:5];
    _contentColor.userInteractionEnabled = NO;
    [self addSubview:_contentColor];
    
    _contentColor.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

- (void)setColorProperty:(UIColor *)colorProperty{
    _colorProperty = colorProperty;
    self.contentColor.backgroundColor = colorProperty;
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    
    if (selected) {
        [self.borderColor.layer setBorderColor:self.colorProperty.CGColor];
    }else{
        [self.borderColor.layer setBorderColor:[UIColor clearColor].CGColor];
    }
}

@end

@interface HBDrawingColorPicker()

@property (nonatomic , strong)NSArray *colors;

@property (nonatomic , strong)HBDrawingColorMenu *currentMenu;
@property (nonatomic , strong)NSMutableArray *menus;

@end

@implementation HBDrawingColorPicker

- (id)initWithFrame:(CGRect)frame colors:(NSArray *)colors{
    self = [super initWithFrame:frame];
    if (self) {
        self.colors = colors;
        self.menus = [[NSMutableArray alloc] init];
        self.showsHorizontalScrollIndicator = NO;
        [self setUp];
    }
    return self;
}

- (void)setUp{
    CGFloat btnWidth = CGRectGetHeight(self.bounds) * 1.5;
    CGFloat btnHeight = CGRectGetHeight(self.bounds);
    __block CGFloat contentWidth = 0;
    [self.colors enumerateObjectsUsingBlock:^(NSString * color, NSUInteger idx, BOOL * _Nonnull stop) {
        HBDrawingColorMenu *menu = [[HBDrawingColorMenu alloc] initWithFrame:CGRectMake(idx * btnWidth, 0, btnWidth, btnHeight)];
        [menu addTarget:self action:@selector(menuChooseAction:) forControlEvents:UIControlEventTouchDown];
        menu.colorProperty = [UIColor colorWithHexString:color];
        contentWidth += btnWidth;
        [self addSubview:menu];
        [self.menus addObject:menu];
    }];
    
    [self setContentSize:CGSizeMake(contentWidth, btnHeight)];
}

- (void)menuChooseAction:(HBDrawingColorMenu *)menu{
    if (_currentMenu == menu) {
        return;
    }
    
    if (_currentMenu) {
        _currentMenu.selected = NO;
    }
    
    _currentMenu = menu;
    _currentMenu.selected = YES;
    if (self.clickColorMenu) {
        self.clickColorMenu(_currentMenu.colorProperty);
    }
}

- (void)chooseMenuAtIndex:(NSInteger)index{
    if (index < self.menus.count) {
        [self menuChooseAction:self.menus[index]];
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
