//
//  HBDrawingVC.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/8/5.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "HBDrawingVC.h"
#import "HBDrawingBoard.h"
#import "HBDrawingColorPicker.h"
#import "UIColor+help.h"
#import "SensorsAnalyticsSDK.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width

@interface HBDrawingVC ()

@property (nonatomic , strong)UIImageView *backgroundImgView;
@property (nonatomic , strong)HBDrawingBoard *drawingBoard;

@end

@implementation HBDrawingVC

- (id)initWithBackgroundImg:(UIImage *)image{
    self = [super init];
    if (self) {
        self.backgroundImg = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.backgroundImgView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_backgroundImgView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_backgroundImgView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[_backgroundImgView]-49-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_backgroundImgView)]];
    
    [self.backgroundImgView addSubview:self.drawingBoard];
    
    [self.backgroundImgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_drawingBoard]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_drawingBoard)]];
    [self.backgroundImgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_drawingBoard]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_drawingBoard)]];
    
    [self addToolBar];
    
    [self addColorPicker];
    
    [[SensorsAnalyticsSDK sharedInstance] track:@"SendDrawingPicture"];
}

- (UIImageView *)backgroundImgView{
    if (!_backgroundImgView) {
        _backgroundImgView = [[UIImageView alloc] init];
        _backgroundImgView.translatesAutoresizingMaskIntoConstraints = NO;
        _backgroundImgView.contentMode = UIViewContentModeScaleAspectFit;
        _backgroundImgView.image = self.backgroundImg ? self.backgroundImg : [[UIImage alloc] init];
        _backgroundImgView.userInteractionEnabled = YES;
        _backgroundImgView.backgroundColor = [UIColor clearColor];
    }
    return _backgroundImgView;
}

- (HBDrawingBoard *)drawingBoard{
    if (!_drawingBoard) {
        _drawingBoard = [[HBDrawingBoard alloc] init];
        _drawingBoard.translatesAutoresizingMaskIntoConstraints = NO;
        _drawingBoard.ise = NO;
        _drawingBoard.lineColor = [UIColor colorWithHexString:[[self getColors] objectAtIndex:0]];
        _drawingBoard.shapType = HBDrawingShapeCurve;
        _drawingBoard.lineWidth = 8.f;
    }
    return _drawingBoard;
}

- (void)addToolBar{
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:toolBar];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[toolBar]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(toolBar)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolBar(49)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(toolBar)]];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIButton *undoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 49, 49)];
    [undoBtn addTarget:self action:@selector(undoAction:) forControlEvents:UIControlEventTouchUpInside];
    [undoBtn setImage:[UIImage imageNamed:@"drawing_undo"] forState:UIControlStateNormal];
    
    UIBarButtonItem *undoBarItem = [[UIBarButtonItem alloc] initWithCustomView:undoBtn];
    
    UIButton *checkBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 49, 49)];
    [checkBtn addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
    [checkBtn setImage:[UIImage imageNamed:@"drawing_check"] forState:UIControlStateNormal];
    
    UIBarButtonItem *checkBarItem = [[UIBarButtonItem alloc] initWithCustomView:checkBtn];
    
    UIButton *trashBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 49, 49)];
    [trashBtn addTarget:self action:@selector(trashAction:) forControlEvents:UIControlEventTouchUpInside];
    [trashBtn setImage:[UIImage imageNamed:@"drawing_trash"] forState:UIControlStateNormal];
    
    UIBarButtonItem *trashBarItem = [[UIBarButtonItem alloc] initWithCustomView:trashBtn];
    
    [toolBar setItems:@[undoBarItem,flexibleItem,checkBarItem,flexibleItem,trashBarItem]];
}

- (void)addColorPicker{
    __weak typeof(self) weakSelf = self;
    HBDrawingColorPicker *colorPicker = [[HBDrawingColorPicker alloc] initWithFrame:CGRectMake(40, 0, ScreenWidth - 40 - 10, 44) colors:[self getColors]];
    [colorPicker chooseMenuAtIndex:0];
    colorPicker.clickColorMenu = ^(UIColor *color){
        weakSelf.drawingBoard.lineColor = color;
    };
    [self.navigationController.navigationBar addSubview:colorPicker];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}

- (NSArray *)getColors
{
    return [NSArray arrayWithObjects:@"#ed4040",
            @"#f5973c",
            @"#efe82e",
            @"#7ce331",
            @"#48dcde",
            @"#2877e3",
            @"#9b33e4",
            nil];
}

- (void)undoAction:(id)sender{
    [self.drawingBoard backToLastDraw];
}

- (void)checkAction:(id)sender{
    if (self.drawFinishBlock) {
        self.drawFinishBlock([self.drawingBoard drawFinish]);
    }
    [self dismissSelf];
}

- (void)trashAction:(id)sender{
    [self.drawingBoard clearAll];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
