//
//  DKAlert.h
//  Alert
//
//  Created by DK on 16/5/10.
//  Copyright © 2016年 JBTM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DKAlert;

/**
 *  AlertView点击回调block
 *
 *  @param alert
 *  @param index
 */
typedef void(^ButtonClickAction)(DKAlert *alert, NSInteger index);

/** 自定义AlertView */
@interface DKAlert : UIView

/** AlertView的点击回调 */
@property (nonatomic, copy) ButtonClickAction tapAction;

/**
 *  初始化方法
 *
 *  @param title        标题
 *  @param msg          提示内容
 *  @param buttonTitles 按钮名称数组
 *
 *  @return
 */
- (instancetype)initWithTitle:(NSString *)title
                          msg:(NSString *)msg
                 bottonTitles:(NSArray *)buttonTitles;

- (void)setTapAction:(ButtonClickAction)tapAction;

/**
 *  显示
 */
- (void)show;

@end
