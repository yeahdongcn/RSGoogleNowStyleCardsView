//
//  RSCardView.m
//  Google Now Style Card View
//
//  Created by R0CKSTAR on 5/21/13.
//  Copyright (c) 2013 P.D.Q. All rights reserved.
//

#import "RSCardView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Folding.h"
#import "UIColor+Expanded.h"

// Percentage limit to trigger certain action
static CGFloat const kRSActionThreshold            = 0.70;
// Maximum bounce amplitude
static CGFloat const kRSBounceAmplitude            = 20.0;
// Duration of the first part of the bounce animation
static NSTimeInterval const kRSBounceDurationForth = 0.2;
// Duration of the second part of the bounce animation
static NSTimeInterval const kRSBounceDurationBack  = 0.1;
// Lowest duration when swipping the cell because we try to simulate velocity
static NSTimeInterval const kRSDurationLowLimit    = 0.25;
// Highest duration when swipping the cell because we try to simulate velocity
static NSTimeInterval const kRSDurationHighLimit   = 0.1;

static const int kContentViewShadowRadius = 2;
#define kContentViewShadowOffset CGSizeMake(0, 1)
#define kContentViewMargin       UIEdgeInsetsMake(kContentViewShadowRadius * 2, 10, kContentViewShadowRadius * 2 + kContentViewShadowOffset.height /*adjust*/ + 2, 10)

@interface RSCardView () <UIGestureRecognizerDelegate> {
    UIPanGestureRecognizer *_panGestureRecognizer;
    UITapGestureRecognizer *_tapGestureRecognizer;
}

@end

@implementation RSCardView

#pragma mark - Private

- (void)toggleSettings:(UIButton *)button {
    button.selected = !button.selected;
    
    CGRect frame = _settingsView.frame;
    
    if (button.selected) {
        _settingsView.hidden = NO;
        frame.origin.y = (_contentView.frame.origin.y + _contentView.frame.size.height);
    }
    
    _settingsView.frame = frame;
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         CGRect frame = self.frame;
                         
                         if (button.selected) {
                             frame.size.height += _settingsView.frame.size.height;
                         } else {
                             frame.size.height -= _settingsView.frame.size.height;
                         }
                         
                         self.frame = frame;
                         
                         if (_delegate && [_delegate respondsToSelector:@selector(didChangeFrame:)]) {
                             [_delegate didChangeFrame:self];
                         }
                     }
     
                     completion: ^(BOOL finished) {
                         if (!button.selected) {
                             _settingsView.hidden = YES;
                         }
                     }];
    
    UIColor *backgroundColor = nil;
    
    if (_delegate && [_delegate respondsToSelector:@selector(superviewBackgroundColor)]) {
        backgroundColor = [_delegate superviewBackgroundColor];
    } else {
        backgroundColor = [UIColor lightGrayColor];
    }
    
    if (button.selected) {
        [_contentView showFoldingView:_settingsView
                      backgroundColor:backgroundColor
                                folds:1
                            direction:KBFoldingViewDirectionFromTop
                             duration:0.3
                         onCompletion:nil];
    } else {
        [_contentView hideFoldingView:_settingsView
                      backgroundColor:backgroundColor
                                folds:1
                            direction:KBFoldingViewDirectionFromTop
                             duration:0.3
                         onCompletion:nil];
    }
}

