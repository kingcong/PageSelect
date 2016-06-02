//
//  CWSegmentRootController.m
//  分段选择器
//
//  Created by kingcong on 16/6/2.
//  Copyright © 2016年 王聪. All rights reserved.
//

#import "CWSegmentRootController.h"

@interface CWSegmentRootController () <UIScrollViewDelegate>

/** 标签栏底部的红色指示器 */
@property (nonatomic, weak) UIView *indicatorView;

/** 当前选中的按钮 */
@property (nonatomic, weak) UIButton *selectedButton;

@property (nonatomic, weak) UIView *titlesView;

/** 底部的所有内容 */
@property (nonatomic, weak) UIScrollView *contentView;

/* 控制器数组和标题数组 */
@property (nonatomic, strong) NSArray *titlesArray;

@property (nonatomic, strong) NSArray *controllersArray;

@end

@implementation CWSegmentRootController

- (id)initWithTitleArray:(NSArray *)titleArray controllersArray:(NSArray *)controllersArray
{
    if (self = [super init]) {
        self.titlesArray = titleArray;
        self.controllersArray = controllersArray;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"分期记录";
    
    [self setupNav];
    
    // 初始化子控制器
    [self setupChildVces];
    
    [self setupTitlesView];
    
    [self setupContentView];
    
}

/**
 * 初始化子控制器
 */
- (void)setupChildVces
{
    for (UIViewController *vc in self.controllersArray) {
        [self addChildViewController:vc];
    }
}

/**
 * 设置顶部的标签栏
 */
- (void)setupTitlesView
{
    // 标签栏整体
    UIView *titlesView = [[UIView alloc] init];
    titlesView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    titlesView.frame = CGRectMake(0, 64, self.view.frame.size.width, 35);
    [self.view addSubview:titlesView];
    self.titlesView = titlesView;
    
    // 底部的红色指示器
    UIView *indicatorView = [[UIView alloc] init];
    indicatorView.backgroundColor = [UIColor redColor];
    indicatorView.tag = -1;
  
    CGFloat indicatorViewW = self.view.frame.size.width/(self.titlesArray.count);
    CGFloat indicatorViewH = 2;
    CGFloat indicatorViewY = titlesView.frame.size.height - indicatorViewH;
    
    indicatorView.frame = CGRectMake(0, indicatorViewY, indicatorViewW, indicatorViewH);
    
    self.indicatorView = indicatorView;
    
    // 内部的子标签
    CGFloat width = titlesView.frame.size.width / self.titlesArray.count;
    CGFloat height = titlesView.frame.size.height;
    for (NSInteger i = 0; i<self.titlesArray.count; i++) {
        UIButton *button = [[UIButton alloc] init];
        button.tag = i;
        button.frame = CGRectMake(i*width, 0, width, height);
        [button setTitle:self.titlesArray[i] forState:UIControlStateNormal];
        //        [button layoutIfNeeded]; // 强制布局(强制更新子控件的frame)
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
        [titlesView addSubview:button];
        
        // 默认点击了第一个按钮
        if (i == 0) {
            button.enabled = NO;
            self.selectedButton = button;
            
            // 让按钮内部的label根据文字内容来计算尺寸
            [button.titleLabel sizeToFit];
            
            CGRect newFrame = indicatorView.frame;
            newFrame.size.width = button.titleLabel.frame.size.width;
            self.indicatorView.frame = newFrame;
            CGPoint newCenter = self.indicatorView.center;
            newCenter.x = button.center.x;
            self.indicatorView.center = newCenter;
        }
    }
    
    [titlesView addSubview:indicatorView];

}

- (void)titleClick:(UIButton *)button
{
    // 修改按钮状态
    self.selectedButton.enabled = YES;
    button.enabled = NO;
    self.selectedButton = button;
    
    // 动画
    [UIView animateWithDuration:0.25 animations:^{
        CGRect newFrame = self.indicatorView.frame;
        newFrame.size.width = button.titleLabel.frame.size.width;
        self.indicatorView.frame = newFrame;
        CGPoint newCenter = self.indicatorView.center;
        newCenter.x = button.center.x;
        self.indicatorView.center = newCenter;
    }];
    
    // 滚动
    CGPoint offset = self.contentView.contentOffset;
    offset.x = button.tag * self.contentView.frame.size.width;
    [self.contentView setContentOffset:offset animated:YES];
}

/**
 * 底部的scrollView
 */
- (void)setupContentView
{
    // 不要自动调整inset
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIScrollView *contentView = [[UIScrollView alloc] init];
    contentView.backgroundColor = [UIColor lightGrayColor];
    //    contentView.frame = self.view.bounds;
    contentView.frame = CGRectMake(0, CGRectGetMaxY(self.titlesView.frame), self.view.frame.size.width, self.view.frame.size.height-CGRectGetMaxY(self.titlesView.frame));
    
    contentView.delegate = self;
    contentView.pagingEnabled = YES;
    [self.view insertSubview:contentView atIndex:0];
    contentView.contentSize = CGSizeMake(contentView.frame.size.width * self.childViewControllers.count, 0);
    self.contentView = contentView;
    
    // 添加第一个控制器的view
    [self scrollViewDidEndScrollingAnimation:contentView];
}

/**
 * 设置导航栏
 */
- (void)setupNav
{
    
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // 当前的索引
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    // 取出子控制器
    UIViewController *vc = self.childViewControllers[index];
    
    vc.view.frame = CGRectMake(scrollView.contentOffset.x, 0, scrollView.frame.size.width, scrollView.frame.size.height);
    
    [scrollView addSubview:vc.view];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:scrollView];
    
    // 点击按钮
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
    [self titleClick:self.titlesView.subviews[index]];
}


@end
