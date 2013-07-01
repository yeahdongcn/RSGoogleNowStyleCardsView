//
//  RSCard.m
//  Google Now Style Card View
//
//  Created by R0CKSTAR on 5/21/13.
//  Copyright (c) 2013 P.D.Q. All rights reserved.
//

#import "RSCard.h"

@implementation RSCard

+ (BOOL)isUserLocationRequired {
    return NO;
}

+ (BOOL)shouldInsertInSection {
    return YES;
}

+ (CGFloat)contentHeight {
    return 0;
}

+ (CGFloat)settingsHeight {
    return 0;
}

@end
