//
//  RSCardsView.m
//  Google Now Style Card View
//
//  Created by R0CKSTAR on 5/21/13.
//  Copyright (c) 2013 P.D.Q. All rights reserved.
//

#import "RSCardsView.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kRSExchangeAnimationScaleZoomIn  = 1.01;
static CGFloat const kRSExchangeAnimationScaleZoomOut = 0.99;
static CGFloat const kRSDropAnimationScaleZoomOut     = 0.98;
static NSTimeInterval const kRSAnimationDuration      = 0.35;

@interface RSCardsView () {
    BOOL _isReloading;
    BOOL _isInserting;
    
    NSMutableArray *_indexPaths;
    NSMutableArray *_insertQueue;
}

@end

@implementation RSCardsView

static const int kTagBase = NSIntegerMax / 10 * 10;
static const int kSectionSpan = 100;

@synthesize delegate = __delegate;
@synthesize dataSource = __dataSource;

#pragma mark - Private: getters

- (NSMutableArray *)insertQueue {
    if (!_insertQueue) {
        _insertQueue = [[NSMutableArray alloc] init];
    }
    
    return _insertQueue;
}

- (NSMutableArray *)indexPaths {
    if (!_indexPaths) {
        _indexPaths = [[NSMutableArray alloc] init];
    }
    
    return _indexPaths;
}

#pragma mark - Private: insert queued card

- (void)insertQueuedCard {
    if ([self insertQueue].count > 0) {
        [self insertCard:[self insertQueue][0]];
        [[self insertQueue] removeObjectAtIndex:0];
    }
}

#pragma mark - Private: card <-> index path

- (int)rowForCard:(RSCardView *)card {
    return (card.tag - kTagBase) % kSectionSpan;
}

- (int)sectionForCard:(RSCardView *)card {
    return (card.tag - kTagBase) / kSectionSpan;
}

- (NSIndexPath *)indexPathForCard:(RSCardView *)card {
    return [NSIndexPath indexPathForRow:[self rowForCard:card] inSection:[self sectionForCard:card]];
}

- (RSCardView *)cardForIndexPath:(NSIndexPath *)indexPath {
    RSCardView *card = (RSCardView *)[self viewWithTag:kTagBase + kSectionSpan * indexPath.section + indexPath.row];
    
    if (!card && __dataSource && [__dataSource respondsToSelector:@selector(cardsView:cardForRowAtIndexPath:)]) {
        card = [__dataSource cardsView:self cardForRowAtIndexPath:indexPath];
        card.tag = kTagBase + kSectionSpan * indexPath.section + indexPath.row;
    }
    
    return card;
}

#pragma mark - Private: manipulate local data

- (int)lastSection {
    return [[self indexPaths] count] - 1;
}

- (int)lastRowInSection:(int)section {
    return [[self indexPaths][section] count] - 1;
}

