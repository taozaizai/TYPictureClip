//
//  PhotoClipViewController.m
//  PhotoClip
//
//  Created by zhaotaoyuan on 2017/12/29.
//  Copyright © 2017年 zhaotaoyuan. All rights reserved.
//

#import "PhotoClipViewController.h"
#import "PhotoClipView.h"
#import "UIColor+Clip.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoClipViewController ()

@property (strong, nonatomic) PhotoClipView *photoView;

@end

@implementation PhotoClipViewController

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super init]) {
        _image = image;
        _autoSaveToLibray = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = YES;

    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor photoTweakCanvasBackgroundColor];

    [self setupSubviews];
}

- (void)setupSubviews
{
    self.photoView = [[PhotoClipView alloc] initWithFrame:self.view.bounds image:self.image clipSize:CGSizeMake(self.clipWidth, self.clipHeight) isCircle:self.isCircle];
    self.photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.photoView];



    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    UIColor *cancelTitleColor = !self.cancelButtonTitleColor ?
    [UIColor cancelButtonColor] : self.cancelButtonTitleColor;
    [cancelBtn setTitleColor:cancelTitleColor forState:UIControlStateNormal];
    UIColor *cancelHighlightTitleColor = !self.cancelButtonHighlightTitleColor ?
    [UIColor cancelButtonHighlightedColor] : self.cancelButtonHighlightTitleColor;
    [cancelBtn setTitleColor:cancelHighlightTitleColor forState:UIControlStateHighlighted];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [cancelBtn addTarget:self action:@selector(cancelBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];

    cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *cancelBtnBottom = [cancelBtn.bottomAnchor constraintEqualToAnchor: self.bottomLayoutGuide.topAnchor];
    NSLayoutConstraint *cancelBtnLeft = [cancelBtn.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:8];
    NSLayoutConstraint *cancelBtnHeight = [cancelBtn.heightAnchor constraintEqualToConstant: 40];
    NSLayoutConstraint *cancelBtnWidth = [cancelBtn.widthAnchor constraintEqualToConstant: 60];

    [NSLayoutConstraint activateConstraints: @[cancelBtnBottom, cancelBtnLeft, cancelBtnWidth, cancelBtnHeight]];
    
    UIButton *cropBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cropBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [cropBtn setTitle:@"保存" forState:UIControlStateNormal];
    UIColor *saveButtonTitleColor = !self.saveButtonTitleColor ?
    [UIColor saveButtonColor] : self.saveButtonTitleColor;
    [cropBtn setTitleColor:saveButtonTitleColor forState:UIControlStateNormal];
    
    UIColor *saveButtonHighlightTitleColor = !self.saveButtonHighlightTitleColor ?
    [UIColor saveButtonHighlightedColor] : self.saveButtonHighlightTitleColor;
    [cropBtn setTitleColor:saveButtonHighlightTitleColor forState:UIControlStateHighlighted];
    cropBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [cropBtn addTarget:self action:@selector(saveBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cropBtn];


    cropBtn.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *cropBtnBottom = [cropBtn.bottomAnchor constraintEqualToAnchor: self.bottomLayoutGuide.topAnchor];
    NSLayoutConstraint *cropBtnRight = [cropBtn.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-8];
    NSLayoutConstraint *cropBtnHeight = [cropBtn.heightAnchor constraintEqualToConstant: 40];
    NSLayoutConstraint *cropBtnWidth = [cropBtn.widthAnchor constraintEqualToConstant: 60];

    [NSLayoutConstraint activateConstraints: @[cropBtnBottom, cropBtnRight, cropBtnWidth, cropBtnHeight]];
}

- (void)cancelBtnTapped
{
    [self.delegate PhotoClipControllerDidCancel:self];
}

- (void)saveBtnTapped
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    // translate
    CGPoint translation = [self.photoView photoTranslation];
    transform = CGAffineTransformTranslate(transform, translation.x, translation.y);

    // rotate
    transform = CGAffineTransformRotate(transform, self.photoView.angle);

    // scale
    CGAffineTransform t = self.photoView.photoContentView.transform;
    CGFloat xScale =  sqrt(t.a * t.a + t.c * t.c);
    CGFloat yScale = sqrt(t.b * t.b + t.d * t.d);
    transform = CGAffineTransformScale(transform, xScale, yScale);

    CGImageRef imageRef = [self newTransformedImage:transform
                                        sourceImage:self.image.CGImage
                                         sourceSize:self.image.size
                                  sourceOrientation:self.image.imageOrientation
                                        outputWidth:self.image.size.width
                                           cropSize:self.photoView.cropView.frame.size
                                      imageViewSize:self.photoView.photoContentView.bounds.size];

    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    [self.delegate PhotoClipController:self didFinishWithCroppedImage:image];
}

