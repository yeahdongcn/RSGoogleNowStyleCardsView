//
//  RSViewController.m
//  Sample
//
//  Created by R0CKSTAR on 6/30/13.
//  Copyright (c) 2013 P.D.Q. All rights reserved.
//

#import "RSViewController.h"
#import "RSSimpleCard.h"
#import "RSSimpleCardView.h"
#import "RSCardsView.h"

@interface RSProfileCard : RSSimpleCard
@end
@implementation RSProfileCard

+ (CGFloat)contentHeight {
    return 80;
}

@end

@interface RSProjectCard : RSSimpleCard
@end
@implementation RSProjectCard
@end

@interface RSProfileCardView : RSSimpleCardView
@end
@implementation RSProfileCardView
@end

@interface RSProjectCardView : RSSimpleCardView
@end
@implementation RSProjectCardView
@end

@interface RSViewController () <RSCardsViewDataSource, RSCardsViewDelegate>
{
    NSMutableArray *_data;
}

@end

@implementation RSViewController

#pragma mark -

- (NSMutableArray *)data {
    if (!_data) {
        NSMutableArray *profiles = [NSMutableArray arrayWithObjects:
                                    [[[RSProfileCard alloc] initWithText:nil] autorelease],
                                    [[[RSProfileCard alloc] initWithText:nil] autorelease],
                                    [[[RSProfileCard alloc] initWithText:nil] autorelease], nil];
        NSMutableArray *projects = [NSMutableArray arrayWithObjects:
                                    [[[RSProjectCard alloc] initWithText:nil] autorelease],
                                    [[[RSProjectCard alloc] initWithText:nil] autorelease],
                                    [[[RSProjectCard alloc] initWithText:nil] autorelease],
                                    [[[RSProjectCard alloc] initWithText:nil] autorelease], nil];
        _data = [[NSMutableArray arrayWithObjects:profiles, projects, nil] retain];
    }
    
    return _data;
}

#pragma mark -

- (void)loadView {
    RSCardsView *view = [[[RSCardsView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    view.delegate = self;
    view.dataSource = self;
    view.animationStyle = RSCardsViewAnimationStyleExchange;
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    if (0) {
        [(RSCardsView *)self.view setNeedsReload];
    } else {
        for (int i = 0; i < [[self data] count]; i++) {
            for (int j = 0; j < [[self data][i] count]; j++) {
                RSSimpleCardView *cardView = nil;
                
                if (i == 0) {
                    cardView = [[[RSProfileCardView alloc] initWithFrame:self.view.bounds] autorelease];
                } else {
                    cardView = [[[RSProjectCardView alloc] initWithFrame:self.view.bounds] autorelease];
                }
                
                RSSimpleCard *card = [self data][i][j];
                cardView.delegate = (RSCardsView *)self.view;
                [cardView setText:[card text]];
                [cardView setContentViewHeight:[[card class] contentHeight] animated:NO];
                [cardView setSettingsViewHeight:[[card class] settingsHeight]];
                [cardView setNeedsLayout];
                
                [(RSCardsView *)self.view insertCard : cardView];
            }
        }
        
        id o = [self data][0];
        [o retain];
        [[self data] removeObjectAtIndex:0];
        [[self data] addObject:o];
        [o release];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_data removeAllObjects];
    [_data release];
    [super dealloc];
}

#pragma mark - RSCardsViewDataSource

- (NSInteger)numberOfSectionsInCardsView:(RSCardsView *)cardsView {
    return [[self data] count];
}

- (NSInteger)cardsView:(RSCardsView *)cardsView numberOfRowsInSection:(NSInteger)section {
    return [[self data][section] count];
}

- (RSCardView *)cardsView:(RSCardsView *)cardsView cardForRowAtIndexPath:(NSIndexPath *)indexPath {
    RSSimpleCardView *cardView = [[[RSSimpleCardView alloc] initWithFrame:self.view.bounds] autorelease];
    
    RSSimpleCard *card = [self data][[indexPath section]][[indexPath row]];
    
    cardView.delegate = cardsView;
    [cardView setText:[card text]];
    [cardView setContentViewHeight:[[card class] contentHeight] animated:NO];
    [cardView setSettingsViewHeight:[[card class] settingsHeight]];
    [cardView setNeedsLayout];
    
    return cardView;
}

#pragma mark - RSCardsViewDelegate

- (CGFloat)heightForHeaderInCardsView:(RSCardsView *)cardsView {
    return 10;
}

- (CGFloat)heightForFooterInCardsView:(RSCardsView *)cardsView {
    return 10;
}

- (CGFloat)heightForSeparatorInCardsView:(RSCardsView *)cardsView {
    return 5;
}

- (CGFloat)heightForCoveredRowInCardsView:(RSCardsView *)cardsView {
    return 60;
}

- (void)cardViewDidRemoveAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *section = [self data][indexPath.section];
    
    [section removeObjectAtIndex:indexPath.row];
    
    if (section.count <= 0) {
        [[self data] removeObjectAtIndex:indexPath.section];
    }
}

// Exchange animation callback
- (void)cardViewWillExchangeAtIndexPath:(NSIndexPath *)indexPath withIndexPath:(NSIndexPath *)otherIndexPath {
}

- (void)cardViewDidExchangeAtIndexPath:(NSIndexPath *)indexPath withIndexPath:(NSIndexPath *)otherIndexPath {
    if (indexPath.section == otherIndexPath.section) {
        NSMutableArray *section = [self data][indexPath.section];
        [section exchangeObjectAtIndex:indexPath.row withObjectAtIndex:otherIndexPath.row];
    }
}

// Drop animation callback
- (void)cardViewWillDropAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)cardViewDidDropAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *section = [self data][indexPath.section];
    id object = [section[indexPath.row] retain];
    
    [section removeObjectAtIndex:indexPath.row];
    [section addObject:object];
    [object release];
}

@end
