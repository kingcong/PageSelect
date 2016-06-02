//
//  ViewController.m
//  分段选择器
//
//  Created by kingcong on 16/6/2.
//  Copyright © 2016年 王聪. All rights reserved.
//

#import "ViewController.h"
#import "CWSegmentRootController.h"

#define RandomColor [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1]


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)jumpToSelectView:(id)sender {
    
    NSArray *titleArray = @[@"第一页",@"第二页222",@"第三页3",@"第四页44444"];
    
    NSMutableArray *controllersArray = [NSMutableArray array];
    for (int i = 0; i < 4; i++) {
        UIViewController *vc1 = [[UIViewController alloc] init];
        vc1.view.backgroundColor = RandomColor;
        [controllersArray addObject:vc1];
    }
    
    CWSegmentRootController *rootVc = [[CWSegmentRootController alloc] initWithTitleArray:titleArray controllersArray:controllersArray];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:rootVc];
    
    [self presentViewController:nav animated:YES completion:nil];

}

@end
