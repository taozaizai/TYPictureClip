//
//  PhotoView.m
//  PhotoClip
//
//  Created by zhaotaoyuan on 2017/12/29.
//  Copyright © 2017年 zhaotaoyuan. All rights reserved.
//

#import "PhotoClipView.h"
#import "UIColor+Clip.h"
#import <math.h>

static const CGFloat kCropViewHotArea = 16;
static const CGFloat kMaximumCanvasWidthRatio = 1;
static const CGFloat kMaximumCanvasHeightRatio = 1;
static const CGFloat kCanvasHeaderHeigth = 0;

//#define kInstruction

@implementation PhotoContentView

    - (instancetype)initWithImage:(UIImage *)image
    {
        if (self = [super init]) {
            _image = image;
            
            self.frame = CGRectMake(0, 0, image.size.width, image.size.height);
            
            _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
            _imageView.image = self.image;
            _imageView.userInteractionEnabled = YES;
            [self addSubview:_imageView];
        }
        return self;
    }

    - (void)layoutSubviews
    {
        [super layoutSubviews];
        
        self.imageView.frame = self.bounds;
    }

@end

@interface PhotoScrollView : UIScrollView

@property (strong, nonatomic) PhotoContentView *photoContentView;

@end

@implementation PhotoScrollView

    - (void)setContentOffsetY:(CGFloat)offsetY
    {
        CGPoint contentOffset = self.contentOffset;
        contentOffset.y = offsetY;
        self.contentOffset = contentOffset;
    }

    - (void)setContentOffsetX:(CGFloat)offsetX
    {
        CGPoint contentOffset = self.contentOffset;
        contentOffset.x = offsetX;
        self.contentOffset = contentOffset;
    }

    - (CGFloat)zoomScaleToBound
    {
        CGFloat scaleW = self.bounds.size.width / self.photoContentView.bounds.size.width;
        CGFloat scaleH = self.bounds.size.height / self.photoContentView.bounds.size.height;
        CGFloat max = MAX(scaleW, scaleH);
        
        return max;
    }

@end

@interface CropView ()

@end

@implementation CropView

    - (instancetype)initWithFrame:(CGRect)frame isCircle:(BOOL)isCircle
    {
        if (self = [super initWithFrame:frame]) {
            self.layer.borderColor = [UIColor maskColor].CGColor;
//            self.backgroundColor = [UIColor maskColor];
            if (isCircle) {
                UIBezierPath *path;
                if (MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) == 812)
                {
                    path = [UIBezierPath bezierPathWithRect:CGRectMake(0, -0.18, frame.size.width, frame.size.height + 0.02)];
                }
                else
                {
                    path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, frame.size.width, frame.size.height)];
                }
                CAShapeLayer *layer = [CAShapeLayer layer];
                [path appendPath:[UIBezierPath bezierPathWithArcCenter:self.center radius:frame.size.width/2 startAngle:0 endAngle:2*M_PI clockwise:YES]];
                path.usesEvenOddFillRule = YES;
                layer.path = path.CGPath;
                layer.borderWidth = 2;
                layer.fillRule = kCAFillRuleEvenOdd;
                layer.fillColor = [UIColor maskColor].CGColor;
                [self.layer addSublayer:layer];
            } else {
                self.layer.borderWidth = 0;
            }
        }
        return self;
    }

@end

@interface PhotoClipView () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) PhotoScrollView *scrollView;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CGSize originalSize;

@property (nonatomic, assign) BOOL manualZoomed;

// masks
@property (nonatomic, strong) UIView *topMask;
@property (nonatomic, strong) UIView *leftMask;
@property (nonatomic, strong) UIView *bottomMask;
@property (nonatomic, strong) UIView *rightMask;

// constants
@property (nonatomic, assign) CGSize maximumCanvasSize;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGPoint originalPoint;

@end

