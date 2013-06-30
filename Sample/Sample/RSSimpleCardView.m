//
//  RSSimpleCardView.m
//  Sample
//
//  Created by R0CKSTAR on 6/30/13.
//  Copyright (c) 2013 P.D.Q. All rights reserved.
//

#import "RSSimpleCardView.h"

@interface RSSimpleCardView ()
{
    UILabel *_textLabel;
}

@end

@implementation RSSimpleCardView

- (void)setText:(NSString *)text {
    if (!_textLabel) {
        _textLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 5, _contentView.bounds.size.width - 5 * 2, _contentView.bounds.size.height - 5 * 2)] autorelease];
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.numberOfLines = 4;
        _textLabel.font = [UIFont systemFontOfSize:16];
        [_contentView addSubview:_textLabel];
    }
    
    _textLabel.text = text;
}

@end
