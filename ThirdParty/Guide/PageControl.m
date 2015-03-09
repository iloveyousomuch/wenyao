//
//  PageControl.m
//  quanzhi
//
//  Created by ZhongYun on 14-1-28.
//  Copyright (c) 2014年 ZhongYun. All rights reserved.
//

#import "PageControl.h"
#import "Constant.h"


@implementation PageControl

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    NSUInteger count = [self.subviews count];
    
    for (int i = 0; i < count; i++) {
        UIImageView* dot = [self.subviews objectAtIndex:i];
        [self setDoc:dot IsActive:(i==0)];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage{
    [super setCurrentPage:currentPage];
    [self updateDots];
}

- (void)updateDots{
    for (int i = 0; i < [self.subviews count]; i++)
    {
        UIImageView* dot = [self.subviews objectAtIndex:i];
        [self setDoc:dot IsActive:(i==self.currentPage)];
    }
    
    //hide the badge
}

- (void)setDoc:(UIImageView*)dot IsActive:(BOOL)actived
{
    if (iOSv7) {
        dot.backgroundColor = (actived ? self.activeColor:self.commonColor);
    } else {
        dot.image = (actived ? self.activeImage:self.commonImage);
    }
}
@end
