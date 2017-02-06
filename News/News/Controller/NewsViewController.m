//
//  NewsViewController.m
//  News
//
//  Created by schubertq on 15/10/21.
//  Copyright © 2015年 schubertq. All rights reserved.
//

#import "NewsViewController.h"
#import "HouseViewController.h"
#import "FinanceViewController.h"
#import "TheoryViewController.h"
#import "EducationViewController.h"
#import "PoliticsViewController.h"
#import "TopLineViewController.h"
#import "TitleButton.h"

#define ScreenW  [UIScreen mainScreen].bounds.size.width
#define ScreenH  [UIScreen mainScreen].bounds.size.height

@interface NewsViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIButton *selButton;

@property (nonatomic, strong) NSMutableArray *titleBtns;

// 标题滚动view
@property (weak, nonatomic) IBOutlet UIScrollView *titileScrollView;

// 内容滚动view
@property (weak, nonatomic) IBOutlet UIScrollView *contentView;

@end

@implementation NewsViewController

#pragma mark - 懒加载
- (NSMutableArray *)titleBtns
{
    if (_titleBtns == nil) {
        _titleBtns = [NSMutableArray array];
    }
    return _titleBtns;
}

#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加所有子控制器
    [self setUpChildViewController];
    
    // 设置标题
    [self setUpTitle];
    
    // 清除额外滚动区域
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 初始化scrollView
    [self setUpScrollView];
}

/**
 初始化scrollView
 */
- (void)setUpScrollView
{
    self.titileScrollView.showsHorizontalScrollIndicator = NO;
    self.contentView.contentSize = CGSizeMake(self.childViewControllers.count * ScreenW, 0);
    self.contentView.showsHorizontalScrollIndicator = NO;
    self.contentView.pagingEnabled = YES;
    self.contentView.bounces = NO;
    self.contentView.delegate = self;
}


/**
 添加所有子控制器
 */
- (void)setUpChildViewController
{
    TopLineViewController *topLineVc = [[TopLineViewController alloc] init];
    topLineVc.title = @"头条";
    [self addChildViewController:topLineVc];
    
    PoliticsViewController *politicsVc = [[PoliticsViewController alloc] init];
    politicsVc.title = @"赣政";
    [self addChildViewController:politicsVc];
    
    HouseViewController *houseVc = [[HouseViewController alloc] init];
    houseVc.title = @"赣房";
    [self addChildViewController:houseVc];
    
    EducationViewController *educationVc = [[EducationViewController alloc] init];
    educationVc.title = @"赣教";
    [self addChildViewController:educationVc];
    
    FinanceViewController *financeVc = [[FinanceViewController alloc] init];
    financeVc.title = @"金融";
    [self addChildViewController:financeVc];
    
    TheoryViewController *theoryVc = [[TheoryViewController alloc] init];
    theoryVc.title = @"理论";
    [self addChildViewController:theoryVc];
}

/**
 设置标题
 */
