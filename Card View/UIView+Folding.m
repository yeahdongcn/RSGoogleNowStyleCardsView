#import "UIView+Folding.h"

static NSUInteger _KBTransitionState = KBFoldingTransitionStateIdle;

KeyframeParametrizedBlock kbOpenFunction = ^double (NSTimeInterval time) {
    return sin(time * M_PI_2);
};

KeyframeParametrizedBlock kbCloseFunction = ^double (NSTimeInterval time) {
    return -cos(time * M_PI_2) + 1.0f;
};

@implementation CAKeyframeAnimation (Parametrized)
//
// Private Interface
//
+ (id)parametrizedAnimationWithKeyPath:(NSString *)path
                              function:(KeyframeParametrizedBlock)function
                             fromValue:(CGFloat)fromValue
                               toValue:(CGFloat)toValue {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:path];
    NSUInteger steps = 100;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:steps];
    double time = 0.0f;
    double timeStep = 1.0 / (double)(steps - 1);
    
    for (NSUInteger i = 0; i < steps; ++i) {
        double value = fromValue + (function(time) * (toValue - fromValue));
        [values addObject:@(value)];
        time += timeStep;
    }
    
    animation.calculationMode = kCAAnimationLinear;
    [animation setValues:values];
    return animation;
}

@end

@interface UIView (FoldingPrivate)

- (BOOL)validateDuration:(NSTimeInterval)duration direction:(NSUInteger)direction folds:(NSUInteger)folds;

@end

@implementation UIView (Folding)

- (NSUInteger)state {
    return _KBTransitionState;
}

