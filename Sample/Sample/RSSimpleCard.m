//
//  RSSimpleCard.m
//  Sample
//
//  Created by R0CKSTAR on 6/30/13.
//  Copyright (c) 2013 P.D.Q. All rights reserved.
//

#import "RSSimpleCard.h"

@interface RSSimpleCard () {
    NSString *_text;
}

@end

@implementation RSSimpleCard

- (id)initWithText:(NSString *)text {
    self = [super init];
    
    if (self) {
        _text = [text retain];
    }
    
    return self;
}

- (void)dealloc {
    [_text release];
    [super dealloc];
}

- (NSString *)text {
    return _text;
}

+ (CGFloat)contentHeight {
    return 100;
}

+ (CGFloat)settingsHeight {
    return 100;
}

@end
