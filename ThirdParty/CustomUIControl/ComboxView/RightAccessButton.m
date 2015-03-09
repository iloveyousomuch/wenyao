//
//  RightAccessButton.m
//  quanzhi
//
//  Created by xiezhenghong on 14-6-9.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "RightAccessButton.h"

@implementation RightAccessButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        _customFont = [UIFont systemFontOfSize:15.0];
        self.isToggle = NO;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        _customFont = [UIFont systemFontOfSize:13.5];
        self.titleLabel.font = _customFont;
        self.isToggle = NO;
    }
    return self;
}

- (void)setCustomColor:(UIColor *)customColor
{
    [self setTitleColor:customColor forState:UIControlStateNormal];
}

- (void)setCustomFont:(UIFont *)customFont
{
    _customFont = customFont;

    self.titleLabel.font = customFont;
    [self layoutAccessView];
}

- (void)setAccessIndicate:(UIImageView *)accessIndicate
{
    if(self.accessIndicate)
        [self.accessIndicate removeFromSuperview];
    
    _accessIndicate = accessIndicate;
    [self addSubview:accessIndicate];
    
}

- (void)setButtonTitle:(NSString *)_title
{
    _buttonTitle = _title;
    [self setTitle:_title forState:UIControlStateNormal];
    [self layoutAccessView];
}

- (void)layoutAccessView
{
    if(self.accessIndicate) {
        CGSize size = [_buttonTitle sizeWithFont:self.customFont];
        CGFloat originX = self.frame.size.width / 2 + size.width / 2 + 10;
        CGFloat originY = self.frame.size.height / 2 - self.accessIndicate.frame.size.height / 2;
        self.accessIndicate.frame = CGRectMake(originX, originY, self.accessIndicate.frame.size.width, self.accessIndicate.frame.size.height);
    }
}

- (void)setCustomImage:(UIImage *)image
{
    self.accessIndicate.image = image;
}

- (void)toggleButtonWithAccessView
{
    self.isToggle = !self.isToggle;
    [self changeArrowDirectionUp:self.isToggle];
}

- (void)changeArrowDirectionUp:(BOOL)up
{
    [UIView animateWithDuration:0.3 animations:^{
        if(up){
            self.accessIndicate.transform = CGAffineTransformMakeRotation(M_PI);
        }else{
            self.accessIndicate.transform = CGAffineTransformMakeRotation(0);
        }
    }];
}

@end