- (CGImageRef)newScaledImage:(CGImageRef)source withOrientation:(UIImageOrientation)orientation toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality
{
    CGSize srcSize = size;
    CGFloat rotation = 0.0;

    switch(orientation)
    {
        case UIImageOrientationUp: {
            rotation = 0;
        } break;
        case UIImageOrientationDown: {
            rotation = M_PI;
        } break;
        case UIImageOrientationLeft:{
            rotation = M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        case UIImageOrientationRight: {
            rotation = -M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        default:
            break;
    }

    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 size.width,
                                                 size.height,
                                                 8,  //CGImageGetBitsPerComponent(source),
                                                 0,
                                                 CGImageGetColorSpace(source),
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst  //CGImageGetBitmapInfo(source)
                                                 );

    CGContextSetInterpolationQuality(context, quality);
    CGContextTranslateCTM(context,  size.width/2,  size.height/2);
    CGContextRotateCTM(context,rotation);

    CGContextDrawImage(context, CGRectMake(-srcSize.width/2 ,
                                           -srcSize.height/2,
                                           srcSize.width,
                                           srcSize.height),
                       source);

    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);

    return resultRef;
}

- (CGImageRef)newTransformedImage:(CGAffineTransform)transform
                      sourceImage:(CGImageRef)sourceImage
                       sourceSize:(CGSize)sourceSize
                sourceOrientation:(UIImageOrientation)sourceOrientation
                      outputWidth:(CGFloat)outputWidth
                         cropSize:(CGSize)cropSize
                    imageViewSize:(CGSize)imageViewSize
{
    CGImageRef source = [self newScaledImage:sourceImage
                             withOrientation:sourceOrientation
                                      toSize:sourceSize
                                 withQuality:kCGInterpolationNone];

    CGFloat aspect = cropSize.height/cropSize.width;
    CGSize outputSize = CGSizeMake(outputWidth, outputWidth*aspect);

    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 outputSize.width,
                                                 outputSize.height,
                                                 CGImageGetBitsPerComponent(source),
                                                 0,
                                                 CGImageGetColorSpace(source),
                                                 CGImageGetBitmapInfo(source));
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, outputSize.width, outputSize.height));

    CGAffineTransform uiCoords = CGAffineTransformMakeScale(outputSize.width / cropSize.width,
                                                            outputSize.height / cropSize.height);
    uiCoords = CGAffineTransformTranslate(uiCoords, cropSize.width/2.0, cropSize.height / 2.0);
    uiCoords = CGAffineTransformScale(uiCoords, 1.0, -1.0);
    CGContextConcatCTM(context, uiCoords);

    CGContextConcatCTM(context, transform);
    CGContextScaleCTM(context, 1.0, -1.0);

    CGContextDrawImage(context, CGRectMake(-imageViewSize.width/2.0,
                                           -imageViewSize.height/2.0,
                                           imageViewSize.width,
                                           imageViewSize.height)
                       , source);

    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGImageRelease(source);
    return resultRef;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
