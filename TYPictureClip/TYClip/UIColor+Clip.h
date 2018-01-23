//
//  UIColor+Clip.h
//  PhotoClip
//
//  Created by zhaotaoyuan on 2017/12/29.
//  Copyright © 2017年 zhaotaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Tweak)

+ (UIColor *)cancelButtonColor;
+ (UIColor *)cancelButtonHighlightedColor;

+ (UIColor *)saveButtonColor;
+ (UIColor *)saveButtonHighlightedColor;

+ (UIColor *)resetButtonColor;
+ (UIColor *)resetButtonHighlightedColor;

+ (UIColor *)cropLineColor;
+ (UIColor *)gridLineColor;
+ (UIColor *)maskColor;
+ (UIColor *)photoTweakCanvasBackgroundColor;

@end