- (void)settingsButtonClicked:(UIButton *)button {
    if (_delegate && [_delegate respondsToSelector:@selector(canToggleSettings:)]) {
        if ([_delegate canToggleSettings:self]) {
            [self toggleSettings:button];
        } else {
            if (_delegate && [_delegate respondsToSelector:@selector(didTapOnCard:)]) {
                [_delegate didTapOnCard:self];
            }
            
            _shouldOpenSettingsLater = YES;
        }
    }
}

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        _settingsView = [[[UIView alloc] initWithFrame:CGRectMake(kContentViewMargin.left, 0, self.bounds.size.width - kContentViewMargin.left - kContentViewMargin.right, 0)] autorelease];
        _settingsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _settingsView.backgroundColor = [UIColor lightGrayColor];
        _settingsView.hidden = YES;
        [self addSubview:_settingsView];
        
        _contentView = [[[UIView alloc] initWithFrame:CGRectMake(kContentViewMargin.left, kContentViewMargin.top, self.bounds.size.width - kContentViewMargin.left - kContentViewMargin.right, 0)] autorelease];
        _contentView.layer.anchorPoint = CGPointMake(0, 1);
        CGRect frame = _contentView.frame;
        frame.origin.x = frame.origin.x - roundf(frame.size.width / 2.f);
        _contentView.frame = frame;
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        _contentView.layer.borderWidth = 1;
        _contentView.layer.masksToBounds = NO;
        _contentView.layer.shadowColor = [UIColor colorWithRGBHex:0x5e5c5c].CGColor;
        _contentView.layer.shadowOpacity = 0.75;
        _contentView.layer.shadowRadius = kContentViewShadowRadius;
        _contentView.layer.shadowOffset = kContentViewShadowOffset;
        _contentView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:_contentView.bounds] CGPath];
        _contentView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        _contentView.layer.shouldRasterize = YES;
        [self addSubview:_contentView];
        
        _settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_settingsButton setImage:[UIImage imageNamed:@"Settings"] forState:UIControlStateNormal];
        [_settingsButton addTarget:self action:@selector(settingsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_settingsButton sizeToFit];
        [_contentView addSubview:_settingsButton];
        
        _panGestureRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)] autorelease];
        _panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:_panGestureRecognizer];
        
        _tapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)] autorelease];
        _tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:_tapGestureRecognizer];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = _settingsButton.frame;
    frame.origin.x = _contentView.bounds.size.width - frame.size.width - 5;
    frame.origin.y = 5;
    _settingsButton.frame = frame;
}

