//
//  AlertManager.m
//  familyUser
//
//  Created by DK on 16/4/15.
//  Copyright © 2016年 JBTM. All rights reserved.
//

#import "AlertManager.h"
#import <objc/runtime.h>
#import "MACRO.h"
#import "UIView+Extension.h"
#import "MBProgressHUD.h"
//#import "UITool.h"
#import "CommonNoDataView.h"
#import "DKAlert.h"
#import "Reachability.h"

@interface AlertManager ()

@property (nonatomic, strong) UILabel                 *label; //提示label
@property (nonatomic, strong) UIImageView             *cicle; //loading的动画图片
@property (nonatomic, strong) UILabel                 *warningLabel; //警告label
@property (nonatomic, strong) UIView                  *contentView; //背景视图
@property (nonatomic, strong) CABasicAnimation        *animation; //缩放的动画效果
@property (nonatomic, strong) UIView                  *loadingView; //loading的动画
@property (nonatomic, strong) UIImageView             *logo; //logo图片视图
@property (nonatomic, strong) MBProgressHUD           *hud; //HUD提示
@property (nonatomic, strong) CommonNoDataView        *noNetView; //无网络视图
@property (nonatomic, assign) CGFloat                 originY; //顶点的Y坐标
@property (nonatomic, strong) UIView                  *currentView; //当前的视图
@property (nonatomic, strong) UIActivityIndicatorView *activity; //菊花

@end

@implementation AlertManager

static const char alertKey;

/**
 *  singleTon
 *
 *  @return
 */
+ (instancetype)shareInstance {
    static AlertManager *manager = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        manager = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    return manager;
}

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupContentView];
        self.label = [self setupLabelWithBgColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] textColor:[UIColor whiteColor]];
        [self setupLoadingView];
        [self.contentView addSubview:self.label];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleEnterForeground:)
                                                     name: UIApplicationWillEnterForegroundNotification
                                                   object: nil];
    }
    return self;
}

/**
 *  创建提示Label
 *
 *  @param bgColor
 *  @param textColor
 *
 *  @return
 */
- (UILabel *)setupLabelWithBgColor:(UIColor *)bgColor textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, KDeviceWidth-100, 80)];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 3;
    label.textColor = textColor;
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.masksToBounds = YES;
    return label;
}

/**
 *  创建提示label背景View
 */
- (void)setupContentView {
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDeviceWidth-80, 80)];
    if (IS_IPHONE_6P) {
        self.contentView.width -= 80;
    }
    self.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.contentView.layer.cornerRadius = 5;
    self.contentView.center = self.center;
    /** 菊花 */
    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activity.originX = 20;
    self.activity.centerY = self.contentView.height/2;
    self.activity.hidden = YES;
    [self.contentView addSubview:self.activity];
    [self addSubview:self.contentView];
}

- (UIView *)contentView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setContentView:(UIView *)contentView {
    objc_setAssociatedObject(self, @selector(contentView), contentView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/**
 *  创建加载页
 */
- (void)setupLoadingView {
    UIView *loadingView = [[UIView alloc] initWithFrame:self.frame];
    loadingView.backgroundColor = RGB(245, 245, 245, 1);
    UIImageView *cicle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle"]];
    cicle.frame = CGRectMake(0, 0, 80, 80);
    cicle.centerX = self.centerX;
    cicle.centerY = self.centerY-NAVBARTOP-40;
    _cicle = cicle;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.toValue = [NSNumber numberWithFloat:M_PI*2];
    animation.duration = 1.0f;
    animation.repeatCount = CGFLOAT_MAX;
    animation.cumulative = YES;
    _animation = animation;
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"requestlogo"]];
    logo.frame = _cicle.frame;
    _logo = logo;
    
    UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    warningLabel.text = @"点击屏幕重试";
    warningLabel.textColor = RGB(62, 62, 62, 0.7);
    warningLabel.font = [UIFont systemFontOfSize:15];
    [warningLabel sizeToFit];
    warningLabel.centerX = _cicle.centerX;
    warningLabel.originY = _cicle.bottomY + 15;
    _warningLabel = warningLabel;
    warningLabel.hidden = YES;
    
    [loadingView addSubview:cicle];
    [loadingView addSubview:logo];
    [loadingView addSubview:warningLabel];
    loadingView.hidden = YES;
    _loadingView = loadingView;
    [_loadingView addGestureTapRecognizerWithTarget:self action:@selector(tapRefresh:)];
}

