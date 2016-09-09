//
//  ViewController.m
//  AlertManager
//
//  Created by DK on 16/9/8.
//  Copyright © 2016年 DK. All rights reserved.
//

#import "ViewController.h"
#import "AlertManager.h"

@interface ViewController ()<AlertManagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /** 显示加载动画，如果当前没有网络，直接显示无网络页面，点击无网络页面，走delegate回调 */
    [AlertManager showLoadingView:YES inView:self.view];
    [AlertManager shareInstance].delegate = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [AlertManager showLoadingView:NO inView:self.view];
    });
}
- (IBAction)showHUD:(UIButton *)sender {
    [AlertManager showHudInView:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeHUD];
    });
}

- (IBAction)showHUDWithText:(UIButton *)sender {
    [AlertManager showHudWithText:@"这是个提示框" inView:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeHUD];
    });
}

- (IBAction)showDialogtype1:(UIButton *)sender {
    [AlertManager showDialog:@"这是一条dialog" inView:self.view type:AlertPressentTypeDefault];
}

- (IBAction)showDialogType2:(UIButton *)sender {
    [AlertManager showDialog:@"这是一条dialog" inView:self.view type:AlertPressentTypeValue1];
}

- (IBAction)showDialogType3:(UIButton *)sender {
    [AlertManager showDialog:@"这是一条dialog" inView:self.view type:AlertPressentTypeValue2];
}

- (IBAction)showDialogType4:(UIButton *)sender {
    [AlertManager showDialog:@"这是一条dialog" inView:self.view type:AlertPressentTypeActivity];
}

- (IBAction)showAlert:(UIButton *)sender {
    [AlertManager showAlertTitle:@"标题" message:@"alert的message" fromController:self tapAction:^(DKAlert *alert, NSInteger index) {
        NSLog(@"点击的按钮%zd", index);
    }];
}

- (IBAction)showAlertWithCustomButton:(UIButton *)sender {
    [AlertManager showAlertTitle:@"标题" message:@"alert的message" cancelTitle:@"自定义1" sureTitle:@"自定义2" fromController:self tapAction:^(DKAlert *alert, NSInteger index) {
        NSLog(@"点击的按钮%zd", index);
    }];
}

- (IBAction)showNoNetWorking:(UIButton *)sender {
    [AlertManager showNoNetWorkDialog];
}

- (IBAction)showLoading:(UIButton *)sender {
    [AlertManager showLoadingView:YES inView:self.view]; 
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [AlertManager showLoadingView:NO inView:self.view];
    });
}

- (void)removeHUD {
    [AlertManager removeHUDFromSuperView];
}

/**
 *  无网络视图点击回调方法
 *
 *  @param manager manager本身
 */
- (void)reloadDataWithManager:(AlertManager *)manager {
    NSLog(@"我要开始回调啦");
    /** 模拟网络请求的延时 */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [AlertManager showLoadingView:NO inView:self.view];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