- (void)layout {
    if (!_indexPaths) {
        return;
    }
    
    CGFloat y = 0;
    
    if (__delegate && [__delegate respondsToSelector:@selector(heightForHeaderInCardsView:)]) {
        y += [__delegate heightForHeaderInCardsView:self];
    }
    
    CGFloat sectionOffset = 0;
    
    if (__delegate && [__delegate respondsToSelector:@selector(heightForSeparatorInCardsView:)]) {
        sectionOffset = [__delegate heightForSeparatorInCardsView:self];
    }
    
    CGFloat rowOffset = 0;
    
    if (__delegate && [__delegate respondsToSelector:@selector(heightForCoveredRowInCardsView:)]) {
        rowOffset = [__delegate heightForCoveredRowInCardsView:self];
    }
    
    for (int section = 0; section <= [self lastSection]; section++) {
        for (int row = 0; row <= [self lastRowInSection:section]; row++) {
            RSCardView *c = [self cardForIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
            CGRect frame = c.frame;
            frame.origin.y = y;
            c.frame = frame;
            
            if (row == [self lastRowInSection:section]) {
                y += frame.size.height;
            } else {
                y += rowOffset;
            }
        }
        
        if (section != [self lastSection]) {
            y += sectionOffset;
        }
    }
    
    if (__delegate && [__delegate respondsToSelector:@selector(heightForFooterInCardsView:)]) {
        y += [__delegate heightForFooterInCardsView:self];
    }
    
    self.contentSize = CGSizeMake(self.contentSize.width, y);
}

#pragma mark - Private: manipulate data from data source

- (int)dsLastSection {
    return [self dsSections] - 1;
}

- (int)dsLastRowInSection:(int)section {
    return [self dsLastRowInSection:section] - 1;
}

- (int)dsSections {
    if (__dataSource && [__dataSource respondsToSelector:@selector(numberOfSectionsInCardsView:)]) {
        return [__dataSource numberOfSectionsInCardsView:self];
    }
    
    return 1;
}

- (int)dsRowsInSection:(int)section {
    if (__dataSource && [__dataSource respondsToSelector:@selector(cardsView:numberOfRowsInSection:)]) {
        return [__dataSource cardsView:self numberOfRowsInSection:section];
    }
    
    return 0;
}

- (void)dsReload {
    for (UIView *view in [self subviews]) {
        if ([view isKindOfClass:[RSCardView class]]) {
            [view removeFromSuperview];
        }
    }
    
    if (_indexPaths) {
        [_indexPaths removeAllObjects];
    }
    
    for (int section = 0; section < [self dsSections]; section++) {
        int numberOfRows = [self dsRowsInSection:section];
        
        if (numberOfRows > 0) {
            NSMutableArray *rows = [NSMutableArray arrayWithCapacity:numberOfRows];
            
            for (int row = 0; row < numberOfRows; row++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                [rows addObject:indexPath];
                RSCardView *card = [self cardForIndexPath:indexPath];
                
                if (card) {
                    [self addSubview:card];
                }
            }
            
            [[self indexPaths] addObject:rows];
        }
    }
}

- (void)dsLayout {
    if (!__dataSource || !_indexPaths) {
        return;
    }
    
    CGFloat y = 0;
    
    if (__delegate && [__delegate respondsToSelector:@selector(heightForHeaderInCardsView:)]) {
        y += [__delegate heightForHeaderInCardsView:self];
    }
    
    CGFloat sectionOffset = 0;
    
    if (__delegate && [__delegate respondsToSelector:@selector(heightForSeparatorInCardsView:)]) {
        sectionOffset = [__delegate heightForSeparatorInCardsView:self];
    }
    
    CGFloat rowOffset = 0;
    
    if (__delegate && [__delegate respondsToSelector:@selector(heightForCoveredRowInCardsView:)]) {
        rowOffset = [__delegate heightForCoveredRowInCardsView:self];
    }
    
    for (int section = 0; section < [self dsSections]; section++) {
        for (int row = 0; row < [self dsRowsInSection:section]; row++) {
            RSCardView *card = [self cardForIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
            CGRect frame = card.frame;
            frame.origin.y = y;
            card.frame = frame;
            
            if (row == ([__dataSource cardsView:self numberOfRowsInSection:section] - 1)) {
                y += frame.size.height;
            } else {
                y += rowOffset;
            }
        }
        
        if (section != [self dsLastSection]) {
            y += sectionOffset;
        }
    }
    
    if (__delegate && [__delegate respondsToSelector:@selector(heightForFooterInCardsView:)]) {
        y += [__delegate heightForFooterInCardsView:self];
    }
    
    self.contentSize = CGSizeMake(self.contentSize.width, y);
}

- (void)reloadData {
    [self setUserInteractionEnabled:NO];
    
    [self dsReload];
    [self dsLayout];
    
    _isReloading = NO;
    _isInserting = NO;
    
    [self insertQueuedCard];
    
    [self setUserInteractionEnabled:YES];
}

#pragma mark - Private : animation related

- (void)sortZPositionInSection:(int)section shouldReset:(BOOL)shouldReset {
    for (int row = 0; row <= [self lastRowInSection:section]; row++) {
        RSCardView *card = [self cardForIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        card.layer.zPosition = shouldReset ? 0 : row;
    }
}

- (void)foldInSection:(int)section {
    for (int row = 0; row <= [self lastRowInSection:section]; row++) {
        RSCardView *card = [self cardForIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        
        if ([card isSettingsVisible]) {
            [card toggleSettings];
        }
    }
}

- (void)animationWillStart:(RSCardView *)card {
    [self setUserInteractionEnabled:NO];
    
    int section = [self sectionForCard:card];
    [self foldInSection:section];
    
    if (_animationStyle == RSCardsViewAnimationStyleExchange) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cardViewWillExchangeAtIndexPath:withIndexPath:)]) {
            [self.delegate
             cardViewWillExchangeAtIndexPath:[self indexPathForCard:card]
             withIndexPath:[NSIndexPath indexPathForRow:[self lastRowInSection:section]
                                              inSection:section]];
        }
        
        [self exchangeAnimationScale:card];
    } else if (_animationStyle == RSCardsViewAnimationStyleDrop) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cardViewWillDropAtIndexPath:)]) {
            [self.delegate cardViewWillDropAtIndexPath:[self indexPathForCard:card]];
        }
        
        [self dropAnimationScale:card];
    }
}