@implementation PhotoClipView

    - (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image clipSize:(CGSize)size isCircle:(BOOL)isCircle
    {
        if (self = [super init]) {
            
            self.frame = frame;
            
            _image = image;
            
            // scale the image
            _maximumCanvasSize = CGSizeMake(kMaximumCanvasWidthRatio * self.frame.size.width,
                                                kMaximumCanvasHeightRatio * self.frame.size.height - kCanvasHeaderHeigth);
            
            CGFloat scaleX = image.size.width / self.maximumCanvasSize.width;
            CGFloat scaleY = image.size.height / self.maximumCanvasSize.height;
            CGFloat scale = MAX(scaleX, scaleY);
            CGRect bounds = CGRectMake(0, 0, image.size.width / scale, image.size.height / scale);
            _originalSize = bounds.size;
            
            _centerY = self.maximumCanvasSize.height / 2 + kCanvasHeaderHeigth;
            
            _scrollView = [[PhotoScrollView alloc] initWithFrame:bounds];
            _scrollView.center = CGPointMake(CGRectGetWidth(self.frame) / 2, self.centerY);
            _scrollView.bounces = YES;
            _scrollView.layer.anchorPoint = CGPointMake(0.5, 0.5);
            _scrollView.alwaysBounceVertical = YES;
            _scrollView.alwaysBounceHorizontal = YES;
            _scrollView.delegate = self;
            _scrollView.minimumZoomScale = 1;
            _scrollView.maximumZoomScale = 10;
            _scrollView.showsVerticalScrollIndicator = NO;
            _scrollView.showsHorizontalScrollIndicator = NO;
            _scrollView.clipsToBounds = NO;
            _scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
            [self addSubview:_scrollView];
    #ifdef kInstruction
            _scrollView.layer.borderColor = [UIColor redColor].CGColor;
            _scrollView.layer.borderWidth = 1;
            _scrollView.showsVerticalScrollIndicator = YES;
            _scrollView.showsHorizontalScrollIndicator = YES;
    #endif
            
            _photoContentView = [[PhotoContentView alloc] initWithImage:image];
            _photoContentView.frame = _scrollView.bounds;
            
            //旋转手势
            UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
            rotate.delegate = self;
            [self addGestureRecognizer:rotate];
            _photoContentView.backgroundColor = [UIColor clearColor];
            _photoContentView.userInteractionEnabled = YES;
            _scrollView.photoContentView = self.photoContentView;
            [self.scrollView addSubview:_photoContentView];
            
            _cropView = [[CropView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) isCircle:isCircle];
            _cropView.center = self.scrollView.center;
            [self addSubview:_cropView];
            
            UIColor *maskColor = [UIColor maskColor];
            _topMask = [UIView new];
            _topMask.backgroundColor = maskColor;
            [self addSubview:_topMask];
            _leftMask = [UIView new];
            _leftMask.backgroundColor = maskColor;
            [self addSubview:_leftMask];
            _bottomMask = [UIView new];
            _bottomMask.backgroundColor = maskColor;
            [self addSubview:_bottomMask];
            _rightMask = [UIView new];
            _rightMask.backgroundColor = maskColor;
            [self addSubview:_rightMask];
            [self updateMasks:NO];
            [self resizeScrollView];
            
            _originalPoint = [self convertPoint:self.scrollView.center toView:self];
        }
        return self;
    }

    - (void) resizeScrollView {
       CGFloat width = fabs(cos(self.angle)) * self.cropView.frame.size.width + fabs(sin(self.angle)) * self.cropView.frame.size.height;
       CGFloat height = fabs(sin(self.angle)) * self.cropView.frame.size.width + fabs(cos(self.angle)) * self.cropView.frame.size.height;
       CGPoint center = self.scrollView.center;
       
       CGPoint contentOffset = self.scrollView.contentOffset;
       CGPoint contentOffsetCenter = CGPointMake(contentOffset.x + self.scrollView.bounds.size.width / 2, contentOffset.y + self.scrollView.bounds.size.height / 2);
       self.scrollView.bounds = CGRectMake(0, 0, width, height);
       CGPoint newContentOffset = CGPointMake(contentOffsetCenter.x - self.scrollView.bounds.size.width / 2, contentOffsetCenter.y - self.scrollView.bounds.size.height / 2);
       self.scrollView.contentOffset = newContentOffset;
       self.scrollView.center = center;

    }


    - (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
    {
        if (CGRectContainsPoint(CGRectInset(self.cropView.frame, -kCropViewHotArea, -kCropViewHotArea), point) && !CGRectContainsPoint(CGRectInset(self.cropView.frame, kCropViewHotArea, kCropViewHotArea), point)) {
            return self.cropView;
        }
        return self.scrollView;
    }

    - (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
    {
        return self.photoContentView;
    }

    - (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
    {
        self.manualZoomed = YES;
    }

    - (void)updateMasks:(BOOL)animate
    {
        void (^animationBlock)(void) = ^(void) {
            self.topMask.frame = CGRectMake(0, 0, self.cropView.frame.origin.x + self.cropView.frame.size.width, self.cropView.frame.origin.y);
            self.leftMask.frame = CGRectMake(0, self.cropView.frame.origin.y, self.cropView.frame.origin.x, self.frame.size.height - self.cropView.frame.origin.y);
            self.bottomMask.frame = CGRectMake(self.cropView.frame.origin.x, self.cropView.frame.origin.y + self.cropView.frame.size.height, self.frame.size.width - self.cropView.frame.origin.x, self.frame.size.height - (self.cropView.frame.origin.y + self.cropView.frame.size.height));
            self.rightMask.frame = CGRectMake(self.cropView.frame.origin.x + self.cropView.frame.size.width, 0, self.frame.size.width - (self.cropView.frame.origin.x + self.cropView.frame.size.width), self.cropView.frame.origin.y + self.cropView.frame.size.height);
        };
        
        if (animate) {
            [UIView animateWithDuration:0.25 animations:animationBlock];
        } else {
            animationBlock();
        }
    }

    - (void)checkScrollViewContentOffset
    {
        self.scrollView.contentOffsetX = MAX(self.scrollView.contentOffset.x, 0);
        self.scrollView.contentOffsetY = MAX(self.scrollView.contentOffset.y, 0);
        
        if (self.scrollView.contentSize.height - self.scrollView.contentOffset.y <= self.scrollView.bounds.size.height) {
            self.scrollView.contentOffsetY = self.scrollView.contentSize.height - self.scrollView.bounds.size.height;
        }
        
        if (self.scrollView.contentSize.width - self.scrollView.contentOffset.x <= self.scrollView.bounds.size.width) {
            self.scrollView.contentOffsetX = self.scrollView.contentSize.width - self.scrollView.bounds.size.width;
        }
    }


    - (void)handleRotation:(UIRotationGestureRecognizer *)gesture {
        // update masks
        [self updateMasks:NO];
        
        // rotate scroll view
        
        CGAffineTransform transform = CGAffineTransformRotate(self.scrollView.transform, gesture.rotation);
        
        CGFloat tempAngle = atanf(self.scrollView.transform.b/self.scrollView.transform.a);
        
        self.scrollView.transform = transform;
        
        //由于tan值大于90度到180度的值与-90度到0度的值一样，所以需要cos和sin值进行辅助
        self.angle = tempAngle;
        if (transform.a < 0 && tempAngle < 0) {
            //说明在90 - 180
            self.angle = tempAngle + M_PI;
        }
        
        if (transform.a < 0 && tempAngle > 0) {
            //说明在（-180） - （-90）
            self.angle = tempAngle - M_PI;
            
        }
        gesture.rotation = 0;
        
        if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
            // position scroll view
            [self resizeScrollView];
            
            // scale scroll view
            BOOL shouldScale = self.scrollView.contentSize.width / self.scrollView.bounds.size.width <= 1.0 || self.scrollView.contentSize.height / self.scrollView.bounds.size.height <= 1.0;
            if (!self.manualZoomed || shouldScale) {
                [UIView animateWithDuration:0.4 animations:^{
                    [self.scrollView setZoomScale:[self.scrollView zoomScaleToBound] animated:NO];
                    self.scrollView.minimumZoomScale = [self.scrollView zoomScaleToBound];
                }];
                self.manualZoomed = NO;
                
            }
            
            [self checkScrollViewContentOffset];
        }
    }

    - (CGPoint)photoTranslation
    {
        CGRect rect = [self.photoContentView convertRect:self.photoContentView.bounds toView:self];
        CGPoint point = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
        CGPoint zeroPoint = CGPointMake(CGRectGetWidth(self.frame) / 2, self.centerY);
        return CGPointMake(point.x - zeroPoint.x, point.y - zeroPoint.y);
    }

    - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
        return YES;
    }


@end