#pragma mark - Handle Gestures

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    if (_tapGestureRecognizer == gestureRecognizer) {
        if ([gestureRecognizer state] == UIGestureRecognizerStateRecognized) {
            if (_delegate && [_delegate respondsToSelector:@selector(didTapOnCard:)]) {
                [_delegate didTapOnCard:self];
            }
        }
    }
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    if (_panGestureRecognizer == gestureRecognizer) {
        UIGestureRecognizerState state = [gestureRecognizer state];
        CGPoint translation = [gestureRecognizer translationInView:self];
        CGPoint velocity = [gestureRecognizer velocityInView:self];
        CGFloat percentage = [self percentageWithOffset:CGRectGetMinX(self.frame) relativeToWidth:CGRectGetWidth(self.bounds)];
        NSTimeInterval animationDuration = [self animationDurationWithVelocity:velocity];
        RSCardViewSwipeDirection direction = [self directionWithPercentage:percentage];
        
        if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
            CGPoint center = { self.center.x + translation.x, self.center.y };
            [self setCenter:center];
            [self updateAlpha];
            [gestureRecognizer setTranslation:CGPointZero inView:self];
        } else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
            if (direction != RSCardViewSwipeDirectionCenter) {
                [self moveWithDuration:animationDuration andDirection:direction];
            } else {
                [self bounceWithDistance:kRSBounceAmplitude * percentage];
            }
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (_panGestureRecognizer == gestureRecognizer) {
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint velocity = [panGestureRecognizer velocityInView:self];
        return fabsf(velocity.x) > fabsf(velocity.y);
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (_tapGestureRecognizer == gestureRecognizer) {
        if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Utils

- (CGFloat)percentageWithOffset:(CGFloat)offset relativeToWidth:(CGFloat)width {
    CGFloat percentage = offset / width;
    
    if (percentage < -1.0) percentage = -1.0;
    else if (percentage > 1.0) percentage = 1.0;
    
    return percentage;
}

- (NSTimeInterval)animationDurationWithVelocity:(CGPoint)velocity {
    CGFloat width = CGRectGetWidth(self.bounds);
    NSTimeInterval animationDurationDiff = kRSDurationHighLimit - kRSDurationLowLimit;
    CGFloat horizontalVelocity = velocity.x;
    
    if (horizontalVelocity < -width) horizontalVelocity = -width;
    else if (horizontalVelocity > width) horizontalVelocity = width;
    
    return (kRSDurationHighLimit + kRSDurationLowLimit) - fabs(((horizontalVelocity / width) * animationDurationDiff));
}

- (RSCardViewSwipeDirection)directionWithPercentage:(CGFloat)percentage {
    if (percentage < -kRSActionThreshold) {
        return RSCardViewSwipeDirectionLeft;
    } else if (percentage > kRSActionThreshold) {
        return RSCardViewSwipeDirectionRight;
    } else {
        return RSCardViewSwipeDirectionCenter;
    }
}

- (void)updateAlpha {
    self.alpha = (self.frame.size.width - fabsf(self.frame.origin.x)) / self.frame.size.width;
}

#pragma mark - Movement

- (void)moveWithDuration:(NSTimeInterval)duration andDirection:(RSCardViewSwipeDirection)direction {
    CGRect frame = self.frame;
    
    if (direction == RSCardViewSwipeDirectionLeft) {
        frame.origin.x = -CGRectGetWidth(self.bounds);
    } else {
        frame.origin.x = CGRectGetWidth(self.bounds);
    }
    
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                     animations: ^{
                         [self setFrame:frame];
                         [self updateAlpha];
                     }
     
                     completion: ^(BOOL finished) {
                         [self removeFromSuperview];
                         
                         if (_delegate && [_delegate respondsToSelector:@selector(didRemoveFromSuperview:)]) {
                             [_delegate didRemoveFromSuperview:self];
                         }
                     }];
}

- (void)bounceWithDistance:(CGFloat)bounceDistance {
    [UIView animateWithDuration:kRSBounceDurationForth
                          delay:0
                        options:(UIViewAnimationOptionCurveEaseOut)
                     animations: ^{
                         CGRect frame = self.frame;
                         frame.origin.x = -bounceDistance;
                         [self setFrame:frame];
                         [self updateAlpha];
                     }
     
                     completion: ^(BOOL forthFinished) {
                         [UIView  animateWithDuration:kRSBounceDurationBack
                                                delay:0
                                              options:UIViewAnimationOptionCurveEaseIn
                                           animations: ^{
                                               CGRect frame = self.frame;
                                               frame.origin.x = 0;
                                               [self setFrame:frame];
                                           }
                          
                                           completion: ^(BOOL backFinished) {
                                           }];
                     }];
}

#pragma mark - Public

- (void)toggleSettings {
    [self toggleSettings:_settingsButton];
}

- (BOOL)isSettingsVisible {
    return _settingsButton.selected;
}

- (void)setContentViewHeight:(CGFloat)height animated:(BOOL)animated {
    void (^ updateFrame)() = ^() {
        CGRect frame = _contentView.frame;
        frame.size.height = height;
        _contentView.frame = frame;
        
        frame = self.frame;
        frame.size.height = height + kContentViewMargin.top + kContentViewMargin.bottom;
        self.frame = frame;
        
        _contentView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:_contentView.bounds] CGPath];
    };
    
    if (animated) {
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations: ^{
                             updateFrame();
                         }
         
                         completion: ^(BOOL finished) {
                         }];
    } else {
        updateFrame();
    }
}

- (void)setSettingsViewHeight:(CGFloat)settingsViewHeight {
    CGRect frame = _settingsView.frame;
    
    frame.size.height = settingsViewHeight;
    frame.origin.y = (_contentView.frame.origin.y + _contentView.frame.size.height - frame.size.height);
    _settingsView.frame = frame;
}

#pragma mark - Insert animation

- (void)insertAnimation {
    _contentView.layer.opacity = 0;
    _contentView.layer.transform = CATransform3DTranslate(CATransform3DMakeRotation(M_PI_4 / 4.f, 0, 0, 1), 0, roundf(_contentView.bounds.size.height / 2.f), 0);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:_contentView.layer.transform];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.fillMode = kCAFillModeForwards;
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.delegate = self;
    _contentView.layer.transform = CATransform3DIdentity;
    [_contentView.layer addAnimation:animation forKey:@"rotation"];
    
    animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithInt:0];
    animation.toValue = [NSNumber numberWithInt:1];
    animation.fillMode = kCAFillModeForwards;
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    _contentView.layer.opacity = 1;
    [_contentView.layer addAnimation:animation forKey:@"opacity"];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim {
    if (_delegate && [_delegate respondsToSelector:@selector(insertAnimationDidStart)]) {
        [_delegate insertAnimationDidStart];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (_delegate && [_delegate respondsToSelector:@selector(insertAnimationDidStop)]) {
        [_delegate insertAnimationDidStop];
    }
}

@end
