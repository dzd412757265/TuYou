//
//  BaseNavigationController.m
//  wenda
//
//  Created by 古元庆 on 16/6/20.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIBaseNavigationController.h"
#import "EIDefines.h"
#import "UINavigationController+JZExtension.h"
#import "UIImage+Color.h"

@interface EIBaseNavigationController ()

@end

@implementation EIBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = EINavigationBarTitleColor;
    textAttrs[NSFontAttributeName] = EIFont(18);
    [self.navigationBar setBarTintColor:kCommonBackgroundColor];
    textAttrs[NSShadowAttributeName] = [[NSShadow alloc] init];
    
    [self.navigationBar setTitleTextAttributes:textAttrs];
    
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"bar_background_img"] forBarMetrics:0];
    [self.navigationBar setShadowImage:[UIImage new]];
    
    self.navigationBar.tintColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//+ (void)initialize
//{
//    [self setupNavigationBarTheme];
//}
//+ (void)setupNavigationBarTheme {
//    
//    UINavigationBar *appearance = [UINavigationBar appearance];
//    
//    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
//    textAttrs[NSForegroundColorAttributeName] = [UIColor blackColor];
//    textAttrs[NSFontAttributeName] = EIFont(18);
//    [appearance setBarTintColor:kCommonBackgroundColor];
//    textAttrs[NSShadowAttributeName] = [[NSShadow alloc] init];
//    
//    [appearance setTitleTextAttributes:textAttrs];
//    appearance.tintColor = [UIColor blackColor];
//}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // 判断是否为栈底控制器
    if (self.viewControllers.count >0) {
        viewController.hidesBottomBarWhenPushed = YES;
        //设置导航子控制器按钮的加载样式
    }
    
    [super pushViewController:viewController animated:YES];
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