- (void)animationDidFinish:(RSCardView *)card {
    if (_animationStyle == RSCardsViewAnimationStyleExchange) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cardViewDidExchangeAtIndexPath:withIndexPath:)]) {
            int section = [self sectionForCard:card];
            [self.delegate
             cardViewDidExchangeAtIndexPath:[self indexPathForCard:card]
             withIndexPath:[NSIndexPath indexPathForRow:[self lastRowInSection:section]
                                              inSection:section]];
        }
    } else if (_animationStyle == RSCardsViewAnimationStyleDrop) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cardViewDidDropAtIndexPath:)]) {
            [self.delegate cardViewDidDropAtIndexPath:[self indexPathForCard:card]];
        }
    }
    
    [self setUserInteractionEnabled:YES];
}

#pragma mark - Private : drop animation

- (void)dropAnimationScale:(RSCardView *)card {
    card.layer.zPosition = 1;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(kRSDropAnimationScaleZoomOut, kRSDropAnimationScaleZoomOut, 1.0)];
    animation.fillMode = kCAFillModeForwards;
    animation.duration = kRSAnimationDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    card.layer.transform = CATransform3DMakeScale(kRSDropAnimationScaleZoomOut, kRSDropAnimationScaleZoomOut, 1.0);
    [card.layer addAnimation:animation forKey:@"scale"];
    
    [self performSelector:@selector(dropAnimationMove:) withObject:card afterDelay:kRSAnimationDuration];
}

- (void)dropAnimationMove:(RSCardView *)card {
    int section = [self sectionForCard:card];
    RSCardView *lastCard = [self cardForIndexPath:[NSIndexPath indexPathForRow:[self lastRowInSection:section] inSection:section]];
    
    CGPoint lastPosition = CGPointMake(lastCard.layer.position.x, lastCard.layer.position.y - lastCard.layer.bounds.size.height / 2.f + card.layer.bounds.size.height / 2.f);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    animation.fromValue = [card.layer valueForKey:@"position"];
    animation.toValue = [NSValue valueWithCGPoint:lastPosition];
    animation.duration = kRSAnimationDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    card.layer.position = lastPosition;
    [card.layer addAnimation:animation forKey:@"position"];
    
    CGFloat offsetRow = 0;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(heightForCoveredRowInCardsView:)]) {
        offsetRow = [self.delegate heightForCoveredRowInCardsView:self];
    }
    
    for (int row = [self rowForCard:card] + 1; row <= [self lastRowInSection:section]; row++) {
        RSCardView *c = [self cardForIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        CGPoint position = c.layer.position;
        position.y -= offsetRow;
        animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.fromValue = [c.layer valueForKey:@"position"];
        animation.toValue = [NSValue valueWithCGPoint:position];
        animation.duration = kRSAnimationDuration;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        c.layer.position = position;
        [c.layer addAnimation:animation forKey:@"position"];
    }
    
    [self performSelector:@selector(dropAnimationScaleBack:) withObject:card afterDelay:kRSAnimationDuration];
}

