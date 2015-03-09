//
//  secondCustomAlertView.m
//  wenyao
//
//  Created by 李坚 on 14/12/22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "secondCustomAlertView.h"
#import "Constant.h"

@implementation secondCustomAlertView

- (void)awakeFromNib{
    
    self.textField.layer.masksToBounds = YES;
    self.textField.layer.borderWidth = 0.5;
    self.textField.layer.borderColor = UIColorFromRGB(0xdbdbdb).CGColor;
    self.textField.layer.cornerRadius = 3.0f;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
    self.textField.leftView = paddingView;
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 42);
    }
    else{
        self.textField.frame = CGRectMake(self.textField.frame.origin.x, 19, self.textField.frame.size.width, 42);
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 80);
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