- (void)setUpTitle
{
    NSUInteger count = self.childViewControllers.count;
    
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    CGFloat btnW = 100;
    CGFloat btnH = 44;
    
    for (NSUInteger i = 0; i < count; i++) {
        btnX = i * btnW;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        UIViewController *vc = self.childViewControllers[i];
        [btn setTitle:vc.title  forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        [btn addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.titileScrollView addSubview:btn];
        
        [self.titleBtns addObject:btn];
        // 默认选中第一个
        if (i == 0) {
            [self titleClick:btn];
        }
    }
    
    self.titileScrollView.contentSize = CGSizeMake(btnW * count, 0);
}

/**
 点击标题按钮
 */
- (void)titleClick:(UIButton *)btn
{
    // 设置标题按钮居中
    [self setUpTitleBtnMiddle:btn];
    
    // 滚动到对应的界面
    CGFloat offsetX = btn.tag * ScreenW;
    self.contentView.contentOffset = CGPointMake(offsetX, 0);
    
    // 添加对应子控制器view到对应的位置
    UIViewController *vc = self.childViewControllers[btn.tag];
    vc.view.frame = CGRectMake(offsetX, 0, ScreenW, self.contentView.bounds.size.height);
    [self.contentView addSubview:vc.view];
    
    // 设置选中按钮
    [self setSelectBtn:btn];
}


/**
 设置选中按钮
 */
- (void)setSelectBtn:(UIButton *)btn
{
    _selButton.transform = CGAffineTransformIdentity;
    [_selButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _selButton.selected = NO;
    
    btn.transform = CGAffineTransformMakeScale(1.3, 1.3);
    btn.selected = YES;
    
    _selButton = btn;
}

#pragma mark - UIScrollViewDelegate

/**
 scrollView停止减速
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 获取当前的偏移量
    CGFloat offsetX = scrollView.contentOffset.x;
    // 获取页码
    int page = offsetX / scrollView.bounds.size.width;
    
    UIButton *btn = self.titileScrollView.subviews[page];
    
    // 选中按钮
    [self setSelectBtn:btn];
    
    // 设置按钮居中
    [self setUpTitleBtnMiddle:btn];
    
    // 添加对应子控制器到界面上
    UIViewController *vc = self.childViewControllers[page];
    
    // 已经加载的view，直接返回
    if (vc.isViewLoaded) return;
    
    vc.view.frame = CGRectMake(offsetX , 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
    [self.contentView addSubview:vc.view];
}

/**
 设置标题按钮居中
 */
- (void)setUpTitleBtnMiddle:(UIButton *)btn
{
    // 计算偏移量
    CGFloat offsetX = btn.center.x - ScreenW * 0.5;
    
    // 左边偏移多了，表示需要往左边看，可视范围往左边，偏移量就减少，最少应该是0
    if (offsetX < 0) offsetX = 0;
    CGFloat maxOffsetX = self.titileScrollView.contentSize.width - ScreenW;
    
    // 右边偏移多了，表示需要往右边看，可视范围往又边，偏移量就增加，最大不超过内容范围 - 屏幕宽度
    if (offsetX > maxOffsetX) offsetX = maxOffsetX;

    [self.titileScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

/**
 监听内容view滚动
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    NSLog(@"page %f", page);
    NSInteger leftIndex = page;
    NSLog(@"leftIndex %zd", (long)leftIndex);
    NSInteger rightIndex = leftIndex + 1;
    // 右边缩放比例
    CGFloat rightScale = (page - leftIndex);
//    NSLog(@"rightScale %f", rightScale);
    // 左边缩放比例
    CGFloat leftScale = (1 - rightScale);
//    NSLog(@"leftScale %f", leftScale);
    
    
    NSInteger count = self.titleBtns.count;
    // 获取左边按钮
    TitleButton *leftBtn = self.titleBtns[leftIndex];
    // 获取右边按钮
    TitleButton *rightBtn = nil;
    if (rightIndex < count) {
       rightBtn  = self.titleBtns[rightIndex];
    }
    
    // 设置尺寸
    CGFloat leftTransform = leftScale * 0.3 + 1; // 1 ~ 1.3
    CGFloat rightTransform = rightScale * 0.3 + 1; // 1 ~ 1.3
    leftBtn.transform = CGAffineTransformMakeScale(leftTransform, leftTransform);
    rightBtn.transform = CGAffineTransformMakeScale(rightTransform, rightTransform);
    
    // 设置颜色
    UIColor *leftColor = [UIColor colorWithRed:leftScale green:0 blue:0 alpha:1];
    UIColor *rightColor = [UIColor colorWithRed:rightScale green:0 blue:0 alpha:1];
    [leftBtn setTitleColor:leftColor forState:UIControlStateNormal];
    [rightBtn setTitleColor:rightColor forState:UIControlStateNormal];
}

@end
