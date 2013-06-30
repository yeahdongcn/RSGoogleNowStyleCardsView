//
//  RSCardsView.h
//  Google Now Style Card View
//
//  Created by R0CKSTAR on 5/21/13.
//  Copyright (c) 2013 P.D.Q. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSCardView.h"

@class RSCardsView;

@protocol RSCardsViewDelegate <UIScrollViewDelegate>

@required

- (CGFloat)heightForHeaderInCardsView:(RSCardsView *)cardsView;

- (CGFloat)heightForFooterInCardsView:(RSCardsView *)cardsView;

- (CGFloat)heightForSeparatorInCardsView:(RSCardsView *)cardsView;

- (CGFloat)heightForCoveredRowInCardsView:(RSCardsView *)cardsView;

- (void)cardViewDidRemoveAtIndexPath:(NSIndexPath *)indexPath;

// For exchange animation
- (void)cardViewWillExchangeAtIndexPath:(NSIndexPath *)indexPath withIndexPath:(NSIndexPath *)otherIndexPath;

- (void)cardViewDidExchangeAtIndexPath:(NSIndexPath *)indexPath withIndexPath:(NSIndexPath *)otherIndexPath;

// For drop animation
- (void)cardViewWillDropAtIndexPath:(NSIndexPath *)indexPath;

- (void)cardViewDidDropAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol RSCardsViewDataSource <NSObject>

@required

- (NSInteger)numberOfSectionsInCardsView:(RSCardsView *)cardsView;

- (NSInteger)cardsView:(RSCardsView *)cardsView numberOfRowsInSection:(NSInteger)section;

- (RSCardView *)cardsView:(RSCardsView *)cardsView cardForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

// Animation style enum
typedef NS_ENUM (NSUInteger, RSCardsViewAnimationStyle) {
    RSCardsViewAnimationStyleExchange = 0,
    RSCardsViewAnimationStyleDrop
};

@interface RSCardsView : UIScrollView <RSCardViewDelegate>

@property (nonatomic, assign) id <RSCardsViewDataSource> dataSource;

@property (nonatomic, assign) id <RSCardsViewDelegate> delegate;

@property (nonatomic, assign) RSCardsViewAnimationStyle animationStyle;

- (void)setNeedsReload;

- (void)insertCard:(RSCardView *)card;

@end
