//
//  RSCardView.h
//  Google Now Style Card View
//
//  Created by R0CKSTAR on 5/21/13.
//  Copyright (c) 2013 P.D.Q. All rights reserved.
//

#import <UIKit/UIKit.h>

// Swip direction enum
typedef NS_ENUM (NSUInteger, RSCardViewSwipeDirection) {
    RSCardViewSwipeDirectionLeft = 0,
    RSCardViewSwipeDirectionCenter,
    RSCardViewSwipeDirectionRight
};

@class RSCardView;

@protocol RSCardViewDelegate <NSObject>

@required

- (BOOL)canToggleSettings:(RSCardView *)cardView;

- (void)didRemoveFromSuperview:(RSCardView *)cardView;

- (void)didTapOnCard:(RSCardView *)cardView;

- (void)didChangeFrame:(RSCardView *)cardView;

- (UIColor *)superviewBackgroundColor;

- (void)insertAnimationDidStart;

- (void)insertAnimationDidStop;

@end

@interface RSCardView : UIView {
    UIView *_contentView;
    UIButton *_settingsButton;
    UIView *_settingsView;
}

@property (assign, nonatomic) id <RSCardViewDelegate> delegate;

@property (assign, nonatomic) BOOL shouldOpenSettingsLater;

- (void)setContentViewHeight:(CGFloat)height animated:(BOOL)animated;

- (void)setSettingsViewHeight:(CGFloat)height;

- (BOOL)isSettingsVisible;

- (void)toggleSettings;

- (void)insertAnimation;

@end