- (void)showLoadingView:(BOOL)isShow inView:(UIView *)view {
    WEAKSELF;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (![self boolNetwork]) {
        if (isShow) {
            [AlertManager shareInstance].hidden = YES;
            [[AlertManager shareInstance] removeFromSuperview];
            _noNetView = [[CommonNoDataView alloc] initWithFrame:CGRectMake(0, 0, view.width, view.height) type:CommonNoDataView_NoNetWork];
            if (_currentView == view) {
                [_noNetView resizeWithOriginY:_originY];
            } else {
                _originY = 0;
            }
            NSLog(@"%@+++", NSStringFromCGRect(view.frame));
            NSLog(@"%@---", NSStringFromCGRect(_noNetView.frame));
            [view insertSubview:_noNetView atIndex:view.subviews.count];
            _noNetView.block = ^ {
                [weakSelf.noNetView removeFromSuperview];
                [weakSelf showLoadingView:YES inView:view];
                /** 如果有代理,优先执行代理,否则执行回调block */
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(reloadDataWithManager:)]) {
                    [weakSelf.delegate reloadDataWithManager:weakSelf];
                } else {
                    RefreshTapAction action = objc_getAssociatedObject(weakSelf, @selector(addRefreshAction:));
                    if (action) {
                        action();
                    }
                }
            };
        }
    } else {
        [AlertManager shareInstance].hidden = NO;
        [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subView, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([subView isKindOfClass:[CommonNoDataView class]]) {
                [subView removeFromSuperview];
            }
        }];
        _loadingView.hidden = !isShow;
        if (isShow) {
            [view insertSubview:_loadingView atIndex:view.subviews.count];
            [self startAnimating];
            [self performSelector:@selector(stopAnimating) withObject:nil afterDelay:60];
        } else {
            [_loadingView removeFromSuperview];
            [self stopAnimating];
        }
    }
}

- (void)showLoadingView:(BOOL)isShow withOrginY:(CGFloat)orginY inView:(UIView *)view {
    orginY != 0 ? _cicle.originY = (KDeviceHeight/2-70):_cicle.originY;
    _logo.centerY  = _cicle.centerY;
    _originY = orginY;
    _warningLabel.originY = _cicle.bottomY + 15;
    _currentView = view;
    [self showLoadingView:isShow inView:view];
}

- (void)layoutSubviews {
    _logo.center = _cicle.center;
}

#pragma mark - notification

/** 后台进入前台 */
- (void)handleEnterForeground:(NSNotification*)notification {
    [self startAnimating];
}

#pragma mark - HUD 

+ (void)showHudInView:(UIView *)view {
    [self showHudWithText:nil inView:view];
}

+ (void)showHudWithText:(NSString *)text inView:(UIView *)view {
    AlertManager *manager = [AlertManager shareInstance];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.margin = 10.f;
    hud.yOffset = -NAVBARTOP;
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = text;
    manager.hud = hud;
}

+ (void)removeHUDFromSuperView {
    AlertManager *manager = [AlertManager shareInstance];
    [manager.hud removeFromSuperview];
}

#pragma mark - 文字提示

+ (void)showNoNetWorkDialog {
    [self showDialog:@"您的网络好像在开小差~" inView:[UIApplication sharedApplication].keyWindow originY:NAVBARTOP type:AlertPressentTypeDefault];
}

+ (void)showDialog:(NSString *)dialog inView:(UIView *)view {
    [self showDialog:dialog inView:view type:AlertPressentTypeDefault];
}

+ (void)showDialog:(NSString *)dialog inView:(UIView *)view type:(AlertPressentType)type {
    [self showDialog:dialog inView:view originY:0 type:type];
}

+ (void)showDialog:(NSString *)dialog inView:(UIView *)view originY:(CGFloat)originY type:(AlertPressentType)type {
    NSAssert(view != nil, @"目标view不能为空！");
    [self removeHUDFromSuperView];
    [AlertManager shareInstance].hidden = NO;
    AlertManager *manager = [AlertManager shareInstance];
    manager.label.hidden = NO;
    manager.contentView.hidden = NO;
    manager.contentView.centerY = manager.centerY-NAVBARTOP + originY/2;
    manager.label.width = manager.contentView.width-20;
    manager.label.centerX = manager.contentView.width / 2;
    manager.label.text = dialog;
    manager.activity.hidden = YES;
    [manager.activity stopAnimating];
    [manager layoutIfNeeded];
    [NSObject cancelPreviousPerformRequestsWithTarget:manager];
    if (type == AlertPressentTypeValue1) { //样式1
        manager.backgroundColor = [UIColor clearColor];
        manager.label.textColor = [UIColor whiteColor];
        manager.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    } else if (type == AlertPressentTypeValue2) { //样式2
        manager.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        manager.label.textColor = [UIColor blackColor];
        manager.contentView.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.9];
    } else if (type == AlertPressentTypeActivity) { //转菊花样式
        manager.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        manager.label.textColor = [UIColor whiteColor];
        manager.label.originX = 50;
        manager.label.width -= 40;
        manager.activity.originX = 80;
        manager.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
        manager.activity.hidden = NO;
        [manager.activity startAnimating];
    } else if(type == AlertPressentTypeDefault){ //默认样式
        manager.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        manager.label.textColor = [UIColor whiteColor];
        manager.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        NSLog(@"%@", NSStringFromCGRect(manager.label.frame));
    }
    [view addSubview:manager];
    /** 动画效果 */
