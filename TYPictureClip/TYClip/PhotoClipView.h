//
//  PhotoView.h
//  PhotoClip
//
//  Created by zhaotaoyuan on 2017/12/29.
//  Copyright © 2017年 zhaotaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CropView;

@interface PhotoContentView : UIView

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;

@end

@interface CropView : UIView

- (instancetype)initWithFrame:(CGRect)frame isCircle:(BOOL)isCircle;

@end

@interface PhotoClipView : UIView

@property (assign, nonatomic) CGFloat angle;
@property (strong, nonatomic) PhotoContentView *photoContentView;
@property (assign, nonatomic) CGPoint photoContentOffset;
@property (strong, nonatomic) CropView *cropView;
@property (assign, nonatomic) CGFloat clipWidth;
@property (assign, nonatomic) CGFloat clipHeight;

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image clipSize:(CGSize)size isCircle:(BOOL)isCircle;
- (CGPoint)photoTranslation;

@end
