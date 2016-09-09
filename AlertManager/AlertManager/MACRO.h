//
//  MACRO.h
//  Demo
//
//  Created by DK on 16/9/8.
//  Copyright © 2016年 DK. All rights reserved.
//

#ifndef MACRO_h
#define MACRO_h

#define iOS7            ([UIDevice currentDevice].systemVersion.floatValue >= 7.0 ? YES : NO)
#define IS_IPHONE_6P    ([[UIScreen mainScreen] bounds].size.height == 736.0f)
#define RGB(R, G, B, A) [UIColor colorWithRed:R / 255.0 green:G / 255.0 blue:B / 255.0 alpha:A]
#define KDeviceWidth    [UIScreen mainScreen].bounds.size.width //屏幕宽度
#define KDeviceHeight   [UIScreen mainScreen].bounds.size.height //屏幕高度
#define NAVBARTOP       (iOS7?64:44) //导航栏的高度
#define WEAKSELF        __weak typeof(self) weakSelf = self //弱引用

#endif