- (void)dropAnimationScaleBack:(RSCardView *)card {
    [self bringSubviewToFront:card];
    
    card.layer.zPosition = 0;
    
    int section = [self sectionForCard:card];
    RSCardView *lastCard = [self cardForIndexPath:[NSIndexPath indexPathForRow:[self lastRowInSection:section] inSection:section]];
    int tag = lastCard.tag;
    
    RSCardView *firstCard = nil;
    
    for (int row = [self rowForCard:card] + 1; row <= [self lastRowInSection:section]; row++) {
        RSCardView *c = [self cardForIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        
        if (!firstCard) {
            firstCard = c;
        }
        
        c.tag -= 1;
    }
    
    card.tag = tag;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(kRSDropAnimationScaleZoomOut, kRSDropAnimationScaleZoomOut, 1.0)];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.fillMode = kCAFillModeForwards;
    animation.duration = kRSAnimationDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    card.layer.transform = CATransform3DIdentity;
    [card.layer addAnimation:animation forKey:@"scale"];
    
    if (card.shouldOpenSettingsLater) {
        [card toggleSettings];
        card.shouldOpenSettingsLater = NO;
    }
    
    [self performSelector:@selector(animationDidFinish:) withObject:firstCard afterDelay:kRSAnimationDuration];
}

#pragma mark - Private : exchange animation

- (void)exchangeAnimationScale:(RSCardView *)card {
    int section = [self sectionForCard:card];
    
    [self sortZPositionInSection:section shouldReset:NO];
    
    RSCardView *lastCard = [self cardForIndexPath:[NSIndexPath indexPathForRow:[self lastRowInSection:section] inSection:section]];
    int zPosition = lastCard.layer.zPosition;
    lastCard.layer.zPosition = card.layer.zPosition;
    card.layer.zPosition = zPosition;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(kRSExchangeAnimationScaleZoomOut, kRSExchangeAnimationScaleZoomOut, 1.0)];
    animation.fillMode = kCAFillModeForwards;
    animation.duration = kRSAnimationDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    card.layer.transform = CATransform3DMakeScale(kRSExchangeAnimationScaleZoomOut, kRSExchangeAnimationScaleZoomOut, 1.0);
    [card.layer addAnimation:animation forKey:@"scale"];
    
    animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(kRSExchangeAnimationScaleZoomIn, kRSExchangeAnimationScaleZoomIn, 1.0)];
    animation.fillMode = kCAFillModeForwards;
    animation.duration = kRSAnimationDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    lastCard.layer.transform = CATransform3DMakeScale(kRSExchangeAnimationScaleZoomIn, kRSExchangeAnimationScaleZoomIn, 1.0);
    [lastCard.layer addAnimation:animation forKey:@"scale"];
    
    [self performSelector:@selector(exchangeAnimationMove:) withObject:card afterDelay:kRSAnimationDuration];
}

- (void)exchangeAnimationMove:(RSCardView *)card {
    int section = [self sectionForCard:card];
    RSCardView *lastCard = [self cardForIndexPath:[NSIndexPath indexPathForRow:[self lastRowInSection:section] inSection:section]];
    
    CGPoint position = CGPointMake(card.layer.position.x, card.layer.position.y - card.layer.bounds.size.height / 2.f + lastCard.layer.bounds.size.height / 2.f);
    CGPoint lastPosition = CGPointMake(lastCard.layer.position.x, lastCard.layer.position.y - lastCard.layer.bounds.size.height / 2.f + card.layer.bounds.size.height / 2.f);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    animation.fromValue = [card.layer valueForKey:@"position"];
    animation.toValue = [NSValue valueWithCGPoint:lastPosition];
    animation.duration = kRSAnimationDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    card.layer.position = lastPosition;
    [card.layer addAnimation:animation forKey:@"position"];
    
    animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [lastCard.layer valueForKey:@"position"];
    animation.toValue = [NSValue valueWithCGPoint:position];
    animation.duration = kRSAnimationDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    lastCard.layer.position = position;
    [lastCard.layer addAnimation:animation forKey:@"position"];
    
    [self performSelector:@selector(exchangeAnimationScaleBack:) withObject:card afterDelay:kRSAnimationDuration];
}

