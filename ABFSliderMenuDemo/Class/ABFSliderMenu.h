//
//  ABFSliderMenu.h
//  ABFSliderMenuDemo
//
//  Created by 陈立宇 on 2018/5/5.
//  Copyright © 2018年 陈立宇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ABFSliderMenu : UIViewController

//主视图
@property (nonatomic, strong) UIViewController *rootViewController;
//左侧视图
@property (nonatomic, strong) UIViewController *leftViewController;
//菜单宽度
@property (nonatomic, assign, readonly) CGFloat menuWidth;
//留白宽度
@property (nonatomic, assign, readonly) CGFloat emptyWidth;
//是否允许滚动
@property (nonatomic ,assign) BOOL slideEnabled;

@property (nonatomic ,assign) BOOL isShow;
//创建方法
-(instancetype)initWithRootViewController:(UIViewController*)rootViewController;
//显示主视图
-(void)showRootViewControllerAnimated:(BOOL)animated;
//显示左侧菜单
-(void)showLeftViewControllerAnimated:(BOOL)animated;

@end