+ (CATransformLayer *)transformLayerfromImage:(UIImage *)image
                                        frame:(CGRect)frame
                                     duration:(NSTimeInterval)duration
                                  anchorPoint:(CGPoint)anchorPoint
                                   startAngle:(CGFloat)startAngle
                                     endAngle:(CGFloat)endAngle {
    CATransformLayer *jointLayer = [CATransformLayer layer];
    
    jointLayer.anchorPoint = anchorPoint;
    CALayer *imageLayer = [CALayer layer];
    CAGradientLayer *shadowLayer = [CAGradientLayer layer];
    double shadowAniOpacity = 0.0f;
    
    if (anchorPoint.y == 0.5f) {
        CGFloat layerWidth = 0.0f;
        
        if (anchorPoint.x == 0.0f) {
            layerWidth = image.size.width - frame.origin.x;
            jointLayer.frame = CGRectMake(0.0f, 0.0f, layerWidth, frame.size.height);
            
            if (frame.origin.x) {
                jointLayer.position = CGPointMake(frame.size.width, frame.size.height / 2.0f);
            } else {
                jointLayer.position = CGPointMake(0.0f, frame.size.height / 2.0f);
            }
        } else {
            layerWidth = frame.origin.x + frame.size.width;
            jointLayer.frame = CGRectMake(0.0f, 0.0f, layerWidth, frame.size.height);
            jointLayer.position = CGPointMake(layerWidth, frame.size.height / 2.0f);
        }
        
        // Map the image onto the transform layer
        imageLayer.frame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
        imageLayer.anchorPoint = anchorPoint;
        imageLayer.position = CGPointMake(layerWidth * anchorPoint.x, frame.size.height / 2.0f);
        [jointLayer addSublayer:imageLayer];
        
        CGImageRef imageCrop = CGImageCreateWithImageInRect(image.CGImage, frame);
        imageLayer.contents = (id)imageCrop;
        CFRelease(imageCrop);
        imageLayer.backgroundColor = [UIColor clearColor].CGColor;
        
        // Add drop shadow
        NSInteger index = frame.origin.x / frame.size.width;
        shadowLayer.frame = imageLayer.bounds;
        shadowLayer.backgroundColor = [UIColor darkGrayColor].CGColor;
        shadowLayer.opacity = 0.0f;
        shadowLayer.colors = @[(id)[UIColor blackColor].CGColor,
                               (id)[UIColor clearColor].CGColor];
        
        if (index % 2 != 0.0f) {
            shadowLayer.startPoint = CGPointMake(0.0f, 0.5f);
            shadowLayer.endPoint = CGPointMake(1.0f, 0.5f);
            shadowAniOpacity = (anchorPoint.x != 0.0f) ? 0.24f : 0.32f;
        } else {
            shadowLayer.startPoint = CGPointMake(1.0f, 0.5f);
            shadowLayer.endPoint = CGPointMake(0.0f, 0.5f);
            shadowAniOpacity = (anchorPoint.x != 0.0f) ? 0.32f : 0.24f;
        }
        
        [imageLayer addSublayer:shadowLayer];
    } else {
        CGFloat layerHeight;
        
        if (anchorPoint.y == 0.0f) {
            layerHeight = image.size.height - frame.origin.y;
            jointLayer.frame = CGRectMake(0.0f, 0.0f, frame.size.width, layerHeight);
            
            if (frame.origin.y) {
                jointLayer.position = CGPointMake(frame.size.width / 2.0f, frame.size.height);
            } else {
                jointLayer.position = CGPointMake(frame.size.width / 2.0f, 0.0f);
            }
        } else {
            layerHeight = frame.origin.y + frame.size.height;
            jointLayer.frame = CGRectMake(0.0f, 0.0f, frame.size.width, layerHeight);
            jointLayer.position = CGPointMake(frame.size.width / 2.0f, layerHeight);
        }
        
        // Map the image onto the transform layer
        imageLayer.frame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
        imageLayer.anchorPoint = anchorPoint;
        imageLayer.position = CGPointMake(frame.size.width / 2.0f, layerHeight * anchorPoint.y);
        [jointLayer addSublayer:imageLayer];
        
        CGImageRef imageCrop = CGImageCreateWithImageInRect(image.CGImage, frame);
        imageLayer.contents = (id)imageCrop;
        CFRelease(imageCrop);
        imageLayer.backgroundColor = [UIColor clearColor].CGColor;
        
        // Add a drop-shadow layer
        NSInteger index = frame.origin.y / frame.size.height;
        shadowLayer.frame = imageLayer.bounds;
        shadowLayer.backgroundColor = [UIColor darkGrayColor].CGColor;
        shadowLayer.opacity = 0.0f;
        shadowLayer.colors = @[(id)[UIColor blackColor].CGColor,
                               (id)[UIColor clearColor].CGColor];
        
        if (index % 2 != 0.0f) {
            shadowLayer.startPoint = CGPointMake(0.05f, 0.0f);
            shadowLayer.endPoint = CGPointMake(0.5f, 1.0f);
            shadowAniOpacity = (anchorPoint.x != 0.0f) ? 0.24f : 0.32f;
        } else {
            shadowLayer.startPoint = CGPointMake(0.5f, 1.0f);
            shadowLayer.endPoint = CGPointMake(0.5f, 0.0f);
            shadowAniOpacity = (anchorPoint.x != 0.0f) ? 0.32f : 0.24f;
        }
        
        [imageLayer addSublayer:shadowLayer];
    }
    
    // Configure the open/close animation
    CABasicAnimation *animation = (anchorPoint.y == 0.5) ?
    [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"] :
    [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    [animation setDuration:duration];
    [animation setFromValue:[NSNumber numberWithDouble:startAngle]];
    [animation setToValue:[NSNumber numberWithDouble:endAngle]];
    [animation setRemovedOnCompletion:NO];
    [jointLayer addAnimation:animation forKey:@"jointAnimation"];
    
    // Configure the shadow opacity
    animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [animation setDuration:duration];
    [animation setFromValue:@((startAngle != 0.0f) ? shadowAniOpacity : 0.0f)];
    [animation setToValue:@((startAngle != 0.0f) ? 0.0f : shadowAniOpacity)];
    [shadowLayer addAnimation:animation forKey:nil];
    
    return jointLayer;
}

#pragma mark -
#pragma mark Show Methods

//
// SHOW METHODS
//
- (void)showFoldingView:(UIView *)view
        backgroundColor:(UIColor *)backgroundColor
                  folds:(NSUInteger)folds
              direction:(NSUInteger)direction
               duration:(NSTimeInterval)duration
           onCompletion:(void (^)(BOOL finished))onCompletion {
    //
    // Guard the Method Invocation
    //
#ifdef kbFoldingViewUseBoundsChecking
    
    if (![self validateDuration:duration direction:direction folds:folds]) {
        return;
    }
    
#endif
    
    if (self.state != KBFoldingTransitionStateIdle) {
        return;
    }
    
    _KBTransitionState = KBFoldingTransitionStateUpdate;
    
    //
    // Configure the target subview
    //
    if ([view superview] != nil) {
        [view removeFromSuperview];
    }
    
    [[self superview] insertSubview:view belowSubview:self];
    
    //
    // Configure the target frame
    //
    CGPoint anchorPoint = CGPointZero;
    switch (direction) {
        case KBFoldingViewDirectionFromRight:
            anchorPoint = CGPointMake(1.0f, 0.5f);
            break;
            
        case KBFoldingViewDirectionFromLeft:
            anchorPoint = CGPointMake(0.0f, 0.5f);
            break;
            
        case KBFoldingViewDirectionFromTop:
            anchorPoint = CGPointMake(0.5f, 0.0f);
            break;
            
        case KBFoldingViewDirectionFromBottom:
            anchorPoint = CGPointMake(0.5f, 1.0f);
            break;
    }
    
    //
    // Grab the snapshot of the image
    //
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewSnapShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsGetCurrentContext();
    
    //
    // Set 3D Depth
    //
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0f / 800.0f;
    CALayer *foldingLayer = [CALayer layer];
    foldingLayer.frame = view.bounds;
    foldingLayer.backgroundColor = backgroundColor.CGColor;
    foldingLayer.sublayerTransform = transform;
    [view.layer addSublayer:foldingLayer];
    
    //
    // Set up rotating angle
    //
    double startAngle = 0.0f;
    CALayer *prevLayer = foldingLayer;
    CGFloat frameWidth = view.bounds.size.width;
    CGFloat frameHeight = view.bounds.size.height;
    CGFloat foldWidth = 0.0f;
    CGRect imageFrame = CGRectZero;
    switch (direction) {
        case KBFoldingViewDirectionFromRight:
            foldWidth = frameWidth / (folds * 2.0f);
            
            for (int b = 0; b < 2 * folds; ++b) {
                if (b == 0) {
                    startAngle = -M_PI_2;
                } else if (b % 2) {
                    startAngle = M_PI;
                } else {              startAngle = -M_PI; }
                
                imageFrame = CGRectMake(frameWidth - (b + 1) * foldWidth, 0, foldWidth, frameHeight);
                
                CATransformLayer *transLayer = [UIView transformLayerfromImage:viewSnapShot
                                                                         frame:imageFrame
                                                                      duration:duration
                                                                   anchorPoint:anchorPoint
                                                                    startAngle:startAngle
                                                                      endAngle:0];
                [prevLayer addSublayer:transLayer];
                prevLayer = transLayer;
            }
            
            break;
            
        case KBFoldingViewDirectionFromLeft:
            foldWidth = frameWidth / (folds * 2.0f);
            
            for (int b = 0; b < 2 * folds; ++b) {
                if (b == 0) {
                    startAngle = M_PI_2;
                } else if (b % 2) {
                    startAngle = -M_PI;
                } else {              startAngle = M_PI; }
                
                imageFrame = CGRectMake(b * foldWidth, 0, foldWidth, frameHeight);
                
                CATransformLayer *transLayer = [UIView transformLayerfromImage:viewSnapShot
                                                                         frame:imageFrame
                                                                      duration:duration
                                                                   anchorPoint:anchorPoint
                                                                    startAngle:startAngle
                                                                      endAngle:0];
                [prevLayer addSublayer:transLayer];
                prevLayer = transLayer;
            }
            
            break;
            
        case KBFoldingViewDirectionFromTop:
            foldWidth = frameHeight / (folds * 2.0f);
            
            for (int b = 0; b < 2 * folds; ++b) {
                if (b == 0) {
                    startAngle = -M_PI_2;
                } else if (b % 2) {
                    startAngle = M_PI;
                } else {              startAngle = -M_PI; }
                
                imageFrame = CGRectMake(0, b * foldWidth, frameWidth, foldWidth);
                
                CATransformLayer *transLayer = [UIView transformLayerfromImage:viewSnapShot
                                                                         frame:imageFrame
                                                                      duration:duration
                                                                   anchorPoint:anchorPoint
                                                                    startAngle:startAngle
                                                                      endAngle:0];
                [prevLayer addSublayer:transLayer];
                prevLayer = transLayer;
            }
            
            break;
            
        case KBFoldingViewDirectionFromBottom:
            foldWidth = frameHeight / (folds * 2.0f);
            
            for (int b = 0; b < 2 * folds; ++b) {
                if (b == 0) {
                    startAngle = M_PI_2;
                } else if (b % 2) {
                    startAngle = -M_PI;
                } else {              startAngle = M_PI; }
                
                imageFrame = CGRectMake(0, frameHeight - (b + 1) * foldWidth, frameWidth, foldWidth);
                
                CATransformLayer *transLayer = [UIView transformLayerfromImage:viewSnapShot
                                                                         frame:imageFrame
                                                                      duration:duration
                                                                   anchorPoint:anchorPoint
                                                                    startAngle:startAngle
                                                                      endAngle:0];
                [prevLayer addSublayer:transLayer];
                prevLayer = transLayer;
            }
            
            break;
    }
    
    //
    // Construct and Commit the Open Animation
    //
    [CATransaction begin];
    [CATransaction setCompletionBlock: ^{
        [foldingLayer removeFromSuperlayer];
        
        // Reset the transition state
        _KBTransitionState = KBFoldingTransitionStateShowing;
        
        if (onCompletion) {
            onCompletion(YES);
        }
    }];
    
    [CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
    
    CAAnimation *openAnimation = nil;
    switch (direction) {
        case KBFoldingViewDirectionFromRight:
        case KBFoldingViewDirectionFromLeft:
            openAnimation = [CAKeyframeAnimation parametrizedAnimationWithKeyPath:@"position.x"
                                                                         function:kbOpenFunction
                                                                        fromValue:self.layer.position.x
                                                                          toValue:self.layer.position.x];
            break;
            
        case KBFoldingViewDirectionFromTop:
        case KBFoldingViewDirectionFromBottom:
            openAnimation = [CAKeyframeAnimation parametrizedAnimationWithKeyPath:@"position.y"
                                                                         function:kbOpenFunction
                                                                        fromValue:self.layer.position.y
                                                                          toValue:self.layer.position.y];
            break;
    }
    openAnimation.fillMode = kCAFillModeForwards;
    openAnimation.removedOnCompletion = NO;
    [self.layer addAnimation:openAnimation forKey:@"position"];
    
    [CATransaction commit];
}

#pragma mark -
#pragma mark Hide Methods

- (void)hideFoldingView:(UIView *)view
        backgroundColor:(UIColor *)backgroundColor
                  folds:(NSUInteger)folds
              direction:(NSUInteger)direction
               duration:(NSTimeInterval)duration
           onCompletion:(void (^)(BOOL finished))onCompletion {
    //
    // Guard the Method Invocation
    //
#ifdef kbFoldingViewUseBoundsChecking
    
    if (![self validateDuration:duration direction:direction folds:folds]) {
        return;
    }
    
#endif
    
    if (self.state != KBFoldingTransitionStateShowing) {
        return;
    }
    
    _KBTransitionState = KBFoldingTransitionStateUpdate;
    
    //
    // Configure the Target Frame
    //
    CGPoint anchorPoint = CGPointZero;
    switch (direction) {
        case KBFoldingViewDirectionFromRight:
            anchorPoint = CGPointMake(1.0f, 0.5f);
            break;
            
        case KBFoldingViewDirectionFromLeft:
            anchorPoint = CGPointMake(0.0f, 0.5f);
            break;
            
        case KBFoldingViewDirectionFromTop:
            anchorPoint = CGPointMake(0.5f, 0.0f);
            break;
            
        case KBFoldingViewDirectionFromBottom:
            anchorPoint = CGPointMake(0.5f, 1.0f);
            break;
    }
    
    //
    // Capture a snapshot of the image
    //
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewSnapShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //
    // Configure 3D Path
    //
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0 / 800.0f;
    CALayer *foldingLayer = [CALayer layer];
    foldingLayer.frame = view.bounds;
    foldingLayer.backgroundColor = backgroundColor.CGColor;
    foldingLayer.sublayerTransform = transform;
    [view.layer addSublayer:foldingLayer];
    
    //
    // Setup rotation angle
    //
    double endAngle = 0.0f;
    CGFloat foldWidth = 0.0f;
    CGFloat frameWidth = view.bounds.size.width;
    CGFloat frameHeight = view.bounds.size.height;
    CALayer *prevLayer = foldingLayer;
    CGRect imageFrame;
    switch (direction) {
        case KBFoldingViewDirectionFromRight:
            foldWidth = frameWidth / (folds * 2.0f);
            
            for (int b = 0; b < 2 * folds; ++b) {
                if (b == 0) {
                    endAngle = -M_PI_2;
                } else if (b % 2) {
                    endAngle = M_PI;
                } else {          endAngle = -M_PI; }
                
                imageFrame = CGRectMake(frameWidth - (b + 1) * foldWidth, 0.0f, foldWidth, frameHeight);
                
                CATransformLayer *transLayer = [UIView transformLayerfromImage:viewSnapShot
                                                                         frame:imageFrame
                                                                      duration:duration
                                                                   anchorPoint:anchorPoint
                                                                    startAngle:0.0f
                                                                      endAngle:endAngle];
                [prevLayer addSublayer:transLayer];
                prevLayer = transLayer;
            }
            
            break;
            
        case KBFoldingViewDirectionFromLeft:
            foldWidth = frameWidth / (folds * 2.0f);
            
            for (int b = 0; b < 2 * folds; ++b) {
                if (b == 0) {
                    endAngle = M_PI_2;
                } else if (b % 2) {
                    endAngle = -M_PI;
                } else {          endAngle = M_PI; }
                
                imageFrame = CGRectMake(b * foldWidth, 0.0f, foldWidth, frameHeight);
                
                CATransformLayer *transLayer = [UIView transformLayerfromImage:viewSnapShot
                                                                         frame:imageFrame
                                                                      duration:duration
                                                                   anchorPoint:anchorPoint
                                                                    startAngle:0.0f
                                                                      endAngle:endAngle];
                [prevLayer addSublayer:transLayer];
                prevLayer = transLayer;
            }
            
            break;
            
        case KBFoldingViewDirectionFromTop:
            foldWidth = frameHeight / (folds * 2.0f);
            
            for (int b = 0; b < 2 * folds; ++b) {
                if (b == 0) {
                    endAngle = -M_PI_2;
                } else if (b % 2) {
                    endAngle = M_PI;
                } else {          endAngle = -M_PI; }
                
                imageFrame = CGRectMake(0.0f, b * foldWidth, frameWidth, foldWidth);
                
                CATransformLayer *transLayer = [UIView transformLayerfromImage:viewSnapShot
                                                                         frame:imageFrame
                                                                      duration:duration
                                                                   anchorPoint:anchorPoint
                                                                    startAngle:0.0f
                                                                      endAngle:endAngle];
                [prevLayer addSublayer:transLayer];
                prevLayer = transLayer;
            }
            
            break;
            
        case KBFoldingViewDirectionFromBottom:
            foldWidth = frameHeight / (folds * 2.0f);
            
            for (int b = 0; b < 2 * folds; ++b) {
                if (b == 0) {
                    endAngle = M_PI_2;
                } else if (b % 2) {
                    endAngle = -M_PI;
                } else {          endAngle = M_PI; }
                
                imageFrame = CGRectMake(0.0f, frameHeight - (b + 1) * foldWidth, frameWidth, foldWidth);
                
                CATransformLayer *transLayer = [UIView transformLayerfromImage:viewSnapShot
                                                                         frame:imageFrame
                                                                      duration:duration
                                                                   anchorPoint:anchorPoint
                                                                    startAngle:0.0f
                                                                      endAngle:endAngle];
                [prevLayer addSublayer:transLayer];
                prevLayer = transLayer;
            }
            
            break;
    }
    
    //
    // Construct and Commit the Close Animation
    //
    [CATransaction begin];
    [CATransaction setCompletionBlock: ^{
        [foldingLayer removeFromSuperlayer];
        _KBTransitionState = KBFoldingTransitionStateIdle;
        
        // Reset the transition state
        _KBTransitionState = KBFoldingTransitionStateIdle;
        
        if (onCompletion) {
            onCompletion(YES);
        }
    }];
    
    [CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
    
    CAAnimation *closeAnimation = nil;
    switch (direction) {
        case KBFoldingViewDirectionFromRight:
        case KBFoldingViewDirectionFromLeft:
            closeAnimation = [CAKeyframeAnimation parametrizedAnimationWithKeyPath:@"position.x"
                                                                          function:kbCloseFunction
                                                                         fromValue:self.layer.position.x
                                                                           toValue:self.layer.position.x];
            break;
            
        case KBFoldingViewDirectionFromTop:
        case KBFoldingViewDirectionFromBottom:
            closeAnimation = [CAKeyframeAnimation parametrizedAnimationWithKeyPath:@"position.y"
                                                                          function:kbCloseFunction
                                                                         fromValue:self.layer.position.y
                                                                           toValue:self.layer.position.y];
            break;
    }
    closeAnimation.fillMode = kCAFillModeForwards;
    closeAnimation.removedOnCompletion = NO;
    [self.layer addAnimation:closeAnimation forKey:@"position"];
    [CATransaction commit];
}

#pragma mark -
#pragma mark Validation Method

- (BOOL)validateDuration:(NSTimeInterval)duration direction:(NSUInteger)direction folds:(NSUInteger)folds; {
    if (!(direction == KBFoldingViewDirectionFromRight ||
          direction == KBFoldingViewDirectionFromLeft ||
          direction == KBFoldingViewDirectionFromTop ||
          direction == KBFoldingViewDirectionFromBottom)) {
        NSLog(@"[KBFoldingView] -- Error -- Invalid direction: %d", direction);
        return NO;
    }
    
    if (folds < kbFoldingViewMinFolds || folds > kbFoldingViewMaxFolds) {
        NSLog(@"[KBFoldingView] -- Error -- Number of folds must be between %d and %d", kbFoldingViewMinFolds, kbFoldingViewMaxFolds);
        return NO;
    }
    
    if (duration < kbFoldingViewMinDuration || duration > kbFoldingViewMaxDuration) {
        NSLog(@"[KBFoldingView] -- Error -- Duration must be between %f and %f", kbFoldingViewMinDuration, kbFoldingViewMaxDuration);
        return NO;
    }
    
    return YES;
}

@end