- (void)exchangeAnimationScaleBack:(RSCardView *)card {
    int section = [self sectionForCard:card];
    
    [self sortZPositionInSection:section shouldReset:YES];
    
    RSCardView *lastCard = [self cardForIndexPath:[NSIndexPath indexPathForRow:[self lastRowInSection:section] inSection:section]];
    
    [self exchangeSubviewAtIndex:[self.subviews indexOfObject:card] withSubviewAtIndex:[self.subviews indexOfObject:lastCard]];
    
    NSInteger tag = card.tag;
    card.tag = lastCard.tag;
    lastCard.tag = tag;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(kRSExchangeAnimationScaleZoomOut, kRSExchangeAnimationScaleZoomOut, 1.0)];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.fillMode = kCAFillModeForwards;
    animation.duration = kRSAnimationDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    card.layer.transform = CATransform3DIdentity;
    [card.layer addAnimation:animation forKey:@"scale"];
    
    animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(kRSExchangeAnimationScaleZoomIn, kRSExchangeAnimationScaleZoomIn, 1.0)];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.fillMode = kCAFillModeForwards;
    animation.duration = kRSAnimationDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    lastCard.layer.transform = CATransform3DIdentity;
    [lastCard.layer addAnimation:animation forKey:@"scale"];
    
    if (card.shouldOpenSettingsLater) {
        [card toggleSettings];
        card.shouldOpenSettingsLater = NO;
    }
    
    [self performSelector:@selector(animationDidFinish:) withObject:lastCard afterDelay:kRSAnimationDuration];
}

#pragma mark - UIScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        _indexPaths = [[NSMutableArray alloc] init];
        
        _animationStyle = RSCardsViewAnimationStyleExchange;
    }
    
    return self;
}

- (void)dealloc {
    [_indexPaths removeAllObjects];
    [_indexPaths release];
    [_insertQueue removeAllObjects];
    [_insertQueue release];
    [super dealloc];
}

#pragma mark - Public

- (void)setNeedsReload {
    if (!_isReloading) {
        _isReloading = YES;
        _isInserting = YES;
        __block typeof(self) this = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [this reloadData];
        });
    }
}