//    manager.label.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
    manager.contentView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
    [UIView animateWithDuration:0.25 animations:^{
//        manager.label.layer.transform = CATransform3DMakeScale(1.0f, 1.0f, 1.0);
        manager.contentView.layer.transform = CATransform3DMakeScale(1.0f, 1.0f, 1.0);
    }];
    [view endEditing:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [manager performSelector:@selector(hide:) withObject:nil afterDelay:3];
    });
}

#pragma mark - loadingView

+ (void)showLoadingView:(BOOL)isShow inView:(UIView *)view {
    [self removeHUDFromSuperView];
    AlertManager *manager = [AlertManager shareInstance];
    manager.cicle.centerX = manager.centerX;
    manager.cicle.centerY = manager.centerY-NAVBARTOP-40;
    manager.logo.center = manager.cicle.center;
    [self showLoadingView:isShow inView:view originY:0];
}

+ (void)showLoadingView:(BOOL)isShow inView:(UIView *)view originY:(CGFloat)originY {
    [self removeHUDFromSuperView];
    AlertManager *manager = [AlertManager shareInstance];
    [manager showLoadingView:isShow withOrginY:originY inView:view];
}

#pragma mark - AlertView 样式

+ (void)showAlertTitle:(NSString *)title message:(NSString *)msg fromController:(UIViewController *)controller {
    [self showAlertTitle:title message:msg fromController:controller tapAction:nil];
}

+ (void)showAlertTitle:(NSString *)title message:(NSString *)msg cancelButton:(NSString *)button fromController:(UIViewController *)controller {
    [self showAlertTitle:title message:msg cancelTitle:button sureTitle:nil fromController:controller tapAction:nil];
}

+ (void)showAlertTitle:(NSString *)title message:(NSString *)msg fromController:(UIViewController *)controller tapAction:(AlertTapAction)block {
    [self showAlertTitle:title message:msg cancelTitle:@"取消" sureTitle:@"确定" fromController:controller tapAction:block];
}

+ (void)showAlertTitle:(NSString *)title
               message:(NSString *)msg
           cancelTitle:(NSString *)cancelTitle
             sureTitle:(NSString *)sureTitle
        fromController:(UIViewController *)controller
             tapAction:(AlertTapAction)block {
    [self removeHUDFromSuperView];
    
/*****************************************************************************************/
/************************************* 调用自定义的Alert ***********************************/
/*****************************************************************************************/
    
    NSMutableArray *array = [NSMutableArray array];
    cancelTitle != nil ? [array addObject:cancelTitle] : array;
    sureTitle != nil ? [array addObject:sureTitle] : array;
    dispatch_async(dispatch_get_main_queue(), ^{
        DKAlert *alert = [[DKAlert alloc] initWithTitle:title msg:msg bottonTitles:array];
        [alert setTapAction:^(DKAlert *alert, NSInteger index) {
            if (block) {
                block(alert, index);
            }
        }];
        [alert show];
    });
    
/*****************************************************************************************/
/************************************* 调用系统的Alert *************************************/
/*****************************************************************************************/
    
//    NSAssert(controller != nil, @"fromController不能为空！");
//    if (IOS8) { /** IOS8或者之后使用UIAlertController */
//        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title
//                                                                         message:msg
//                                                                  preferredStyle:UIAlertControllerStyleAlert];
//        if (cancelTitle) {
//            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                if (block) {
//                    block(AlertActionStyleCancel);
//                }
//            }];
//            [alertVC addAction:cancelAction];
//        }
//
//        if (sureTitle) { /** 确定按钮点击 */
//            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                /** 如果有推出的控制器,先Dismiss */
//                if (controller.presentedViewController) {
//                    [controller.presentedViewController dismissViewControllerAnimated:YES completion:nil];
//                }
//                if (block) {
//                    block(AlertActionStyleSure);
//                }
//            }];
//            [alertVC addAction:sureAction];
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            /** 如果没有推出过别的控制器 */
//            if (!controller.presentedViewController) {
//                [controller presentViewController:alertVC animated:YES completion:nil];
//            } else if ([controller.presentedViewController isKindOfClass:[UIAlertController class]]) { /** 如果推出过AlertController */
//                [controller.presentedViewController dismissViewControllerAnimated:YES completion:^{
//                    [controller presentViewController:alertVC animated:YES completion:nil];
//                }];
//            } else { /** 如果推出的是其他的控制器 */
//                if ([controller.presentedViewController.presentedViewController isKindOfClass:[UIAlertController class]]) {
//                    [controller.presentedViewController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
//                }
//                [controller.presentedViewController presentViewController:alertVC animated:YES completion:nil];
//            }
//        });
//    } else { /** IOS8 之前使用UIAlertView */
//        AlertManager *manager = [AlertManager shareInstance];
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
//                                                            message:msg
//                                                           delegate:manager
//                                                  cancelButtonTitle:cancelTitle
//                                                  otherButtonTitles:sureTitle, nil];
//        objc_setAssociatedObject(self, &alertKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
//        [alertView show];
//    }

}

