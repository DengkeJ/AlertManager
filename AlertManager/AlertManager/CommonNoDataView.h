//
//  CommonNoDataView.h
//  familyUser
//
//  Created by DK on 15/12/17.
//  Copyright © 2015年 JBTM. All rights reserved.
//

/*
 *************************************************
 *  名称：无数据的公共view
 *  描述：无数据的显示
 *************************************************
 */

#import <UIKit/UIKit.h>

typedef void(^ClickBlock)(void); //无网络情况下 点击，再次请求

typedef NS_ENUM(NSInteger, CommonNoDataViewType) {
    CommonNoDataView_NoExpert = 0, //我的专家为空
    CommonNoDataView_NoCollection, //我的收藏为空
    CommonNoDataView_NoNetWork, //无网络状态
};

@interface CommonNoDataView : UIView

@property (nonatomic, assign) CommonNoDataViewType type; //类型

@property (nonatomic, copy) ClickBlock block;//block块 实例化

/**
 *  根据类型创建
 *
 *  @param frame
 *  @param type
 *
 *  @return 
 */
- (instancetype)initWithFrame:(CGRect)frame type:(CommonNoDataViewType)type;



/**
 *  调整顶点坐标
 *
 *  @param originY
 */
- (void)resizeWithOriginY:(CGFloat)originY;

@end
