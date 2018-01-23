//
//  PhotoClipViewController.h
//  PhotoClip
//
//  Created by zhaotaoyuan on 2017/12/29.
//  Copyright © 2017年 DoMobile21. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoClipViewControllerDelegate;

/**
 The photo clip controller.
 */
@interface PhotoClipViewController : UIViewController

/**
 是否圆形切割
 */
@property (nonatomic, assign) BOOL isCircle;

/**
 Image to process.
 */
@property (nonatomic, strong, readonly) UIImage *image;

/**
 Flag indicating whether the image cropped will be saved to photo library automatically. Defaults to YES.
 */
@property (nonatomic, assign) BOOL autoSaveToLibray;

/**
 The optional photo clip controller delegate.
 */
@property (nonatomic, weak) id<PhotoClipViewControllerDelegate> delegate;

/**
 Save action button's default title color
 */
@property (nonatomic, strong) UIColor *saveButtonTitleColor;

/**
 Save action button's highlight title color
 */
@property (nonatomic, strong) UIColor *saveButtonHighlightTitleColor;

/**
 Cancel action button's default title color
 */
@property (nonatomic, strong) UIColor *cancelButtonTitleColor;

/**
 Cancel action button's highlight title color
 */
@property (nonatomic, strong) UIColor *cancelButtonHighlightTitleColor;

/**
 Reset action button's default title color
 */
@property (nonatomic, strong) UIColor *resetButtonTitleColor;

/**
 Reset action button's highlight title color
 */
@property (nonatomic, strong) UIColor *resetButtonHighlightTitleColor;

/**
 Slider tint color
 */
@property (nonatomic, strong) UIColor *sliderTintColor;

/**
 clipWidth
 */
@property (nonatomic, assign) CGFloat clipWidth;

/**
 clipHeight
 */
@property (nonatomic, assign) CGFloat clipHeight;


/**
 Creates a photo clip view controller with the image to process.
 */
- (instancetype)initWithImage:(UIImage *)image;

@end

/**
 The photo clip controller delegate
 */
@protocol PhotoClipViewControllerDelegate <NSObject>

/**
 Called on image cropped.
 */
- (void)PhotoClipController:(PhotoClipViewController *)controller didFinishWithCroppedImage:(UIImage *)croppedImage;

/**
 Called on cropping image canceled
 */
- (void)PhotoClipControllerDidCancel:(PhotoClipViewController *)controller;

@end