#pragma mark - 设置无数据页面回调block

+ (void)addRefreshAction:(RefreshTapAction)action {
    objc_setAssociatedObject([AlertManager shareInstance], @selector(addRefreshAction:), action, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - toucheBegan

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self removeFromParentView];
}

- (void)hide:(id)sender {
    [self removeFromParentView];
}

/**
 *  从父视图移除
 */
- (void)removeFromParentView {
    CATransform3D transform1 = [AlertManager shareInstance].contentView.layer.transform;
    CATransform3D transform2 = [AlertManager shareInstance].label.layer.transform;
    [UIView animateWithDuration:0.25 animations:^{
        [AlertManager shareInstance].contentView.layer.transform = CATransform3DConcat(transform1, CATransform3DMakeScale(0.01f, 0.01f, 1.0));
        [AlertManager shareInstance].label.layer.transform = CATransform3DConcat(transform2, CATransform3DMakeScale(0.01f, 0.01f, 1.0));
    } completion:^(BOOL finished) {
        [AlertManager shareInstance].contentView.layer.transform = CATransform3DMakeScale(1.0f, 1.0f, 1.0);
        [AlertManager shareInstance].label.layer.transform = CATransform3DMakeScale(1.0f, 1.0f, 1.0);
        [[AlertManager shareInstance] removeFromSuperview];
    }];
}

/**
 *  开始动画
 */
- (void)startAnimating {
    
    self.label.hidden = YES;
    self.contentView.hidden = YES;
    
    _warningLabel.hidden = YES;
    _loadingView.gestureRecognizers.lastObject.enabled = NO;
    [_cicle.layer addAnimation:_animation forKey:@"rotation"];
}

/**
 *  结束动画
 */
- (void)stopAnimating {
    _warningLabel.hidden = NO;
    _loadingView.gestureRecognizers.lastObject.enabled = YES;
    [_cicle.layer removeAnimationForKey:@"rotation"];
}

- (void)tapRefresh:(UITapGestureRecognizer *)gesture {
    [self showLoadingView:YES inView:_currentView];
    /** 如果有代理,优先执行代理,否则执行回调block */
    if (_delegate && [_delegate respondsToSelector:@selector(reloadDataWithManager:)]) {
        [_delegate reloadDataWithManager:self];
    } else {
        RefreshTapAction action = objc_getAssociatedObject(self, @selector(addRefreshAction:));
        if (action) {
            action();
        }
    }
}

/** 判断网络 */
- (BOOL)boolNetwork {
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    BOOL yesOrNo=NO;
    switch ([reachability currentReachabilityStatus]) {
        case NotReachable: {
            yesOrNo=NO;
        }
            break;
        case ReachableViaWWAN: {
            yesOrNo= YES;
        }
            break;
        case ReachableViaWiFi: {
            yesOrNo= YES;
        }
            
            break;
    }
    return yesOrNo;
}

#pragma mark - UIAlertViewDelegate

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    AlertTapAction action = objc_getAssociatedObject([self class], &alertKey);
//    if (action && buttonIndex == 1) {
//        action(AlertActionStyleSure);
//    } else {
//        action(AlertActionStyleCancel);
//    }
//}

@end
