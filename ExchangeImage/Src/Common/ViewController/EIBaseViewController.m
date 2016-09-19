//
//  BaseViewController.m
//  wenda
//
//  Created by 古元庆 on 16/6/20.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIBaseViewController.h"
#import "EIDefines.h"
#import "UIImage+Color.h"
#import "UINavigationController+JZExtension.h"
#import "UMMobClick/MobClick.h"

@interface EIBaseViewController ()

@end

@implementation EIBaseViewController

- (id)init{
    self = [super init];
    if (self) {
        self.viewControllerStyle = ViewControllerStylePlain;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kCommonBackgroundColor;
    // Do any additional setup after loading the view.
    
    //隐藏导航栏的分割线
//    UIImageView *navigationImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
//    navigationImageView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.joinAnalytic) {
        [MobClick beginLogPageView:NSStringFromClass([self class])];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.joinAnalytic) {
        [MobClick endLogPageView:NSStringFromClass([self class])];
    }
    
}

-(void)setViewControllerStyle:(ViewControllerStyle)viewControllerStyle
{
    _viewControllerStyle = viewControllerStyle;
    
    if(self.viewControllerStyle == ViewControllerStyleNone){
        self.navigationItem.hidesBackButton = YES;
    }else if(self.viewControllerStyle == ViewControllerStylePresenting){
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(backBarButtonAction:)];
        [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
    }else{
//        NSString *buf = @"返回";
//        if ([UINavigationBar instancesRespondToSelector:@selector(setBackIndicatorImage:)]) {
//            UIImage *image = [UIImage imageNamed:@"common_back2_btn"];
//            [[UINavigationBar appearance] setBackIndicatorImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//            [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:image];
//            
//            UIBarButtonItem *btn = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
            
            //[buttonItem setBackButtonTitlePositionAdjustment:offset forBarMetrics:UIBarMetricsDefault];
//        [btn setBackgroundVerticalPositionAdjustment:-500.f forBarMetrics:UIBarMetricsDefault];
//
//            buf = @"";
//        }
        
//        UIImage *image = [UIImage imageNamed:@"ArrowLeft"];
//        [[UINavigationBar appearance] setBackIndicatorImage:[image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, 0, 20)]];
//        [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:image];
        
//        UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ArrowLeft"]
//                                                                       style:UIBarButtonItemStylePlain
//                                                                      target:self
//                                                                      action:@selector(popViewController:)];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
        [button addTarget:self action:@selector(backBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"ArrowLeft"] forState:UIControlStateNormal];
        
        UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -15;
        
        self.navigationItem.leftBarButtonItems = @[negativeSpacer,barBtnItem];
    }
}

- (void)backBarButtonAction:(id)sender{
    if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dismissSelf
{
    [self backBarButtonAction:nil];
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
