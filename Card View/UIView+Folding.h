#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef double (^KeyframeParametrizedBlock)(NSTimeInterval);

//
// The following constants can be used in case you think its
// useful to exclude nonsense values from being supplied to the
// category. If you want to use the boundary checking, set the
// kbFoldingViewUseBoundsChecking flag to 1, and configure the
// boundary value as you wish. Otherwise, set it to 0.
//
#define kbFoldingViewUseBoundsChecking 1
#define kbFoldingViewMinFolds          1
#define kbFoldingViewMaxFolds          20
#define kbFoldingViewMinDuration       0.2f
#define kbFoldingViewMaxDuration       10.0f

#pragma mark -
#pragma mark CAKeyframeAnimation Category
//
// CAKeyframeAnimation Category
//
@interface CAKeyframeAnimation (Parametrized)

+ (id)parametrizedAnimationWithKeyPath:(NSString *)path
                              function:(KeyframeParametrizedBlock)function
                             fromValue:(CGFloat)fromValue
                               toValue:(CGFloat)toValue;

@end

//
// Animation Constants
//
typedef enum {
    KBFoldingViewDirectionFromRight     = 0,
    KBFoldingViewDirectionFromLeft      = 1,
    KBFoldingViewDirectionFromTop       = 2,
    KBFoldingViewDirectionFromBottom    = 3,
} KBFoldingViewDirection;

typedef enum {
    KBFoldingTransitionStateIdle    = 0,
    KBFoldingTransitionStateUpdate  = 1,
    KBFoldingTransitionStateShowing = 2,
} KBFoldingTransitionState;

#pragma mark -
#pragma mark UIView Category
//
// UIView Category
//
@interface UIView (Folding)

@property (nonatomic, readonly) NSUInteger state;

#pragma mark -
#pragma mark Show Methods

// Fold the view using specified values
- (void)showFoldingView:(UIView *)view
        backgroundColor:(UIColor *)backgroundColor
                  folds:(NSUInteger)folds
              direction:(NSUInteger)direction
               duration:(NSTimeInterval)duration
           onCompletion:(void(^) (BOOL finished))onCompletion;

#pragma mark -
#pragma mark Hide Methods

// Hide the folds using specified values
- (void)hideFoldingView:(UIView *)view
        backgroundColor:(UIColor *)backgroundColor
                  folds:(NSUInteger)folds
              direction:(NSUInteger)direction
               duration:(NSTimeInterval)duration
           onCompletion:(void(^) (BOOL finished))onCompletion;

@end
