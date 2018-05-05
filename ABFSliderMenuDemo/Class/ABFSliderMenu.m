//
//  ABFSliderMenu.m
//  ABFSliderMenuDemo
//
//  Created by 陈立宇 on 2018/5/5.
//  Copyright © 2018年 陈立宇. All rights reserved.
//

#import "ABFSliderMenu.h"

//菜单的显示区域占屏幕宽度的百分比
static CGFloat MenuWidthScale = 0.8f;
//遮罩层最高透明度
static CGFloat MaxCoverAlpha = 0.3;
//快速滑动最小触发速度
static CGFloat MinActionSpeed = 500;

@interface ABFSliderMenu ()<UIGestureRecognizerDelegate>{
    //记录起始位置
    CGPoint _originalPoint;
}
//遮罩view
@property (nonatomic, strong) UIView *coverView;
//拖拽手势
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@end

@implementation ABFSliderMenu

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _coverView = [[UIView alloc] initWithFrame:self.view.bounds];
    _coverView.backgroundColor = [UIColor blackColor];
    _coverView.alpha = 0;
    _coverView.hidden = true;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [_coverView addGestureRecognizer:tap];
    
    [_rootViewController.view addSubview:_coverView];
    
    self.isShow = NO;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateLeftMenuFrame];
}

-(instancetype)initWithRootViewController:(UIViewController*)rootViewController{
    if (self = [super init]) {
        _rootViewController = rootViewController;
        [self addChildViewController:_rootViewController];
        [self.view addSubview:_rootViewController.view];
        [_rootViewController didMoveToParentViewController:self];
    }
    return self;
}

-(void)setLeftViewController:(UIViewController *)leftViewController{
    _leftViewController = leftViewController;
    //提前设置ViewController的viewframe，为了懒加载view造成的frame问题，所以通过setter设置了新的view
    _leftViewController.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self menuWidth], self.view.bounds.size.height)];
    _leftViewController.view.alpha = 0;
    //自定义View需要主动调用viewDidLoad
    [_leftViewController viewDidLoad];
    [self addChildViewController:_leftViewController];
    [self.view insertSubview:_leftViewController.view atIndex:0];
    [_leftViewController didMoveToParentViewController:self];
}

//显示主视图
-(void)showRootViewControllerAnimated:(BOOL)animated{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:[self animationDurationAnimated:animated] animations:^{
        CGRect frame = weakSelf.rootViewController.view.frame;
        frame.origin.x = 0;
        weakSelf.rootViewController.view.frame = frame;
        [self updateLeftMenuFrame];
        weakSelf.coverView.alpha = 0;
    }completion:^(BOOL finished) {
        weakSelf.coverView.hidden = true;
    }];
}

//显示左侧菜单
- (void)showLeftViewControllerAnimated:(BOOL)animated {
    if (!_leftViewController) {return;}
    _coverView.hidden = false;
    [_rootViewController.view bringSubviewToFront:_coverView];
    self.isShow = YES;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:[self animationDurationAnimated:animated] animations:^{
        weakSelf.rootViewController.view.center = CGPointMake(weakSelf.rootViewController.view.bounds.size.width/2 + weakSelf.menuWidth, weakSelf.rootViewController.view.center.y);
        weakSelf.leftViewController.view.frame = CGRectMake(0, 0, [weakSelf menuWidth], self.view.bounds.size.height);
        weakSelf.leftViewController.view.alpha = 1.0;
        weakSelf.coverView.alpha = MaxCoverAlpha;
    }];
}

//更新左侧菜单位置
- (void)updateLeftMenuFrame {
    _leftViewController.view.alpha = 0;
    _leftViewController.view.center = CGPointMake(CGRectGetMinX(_rootViewController.view.frame)/2, _leftViewController.view.center.y);
}

//菜单宽度
- (CGFloat)menuWidth {
    return MenuWidthScale * self.view.bounds.size.width;
}

//空白宽度
- (CGFloat)emptyWidth {
    return self.view.bounds.size.width - self.menuWidth;
}

//动画时长
- (CGFloat)animationDurationAnimated:(BOOL)animated {
    return animated ? 0.25 : 0;
}

//取消自动旋转
- (BOOL)shouldAutorotate {
    return false;
}

-(void)setSlideEnabled:(BOOL)slideEnabled{
    _pan.enabled = slideEnabled;
}

-(BOOL)slideEnabled{
    return _pan.isEnabled;
}

-(void)pan:(UIPanGestureRecognizer*)pan{
    switch (pan.state) {
            //记录起始位置 方便拖拽移动
        case UIGestureRecognizerStateBegan:
            _originalPoint = _rootViewController.view.center;
            break;
        case UIGestureRecognizerStateChanged:
            [self panChanged:pan];
            break;
        case UIGestureRecognizerStateEnded:
            //滑动结束后自动归位
            [self panEnd:pan];
            break;
            
        default:
            break;
    }
}

//拖拽方法
-(void)panChanged:(UIPanGestureRecognizer*)pan{
    //拖拽的距离
    CGPoint translation = [pan translationInView:self.view];
    //移动主控制器
    _rootViewController.view.center = CGPointMake(_originalPoint.x + translation.x, _originalPoint.y);
    
    if (!_leftViewController && CGRectGetMinX(_rootViewController.view.frame) >= 0) {
        _rootViewController.view.frame = self.view.bounds;
    }
    //滑动到边缘位置后不可以继续滑动
    if (CGRectGetMinX(_rootViewController.view.frame) > self.menuWidth) {
        _rootViewController.view.center = CGPointMake(_rootViewController.view.bounds.size.width/2 + self.menuWidth, _rootViewController.view.center.y);
    }
    if (CGRectGetMaxX(_rootViewController.view.frame) < self.emptyWidth) {
        _rootViewController.view.center = CGPointMake(_rootViewController.view.bounds.size.width/2 - self.menuWidth, _rootViewController.view.center.y);
    }
    
    //显示左菜单
    //更新左菜单位置
    [self updateLeftMenuFrame];
    //更新遮罩层的透明度
    _coverView.hidden = false;
    [_rootViewController.view bringSubviewToFront:_coverView];
    _coverView.alpha = CGRectGetMinX(_rootViewController.view.frame)/self.menuWidth * MaxCoverAlpha;
    
}

//拖拽结束
- (void)panEnd:(UIPanGestureRecognizer*)pan {
    
    //处理快速滑动
    CGFloat speedX = [pan velocityInView:pan.view].x;
    if (ABS(speedX) > MinActionSpeed) {
        [self dealWithFastSliding:speedX];
        return;
    }
    //正常速度
    if (CGRectGetMinX(_rootViewController.view.frame) > self.menuWidth/2) {
        [self showLeftViewControllerAnimated:true];
    }else{
        [self showRootViewControllerAnimated:true];
    }
}

//处理快速滑动
- (void)dealWithFastSliding:(CGFloat)speedX {
    //向左滑动
    BOOL swipeRight = speedX > 0;
    //rootViewController的左边缘位置
    CGFloat roootX = CGRectGetMinX(_rootViewController.view.frame);
    if (swipeRight) {//向右滑动
        if (roootX > 0) {//显示左菜单
            [self showLeftViewControllerAnimated:true];
        }else if (roootX < 0){//显示主菜单
            [self showRootViewControllerAnimated:true];
        }
    }
    
    return;
}

- (void)tap {
    [self showRootViewControllerAnimated:true];
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
