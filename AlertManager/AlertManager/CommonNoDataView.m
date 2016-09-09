//
//  CommonNoDataView.m
//  familyUser
//
//  Created by DK on 15/12/17.
//  Copyright © 2015年 JBTM. All rights reserved.
//

#import "CommonNoDataView.h"
#import "UIView+Extension.h"
#import "MACRO.h"

@interface CommonNoDataView ()

@property (nonatomic, strong) UIImageView *imageView; //内容为空的图片
@property (nonatomic, strong) UILabel *warningLabel; //内容为空的提示语
@property (nonatomic, strong) UILabel *reloadLabel; //无网络的lable

@end

@implementation CommonNoDataView

/** 实例化 */
- (instancetype)initWithFrame:(CGRect)frame type:(CommonNoDataViewType)type{
    
    self = [super initWithFrame:frame];
    if (type == CommonNoDataView_NoExpert) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 48, 45, 45)];
        if (IS_IPHONE_6P) {
            imageView.originY += 24;
        }
        imageView.centerX = self.centerX;
        imageView.image = [UIImage imageNamed:@"Lprompt"];
        [self addSubview:imageView];
        
        UILabel *label = [self labelWithString:@"您当前尚未关注专家"];
        label.originY = imageView.bottomY + 16;
        [self addSubview:label];
    } else if (type == CommonNoDataView_NoCollection) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 48, 45, 45)];
        imageView.centerX = self.centerX;
        imageView.image = [UIImage imageNamed:@"Lcollect"];
        [self addSubview:imageView];
        
        UILabel *label = [self labelWithString:@"暂时没有收藏记录"];
        label.originY = imageView.bottomY + 16;
        [self addSubview:label];
    } else if (type == CommonNoDataView_NoNetWork) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 125, 100, 76)];
        imageView.centerX = self.centerX;
        imageView.image = [UIImage imageNamed:@"wifi"];
        _imageView = imageView;
        [self addSubview:imageView];
        
        UILabel *label = [self labelWithString:@"您的网络好像在开小差" fontSize:15 textColor:RGB(62, 62, 62, 1)];
        label.originY = imageView.bottomY + 39;
        _warningLabel = label;
        [self addSubview:label];
        
        UILabel *subLabel = [self labelWithString:@"请检查网络设置，点击屏幕重新加载" fontSize:13 textColor:RGB(62, 62, 62, 0.7)];
        label.textColor = RGB(62, 62, 62, 0.7);
        subLabel.originY = label.bottomY + 15;
        _reloadLabel = subLabel;
        [self addSubview:subLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(requestAgain)];
        [self addGestureRecognizer:tap];
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}
/** 调整顶点坐标 */
- (void)resizeWithOriginY:(CGFloat)originY {
    _imageView.originY = 125 + originY;
    _warningLabel.originY = _imageView.bottomY + 39;
    _reloadLabel.originY = _warningLabel.bottomY + 15;
}

/** 再次请求 */
- (void)requestAgain {
    if (_block) {
        _block();
    }
}

/** 创建label */
- (UILabel *)labelWithString:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KDeviceWidth, 20)];
    label.textColor = RGB(62, 62, 62, 0.5);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14.f];
    label.text = text;
    
    return label;
}

/** 创建label */
- (UILabel *)labelWithString:(NSString *)text textColor:(UIColor *)color {
    return [self labelWithString:text fontSize:0 textColor:nil];
}

/** 创建label */
- (UILabel *)labelWithString:(NSString *)text fontSize:(CGFloat)fontSize {
    return [self labelWithString:text fontSize:fontSize textColor:nil];
}

/** 创建label */
- (UILabel *)labelWithString:(NSString *)text fontSize:(CGFloat)fontSize textColor:(UIColor *)color {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KDeviceWidth, 20)];
    if (!color) {
        color = RGB(62, 62, 62, 0.5);
    }
    label.textColor = color;
    label.textAlignment = NSTextAlignmentCenter;
    if (!fontSize) {
        fontSize = 14.0f;
    }
    label.font = [UIFont systemFontOfSize:fontSize];
    label.text = text;
    
    return label;
}

@end
