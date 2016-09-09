//
//  UIView+Extension.h
//  familyUser
//
//  Created by DK on 15/11/30.
//  Copyright © 2015年 JBTM. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 *********************************************************************************
 *
 * 名称：UIView分类
 * 描述：提供访问UIView的frame的上、下、左、右、宽、高快捷方式
 *
 *********************************************************************************
 */

@interface UIView (Extension)

/**
 * @brief Shortcut for frame.origin.x.
 *        Sets frame.origin.x = originX
 */
@property (nonatomic, assign) CGFloat originX;

/**
 * @brief Shortcut for frame.origin.y
 *        Sets frame.origin.y = originY
 */
@property (nonatomic, assign) CGFloat originY;

/**
 * @brief Shortcut for frame.origin.x + frame.size.width
 *       Sets frame.origin.x = rightX - frame.size.width
 */
@property (nonatomic, assign) CGFloat rightX;

/**
 * @brief Shortcut for frame.origin.y + frame.size.height
 *        Sets frame.origin.y = bottomY - frame.size.height
 */
@property (nonatomic, assign) CGFloat bottomY;

/**
 * @brief Shortcut for frame.size.width
 *        Sets frame.size.width = width
 */
@property (nonatomic, assign) CGFloat width;

/**
 * @brief Shortcut for frame.size.height
 *        Sets frame.size.height = height
 */
@property (nonatomic, assign) CGFloat height;

/**
 * @brief Shortcut for center.x
 * Sets center.x = centerX
 */
@property (nonatomic, assign) CGFloat centerX;

/**
 * @brief Shortcut for center.y
 *        Sets center.y = centerY
 */
@property (nonatomic, assign) CGFloat centerY;

/**
 * @brief Shortcut for frame.origin
 */
@property (nonatomic, assign) CGPoint origin;

/**
 * @brief Shortcut for frame.size
 */
@property (nonatomic, assign) CGSize size;


/** Helps clean up code for changing UIView frames.
 
 Instead of creating a CGRect struct, changing properties and reassigning. For example, moving a UIView newX points to the left:
 
 CGRect frame = view.frame;
 frame.origin x = (CGFloat)newX + view.frame.size.width;
 view.frame = frame;
 
 This can be cleaned up to:
 
 view.left += newX;
 
 Properties bottom and right also take into account the width of the UIView.
 */

///---------------------------------------------------------------------------------------
/// @name Edges
///---------------------------------------------------------------------------------------

/** Get the left point of a view. */
@property (nonatomic) CGFloat left;

/** Get the top point of a view. */
@property (nonatomic) CGFloat top;

/** Get the right point of a view. */
@property (nonatomic) CGFloat right;

/** Get the bottom point of a view. */
@property (nonatomic) CGFloat bottom;


///< 移除此view上的所有子视图
- (void)removeAllSubviews;

-(void)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius;

-(void)addGestureTapRecognizerWithTarget:(id)target action:(SEL)action;

- (UIView *)firstResponderView;

@end
