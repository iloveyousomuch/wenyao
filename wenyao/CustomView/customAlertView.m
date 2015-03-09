//
//  customAlertView.m
//  TestAlertView
//
//  Created by chenzhipeng on 14/11/4.
//  Copyright (c) 2014年 perry. All rights reserved.
//

#import "customAlertView.h"

@implementation customAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)btnClick:(id)sender {
//    self.isClick = YES;
    if (self.isClick == YES) {
        self.isClick = NO;
        [self.btnClick setImage:[UIImage imageNamed:@"checkboxUnselect"] forState:UIControlStateNormal];
    } else {
        self.isClick = YES;
        [self.btnClick setImage:[UIImage imageNamed:@"checkboxSelect"] forState:UIControlStateNormal];
    }
}
@end
