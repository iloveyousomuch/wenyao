//
//  SBTextView.m
//  wenyao
//
//  Created by Meng on 14/12/9.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "SBTextView.h"

@implementation SBTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)init
{
    if (self = [super init]) {
        self.textContainerInset = UIEdgeInsetsZero;
        self.textContainer.lineFragmentPadding = 0;
        self.scrollEnabled = NO;
        self.editable = NO;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.textContainerInset = UIEdgeInsetsZero;
        self.textContainer.lineFragmentPadding = 0;
        self.scrollEnabled = NO;
        self.editable = NO;
    }
    return self;
}

- (void)awakeFromNib
{
    self.textContainerInset = UIEdgeInsetsZero;
    self.textContainer.lineFragmentPadding = 0;
    self.scrollEnabled = NO;
    self.editable = NO;
}

@end
