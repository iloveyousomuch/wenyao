//
//  MATagButtonView.m
//  wenyao
//
//  Created by Meng on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "MATagButtonView.h"
#import "Constant.h"
#import "ZhPMethod.h"

#define kTag            666
#define kFontSize       14
#define kButton_10   10 //button的标题两端的宽度

#define k0              0//控件的x坐标
#define kX              10//控件的x坐标
#define kY              10//控件的y坐标
#define kH              10//两个控件间距离
#define kB              10//控件底部距离

#define kButtonH    20   //标签button的高度
#define kButtonw    8 //button左右间距

@implementation MATagButtonView


- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame TagArray:(NSArray *)tagArray
{
    if (self = [super init]) {
        
        __block CGFloat button_x = kX;
        __block CGFloat button_y = kY;
        
        [tagArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MATagButton *button = [MATagButton buttonWithType:UIButtonTypeCustom];
            button.tag = kTag;
            //button.layer.borderWidth = 0.5;
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = 3;
            //button.layer.borderColor = GREENTCOLOR.CGColor;
            button.isSelected = NO;
            button.backgroundColor = [UIColor whiteColor];
            [button addTarget:self action:@selector(tagButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitleColor:GREENTCOLOR forState:UIControlStateNormal];
            
            CGSize buttonSize = getTextSize(obj, Font(kFontSize), APP_W-20);
            [button setTitle:obj forState:UIControlStateNormal];
            button.titleLabel.font = Font(14);
            CGFloat buttonWidth = buttonSize.width + kButton_10;
            if (buttonWidth > APP_W - 20) {
                buttonWidth = APP_W - 20;
            }
            if (button_x + buttonWidth >= APP_W-20) {
                button_x = kX;
                button_y = button_y + kButtonH + kButton_10;
            }
            [button setFrame:CGRectMake(button_x, button_y, buttonSize.width + kButton_10, kButtonH)];
            button_x += buttonWidth + kButtonw;
            
            [self addSubview:button];
        }];
        
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width , button_y + kButtonH);
    }
    return self;
}

- (void)tagButtonClick:(MATagButton *)button
{
    if (button.isSelected == NO) {
        button.isSelected = YES;
        button.backgroundColor = GREENTCOLOR;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        button.isSelected = NO;
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:GREENTCOLOR forState:UIControlStateNormal];
    }
}

@end




@implementation MATagButton



@end