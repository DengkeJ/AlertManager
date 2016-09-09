//
//  DKAlert.m
//  Alert
//
//  Created by DK on 16/5/10.
//  Copyright © 2016年 JBTM. All rights reserved.
//

#import "DKAlert.h"
#import "UIView+Extension.h"
#import <objc/runtime.h>

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

static const CGFloat AlertViewCornerRadius = 10; //alertView的圆角
static const CGFloat AlertViewButtonHeight = 45; //alertViewButton的高度

@interface DKAlert ()

@property (nonatomic, strong) UIView         *alertView; //自定义AlertView
@property (nonatomic, strong) UILabel        *titleLabel; //AlertView的标题
@property (nonatomic, strong) UILabel        *msgLabel; //AlertView的内容
@property (nonatomic, strong) NSArray        *buttonTitles; //AlertView的按钮标题
@property (nonatomic, strong) NSMutableArray *buttons; //AlertView的按钮
@property (nonatomic, assign) NSInteger      numberOfButtonRows; //按钮的行数

@end

@implementation DKAlert

- (NSMutableArray *)buttons {
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

- (void)setButtonTitles:(NSArray *)buttonTitles {
    _buttonTitles = buttonTitles;
    [self setupButtonsInView:self.alertView];
}

#pragma mark - init

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        [self setupAlertView];
        [self setupTitleLabel];
        [self setupMsgLabel];
        [self applyMotionEffects];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title msg:(NSString *)msg bottonTitles:(NSArray *)buttonTitles {
    NSAssert(buttonTitles != nil || buttonTitles.count != 0, @"DKAlert的点击按钮不能为空！");
    self = [self init];
    [self calculateHeightWithTitle:title msg:msg buttonTitles:buttonTitles];
    self.buttonTitles = buttonTitles;
    return self;
}

/**
 *  根据标题和内容计算AlertView的高度
 *
 *  @param title
 *  @param msg
 */
- (void)calculateHeightWithTitle:(NSString *)title msg:(NSString *)msg buttonTitles:(NSArray *)buttonTitles {
    self.titleLabel.text = title;
    self.msgLabel.text = msg;
    /** label的文本显示超过1行 */
    if ([self fetchNumberOfLine:self.msgLabel] > 1 && msg) {
        [self.msgLabel sizeToFit];
    }
    
    if (buttonTitles.count <= 2) {
        self.numberOfButtonRows = 1;
    } else {
        self.numberOfButtonRows = buttonTitles.count;
    }
    
    if (title == nil || [title isEqualToString:@""]) {
        self.titleLabel.hidden = YES;
        self.titleLabel.height = 0;
        self.msgLabel.originY = 20;
    } else if (msg == nil || [msg isEqualToString:@""]) {
        self.msgLabel.hidden = YES;
        self.msgLabel.height = 0;
    }
    
    self.alertView.height = self.msgLabel.bottomY+(AlertViewButtonHeight*self.numberOfButtonRows)+20;
    self.alertView.center = self.center;
}

#pragma mark - setupSubViews

/**
 *  创建AlertView
 */
- (void)setupAlertView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 150)];
    view.backgroundColor = [UIColor whiteColor];
    view.center = self.center; 
    view.layer.cornerRadius = AlertViewCornerRadius;
    view.layer.masksToBounds = YES;
    self.alertView = view;
    [self addSubview:self.alertView];
}

/**
 *  创建TitleLabel
 */
- (void)setupTitleLabel {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.alertView.width-20, 20)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.alertView addSubview:self.titleLabel];
}

/**
 *  创建内容Label
 */
- (void)setupMsgLabel {
    self.msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.titleLabel.originY+30, self.alertView.width-20, 20)];
    self.msgLabel.font = [UIFont systemFontOfSize:13];
    self.msgLabel.textAlignment = NSTextAlignmentCenter;
    self.msgLabel.numberOfLines = 0;
    [self.alertView addSubview:self.msgLabel];
}

/**
 *  创建点击按钮
 *
 *  @param view
 */