- (void)insertCard:(RSCardView *)card {
    if (_isInserting) {
        [[self insertQueue] addObject:card];
        return;
    }
    
    [self setUserInteractionEnabled:NO];
    
    _isInserting = YES;
    
    NSString *cardViewClassName = NSStringFromClass([card class]);
    Class cardClass = NSClassFromString([cardViewClassName substringToIndex:[cardViewClassName rangeOfString:@"View"].location]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
    
    if ([cardClass shouldInsertInSection]) {
#pragma clang diagnostic pop
        
        for (int section = 0; section <= [self lastSection]; section++) {
            for (int row = 0; row <= [self lastRowInSection:section]; row++) {
                RSCardView *c = [self cardForIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                
                if ([card isKindOfClass:[c class]]) {
                    int r = [self lastRowInSection:section] + 1;
                    card.tag = kTagBase + kSectionSpan * section + r;
                    NSIndexPath *ip = [NSIndexPath indexPathForRow:r inSection:section];
                    [[self indexPaths][section] addObject:ip];
                    
                    goto Animation;
                }
            }
        }
    }
    
    for (int section = 0; section <= [self lastSection]; section++) {
        for (int row = 0; row <= [self lastRowInSection:section]; row++) {
            [self cardForIndexPath:[NSIndexPath indexPathForRow:row inSection:section]].tag = kTagBase + kSectionSpan * (section + 1) + row;
            [self indexPaths][section][row] = [NSIndexPath indexPathForRow:row inSection:section + 1];
        }
    }
    
    NSMutableArray *section = [NSMutableArray arrayWithCapacity:1];
    [section addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
    [[self indexPaths] insertObject:section atIndex:0];
    card.tag = kTagBase;
    
Animation:
    
    card.hidden = YES;
    [self addSubview:card];
    
    [UIView animateWithDuration:kRSAnimationDuration
                     animations: ^{
                         [self layout];
                     }
     
                     completion: ^(BOOL finished) {
                         [self setUserInteractionEnabled:YES];
                         card.hidden = NO;
                         [card insertAnimation];
                     }];
}

#pragma mark - RSCardViewDelegate

- (UIColor *)superviewBackgroundColor {
    return self.backgroundColor;
}

- (BOOL)canToggleSettings:(RSCardView *)card {
    int section = [self sectionForCard:card];
    RSCardView *lastCard = [self cardForIndexPath:[NSIndexPath indexPathForRow:[self lastRowInSection:section] inSection:section]];
    
    return lastCard == card;
}

- (void)didTapOnCard:(RSCardView *)card {
    int section = [self sectionForCard:card];
    RSCardView *lastCard = [self cardForIndexPath:[NSIndexPath indexPathForRow:[self lastRowInSection:section] inSection:section]];
    
    if (card != lastCard) {
        [self animationWillStart:card];
    }
}

- (void)didRemoveFromSuperview:(RSCardView *)card {
    [self setUserInteractionEnabled:NO];
    
    NSIndexPath *indexPath = [self indexPathForCard:card];
    
    if (__delegate && [__delegate respondsToSelector:@selector(cardViewDidRemoveAtIndexPath:)]) {
        [__delegate cardViewDidRemoveAtIndexPath:indexPath];
    }
    
    [[self indexPaths][indexPath.section] removeObjectAtIndex:indexPath.row];
    
    int section = [self sectionForCard:card];
    
    if ([self lastRowInSection:section] >= 0) {
        for (int i = [self rowForCard:card]; i <= [self lastRowInSection:section]; i++) {
            NSIndexPath *indexPath = [self indexPaths][section][i];
            [self cardForIndexPath:indexPath].tag -= 1;
            [self indexPaths][section][i] = [NSIndexPath indexPathForRow:[indexPath row] - 1 inSection:[indexPath section]];
        }
    } else {
        [[self indexPaths] removeObjectAtIndex:section];
        
        for (int i = section; i <= [self lastSection]; i++) {
            for (int j = 0; j <= [self lastRowInSection:section]; j++) {
                NSIndexPath *indexPath = [self indexPaths][i][j];
                [self cardForIndexPath:indexPath].tag -= kSectionSpan;
                [self indexPaths][i][j] = [NSIndexPath indexPathForRow:[indexPath row] inSection:[indexPath section] - 1];
            }
        }
    }
    
    [UIView animateWithDuration:kRSAnimationDuration
                     animations: ^{
                         [self layout];
                     }
     
                     completion: ^(BOOL finished) {
                         [self setUserInteractionEnabled:YES];
                     }];
}

- (void)didChangeFrame:(RSCardView *)cardView {
    [self setUserInteractionEnabled:NO];
    
    [UIView animateWithDuration:kRSAnimationDuration
                     animations: ^{
                         [self layout];
                     }
     
                     completion: ^(BOOL finished) {
                         [self setUserInteractionEnabled:YES];
                     }];
}

- (void)insertAnimationDidStart {
    [self setUserInteractionEnabled:NO];
}

- (void)insertAnimationDidStop {
    [self setUserInteractionEnabled:YES];
    
    _isInserting = NO;
    
    [self insertQueuedCard];
}

@end
