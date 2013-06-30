//
//  RSCard.h
//  Google Now Style Card View
//
//  Created by R0CKSTAR on 5/21/13.
//  Copyright (c) 2013 P.D.Q. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSCard : NSObject

// Override these functions to customize

+ (BOOL)isUserLocationRequired;

+ (BOOL)shouldInsertInSection;

+ (CGFloat)contentHeight;

+ (CGFloat)settingsHeight;

@end
