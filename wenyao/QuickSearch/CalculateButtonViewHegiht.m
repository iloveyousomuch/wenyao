//
//  CalculateButtonViewHegiht.m
//  wenyao
//
//  Created by Meng on 14/12/11.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "CalculateButtonViewHegiht.h"
#import "Constant.h"
#import "ZhPMethod.h"
#import "treatRuleBgView.h"
#import "DisesaeDetailInfoButton.h"

#define kButtonX    10 //button的x坐标
#define kButtonY    10 //button的y坐标
#define kButton2w   10 //button的标题两端的宽度
#define kButtonKB   8  //button上下间距离
#define kButtonH    20//相关疾病的button高度
#define kButtonw    8 //button左右间距

@implementation CalculateButtonViewHegiht



+ (CGFloat)calculateButtonsHeightWith:(NSArray *)infoArr
{
    CGFloat button_x = kButtonX;
    CGFloat button_y = kButtonY;
    
    for (int i = 0; i < infoArr.count; i++) {
        NSDictionary * dic = infoArr[i];
        UIFont * font = dic[@"titleFont"];
        NSString * buttonName = dic[@"formulaName"];
        CGSize buttonSize = getTextSize(buttonName, font, APP_W-20);
        CGFloat buttonWidth = buttonSize.width + kButton2w;
        if (buttonWidth > APP_W-20) {
            buttonWidth = APP_W-20;
        }
        if (button_x + buttonWidth >= APP_W-20) {
            button_x = kButtonX;
            button_y = button_y + kButtonH + kButtonKB;
        }
        UIButton * b = [UIButton buttonWithType:UIButtonTypeCustom];
        [b setFrame:CGRectMake(button_x, button_y, buttonWidth, kButtonH)];
        button_x += buttonWidth + kButtonw;
//        if (button_x + buttonWidth + kButtonw >= APP_W-20) {
//            button_x = kButtonX;
//            button_y = button_y + kButtonH + kButtonKB;
//        }
        
    }
    return button_y + kButtonH;
}

@end
