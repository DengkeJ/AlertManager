//
//  AlertManager.h
//  familyUser
//
//  Created by DK on 16/4/15.
//  Copyright © 2016年 JBTM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlertManager, DKAlert;

@protocol AlertManagerDelegate <NSObject>

/** 显示为无网络或者加载失败时的点击回调 */
- (void)reloadDataWithManager:(AlertManager *)manager;

@end

/** 提示框样式枚举类型 */
typedef NS_ENUM(NSInteger ,AlertPressentType) {
    AlertPressentTypeDefault = 0,   //默认样式
    AlertPressentTypeValue1  = 1,   //value1样式
    AlertPressentTypeValue2  = 2,   //value2样式
    AlertPressentTypeActivity= 3    //转菊花样式
};

/** AlertButton点击类型 */
typedef NS_ENUM(NSInteger ,AlertActionStyle) {
    AlertActionStyleCancel = 0, //点击取消
    AlertActionStyleSure = 1    //点击确定
};

/** 提示框点击回调 */
typedef void(^AlertTapAction)(DKAlert *alert, NSInteger index);

/** 重新加载点击回调 */
typedef void(^RefreshTapAction)();

/** 所有弹框，提示，加载管理类 */
@interface AlertManager : UIView

@property (nonatomic, weak) id<AlertManagerDelegate> delegate; //代理

/**
 *  singleTon
 *
 *  @return
 */
+ (instancetype)shareInstance;

/**
 *  显示HUD
 *
 *  @param view
 */
+ (void)showHudInView:(UIView *)view;

/**
 *  显示带文字的HUD
 *
 *  @param text
 *  @param view
 */
+ (void)showHudWithText:(NSString *)text inView:(UIView *)view;

/**
 *  移除HUD
 */
+ (void)removeHUDFromSuperView;

/**
 *  提示网络异常
 */
+ (void)showNoNetWorkDialog;

/**
 *  显示提示框
 *
 *  @param dialog 提示内容
 *  @param view   目标视图
 */
+ (void)showDialog:(NSString *)dialog inView:(UIView *)view;

/**
 *  显示提示框
 *
 *  @param dialog 提示内容
 *  @param view   目标视图
 *  @param type   提示框样式
 */
+ (void)showDialog:(NSString *)dialog
            inView:(UIView *)view
              type:(AlertPressentType)type;

/**
 *  显示提示框
 *
 *  @param dialog 提示内容
 *  @param view   目标视图
 *  @param origin 顶点位置
 *  @param type   提示框样式
 */
+ (void)showDialog:(NSString *)dialog
            inView:(UIView *)view
           originY:(CGFloat)originY
              type:(AlertPressentType)type;

+ (void)addRefreshAction:(RefreshTapAction)action;

/**
 *  显示正在加载页
 *
 *  @param isShow
 *  @param view
 */
+ (void)showLoadingView:(BOOL)isShow inView:(UIView *)view;

/**
 *  显示正在加载页
 *
 *  @param isShow
 *  @param view
 *  @param originY 顶点的Y值
 */
+ (void)showLoadingView:(BOOL)isShow inView:(UIView *)view originY:(CGFloat)originY;

/**
 *  显示系统AlertView
 *
 *  @param title
 *  @param msg
 *  @param controller
 */
+ (void)showAlertTitle:(NSString *)title
               message:(NSString *)msg
        fromController:(UIViewController *)controller;

/**
 *  显示系统AlertView
 *
 *  @param title
 *  @param msg
 *  @param buttonTitles
 *  @param controller   
 */
+ (void)showAlertTitle:(NSString *)title
               message:(NSString *)msg
          cancelButton:(NSString *)button
        fromController:(UIViewController *)controller;

/**
 *  显示系统AlertView
 *
 *  @param title
 *  @param msg
 *  @param controller
 *  @param action 确定按钮点击回调
 */
+ (void)showAlertTitle:(NSString *)title
               message:(NSString *)msg
        fromController:(UIViewController *)controller
             tapAction:(AlertTapAction)block;

/**
 *  显示系统AlertView
 *
 *  @param title       标题
 *  @param msg         内容
 *  @param cancelTitle 取消按钮标题
 *  @param sureTitle   确定按钮标题
 *  @param controller
 *  @param action      确定按钮点击回调
 */
+ (void)showAlertTitle:(NSString *)title
               message:(NSString *)msg
           cancelTitle:(NSString *)cancelTitle
             sureTitle:(NSString *)sureTitle
        fromController:(UIViewController *)controller
             tapAction:(AlertTapAction)block;

@end