- (void)setupButtonsInView:(UIView *)view {
    CGFloat buttonWidth = 0;
    if (self.buttonTitles.count == 2) {
        buttonWidth = view.width / 2;
        /** 垂直分割线 */
        UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(buttonWidth, self.alertView.height-AlertViewButtonHeight, 0.5, AlertViewButtonHeight)];
        verticalLine.backgroundColor = [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f];
        [view addSubview:verticalLine];
    } else {
        buttonWidth = view.width;
    }
    
    [self.buttonTitles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
        NSAssert([title isKindOfClass:[NSString class]], @"按钮标题必须是NSString类型");
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        if (buttonWidth == view.width && self.buttonTitles.count > 2) {
            button.frame = CGRectMake(0, self.alertView.height-(self.buttonTitles.count-self.buttons.count)*AlertViewButtonHeight, buttonWidth, AlertViewButtonHeight);
        } else {
            button.frame = CGRectMake(buttonWidth*idx, self.alertView.height-AlertViewButtonHeight, buttonWidth-0.5, AlertViewButtonHeight);
        }
        
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.5f] forState:UIControlStateHighlighted];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [button.layer setCornerRadius:5];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        /** 水平分割线 */
        UIView *separateLine = [[UIView alloc] initWithFrame:CGRectMake(button.originX, button.originY,self.alertView.width, 0.5)];
        separateLine.backgroundColor = [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f];
        [view addSubview:separateLine];
        [self.buttons addObject:button];
        [view addSubview:button];
    }];
}

/**
 *  支持根据屏幕偏移的偏移
 */
- (void)applyMotionEffects { 
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) {
        return;
    }
    UIInterpolatingMotionEffect *horizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                                                    type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalEffect.minimumRelativeValue = @(-10);
    horizontalEffect.maximumRelativeValue = @( 10);
    UIInterpolatingMotionEffect *verticalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                                                  type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalEffect.minimumRelativeValue = @(-10);
    verticalEffect.maximumRelativeValue = @( 10);
    UIMotionEffectGroup *motionEffectGroup = [[UIMotionEffectGroup alloc] init];
    motionEffectGroup.motionEffects = @[horizontalEffect, verticalEffect];
    [self.alertView addMotionEffect:motionEffectGroup];
}

/**
 *  获取label文本的行数
 *
 *  @param label
 *
 *  @return
 */
- (NSInteger)fetchNumberOfLine:(UILabel *)label {
    return [label sizeThatFits:CGSizeMake(label.width, CGFLOAT_MAX)].height / label.font.lineHeight;;
}

#pragma mark - tapAction

- (void)setTapAction:(ButtonClickAction)tapAction {
    objc_setAssociatedObject(self, @selector(tapAction), tapAction, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (ButtonClickAction)tapAction {
    return objc_getAssociatedObject(self, _cmd);
}

/**
 *  Alert直接显示在window上
 */
- (void)show {
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    /** 保证同一时间屏幕上只有一个Alert在显示 */
    [[UIApplication sharedApplication].keyWindow.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subView, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([subView isKindOfClass:[DKAlert class]]) {
            [subView removeAllSubviews];
            [subView removeFromSuperview];
        } else {
            
        }
    }];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.layer.opacity = 0.5;
    self.alertView.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1.0);
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alertView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
        self.layer.opacity = 1;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    } completion:nil];
}

/**
 *  Alert直接从window上移除
 */
- (void)close {
    CATransform3D currentTransform = self.alertView.layer.transform;
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
        self.alertView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.5f, 0.5f, 1.0));
        self.alertView.layer.opacity = 0.0f;
    } completion:^(BOOL finished) {
        for (UIView *view in [self subviews]) {
            [view removeFromSuperview];
        }
        [self removeFromSuperview];
    }];
}

#pragma mark - 按钮点击回调

- (void)buttonClick:(UIButton *)sender {
    ButtonClickAction tapAction = objc_getAssociatedObject(self, @selector(tapAction));
    if (tapAction) {
        tapAction(self, [self.buttons indexOfObject:sender]);
    }
    [self close];
}

@end
