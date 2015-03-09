//
//  treatRuleBgView.m
//  wenyao
//
//  Created by Meng on 14/12/10.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "treatRuleBgView.h"
#import "Constant.h"
#import "ZhPMethod.h"
#import "Categorys.h"
#import "TagCollectionView.h"
#import "DisesaeDetailInfoButton.h"

#define k0              0//控件的x坐标
#define kX              10//控件的x坐标
#define kY              10//控件的y坐标
#define kH              10//两个控件间距离
#define kB              10//控件底部距离
#define kSectionHeight  30//Section段头的高度


#define kBoxBackgroundColor     UICOLOR(255, 249, 222)          //背景颜色
#define kBoxBorderColor         UICOLOR(254, 229, 176).CGColor  //边框颜色
#define kBoxBorderWidth         1                               //边框宽度

#define kEBu            10//恶补高度
#define kRelateButtonHeight 20 //相关疾病的button高度


#define kRuleTitleTag               900
#define kRuleBoxTag                 901
#define kRuleBoxDescTag             9001
#define kRuleMedicineTitleTag       902
#define kRuleButtonTag              903


#define kButtonX    10 //button的x坐标
#define kButtonY    10 //button的y坐标
#define kButton2w   10 //button的标题两端的宽度
#define kButtonKB   8  //button上下间距离
#define kButtonH    20//相关疾病的button高度
#define kButtonw    8 //button左右间距

#define kLineTag   8088//绿色线条的tag值

@implementation treatRuleBgView

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
        
        
        
    }
    return self;
}

- (instancetype)initWithArr:(NSArray *)arr
{
    if (self = [super init]) {
        
        UIView * greenLine = [[UIView alloc]init];
        greenLine.backgroundColor = GREENTCOLOR;
        greenLine.tag = kLineTag;
        [self addSubview:greenLine];
        
        SBTextView * ruleTitle = [[SBTextView alloc] init];
        ruleTitle.tag = kRuleTitleTag;
        [self addSubview:ruleTitle];
        
        UIView * boxView = [[UIView alloc] init];
        boxView.tag = kRuleBoxTag;
        [boxView setBackgroundColor:kBoxBackgroundColor];
        boxView.layer.borderColor = kBoxBorderColor;
        boxView.layer.borderWidth = kBoxBorderWidth;
        [self addSubview:boxView];
        
        SBTextView * descText = [[SBTextView alloc] init];
        descText.tag = kRuleBoxDescTag;
        descText.backgroundColor = [UIColor clearColor];
        [boxView addSubview:descText];
        
        SBTextView * medicineText = [[SBTextView alloc] init];
        medicineText.tag = kRuleMedicineTitleTag;
        [self addSubview:medicineText];
        
        
        //循环创建buttons
        for (int i = 0; i<arr.count; i++) {
            DisesaeDetailInfoButton * button = [DisesaeDetailInfoButton buttonWithType:UIButtonTypeCustom];
            button.tag = kRuleButtonTag + i;
            button.layer.borderWidth = 0.5;
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = 3;
            button.layer.borderColor = GREENTCOLOR.CGColor;
            [button setTitleColor:GREENTCOLOR forState:UIControlStateNormal];
            [self addSubview:button];
        }
        
    }
    return self;
}

- (void)setInfoDict:(NSDictionary *)infoDict
{
    CGFloat rule_y = 0;
    UIView * greenLine = (UIView *)[self viewWithTag:kLineTag];
    [greenLine setFrame:CGRectMake(kX, rule_y, APP_W-20, 0.5)];
    
    rule_y += kY;
    
    
    _infoDict = infoDict;
    UIFont * font = infoDict[@"font"];
    UIFont * titleFont = infoDict[@"titleFont"];
    
    CGSize ruleTitleSize = [self getTextViewHeightWithContent:infoDict[@"ruleName"] Font:titleFont width:APP_W-20];
    CGSize ruleDescSize = [self getTextViewHeightWithContent:infoDict[@"ruleDesc"] Font:font width:APP_W-30];

    //标题
    SBTextView * ruleTitle = (SBTextView *)[self viewWithTag:kRuleTitleTag];
    ruleTitle.font = titleFont;
    ruleTitle.text = infoDict[@"ruleName"];
    [ruleTitle setFrame:CGRectMake(kX, rule_y, APP_W-20, ruleTitleSize.height)];
    
    rule_y += ruleTitleSize.height +kB;
    //盒子
    UIView * boxView = (SBTextView *)[self viewWithTag:kRuleBoxTag];
    [boxView setFrame:CGRectMake(kX, rule_y, APP_W-20, ruleDescSize.height + kB)];
    //描述
    SBTextView * descText = (SBTextView *)[self viewWithTag:kRuleBoxDescTag];
    [descText setFrame:CGRectMake(kX-5, 5, ruleDescSize.width, ruleDescSize.height)];
    descText.font = font;
    descText.text = infoDict[@"ruleDesc"];
    
    rule_y += boxView.FH + kB;
    
    
    //常用药品
    SBTextView * medicineText = (SBTextView *)[self viewWithTag:kRuleMedicineTitleTag];
    [medicineText setFrame:CGRectMake(kX, rule_y, ruleTitleSize.width, ruleTitleSize.height)];
    medicineText.font = titleFont;
    medicineText.text = @"常用药品";
    
    CGFloat button_x = kButtonX;
    CGFloat button_y = rule_y + ruleTitleSize.height + kB;
    
    
    NSArray * buttonArr = infoDict[@"formulaDetail"];
    for (int i = 0; i < buttonArr.count; i++) {
        NSDictionary * dic = buttonArr[i];
        UIFont * buttonFont = dic[@"titleFont"];
        NSString * buttonName = dic[@"formulaName"];
        CGSize buttonSize = getTextSize(buttonName, buttonFont, APP_W-20);
        
        DisesaeDetailInfoButton * button = (DisesaeDetailInfoButton *)[self viewWithTag:kRuleButtonTag + i];
        button.infoDict = buttonArr[i];
        [button addTarget:self action:@selector(ruleMedicineButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:dic[@"formulaName"] forState:UIControlStateNormal];
        button.titleLabel.font = buttonFont;
        
        
        CGFloat buttonWidth = buttonSize.width + kButton2w;
        if (buttonWidth > APP_W-20) {
            buttonWidth = APP_W-20;
        }
        if (button_x + buttonWidth >= APP_W-20) {
            button_x = kButtonX;
            button_y = button_y + kButtonH + kButtonKB;
        }

        [button setFrame:CGRectMake(button_x, button_y, buttonSize.width + kButton2w, kButtonH)];
        button_x += buttonWidth + kButtonw;
    }
    
}

- (void)ruleMedicineButtonClick:(DisesaeDetailInfoButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(treatRuleBgViewButtonClick:)]) {
        [self.delegate treatRuleBgViewButtonClick:btn.infoDict];
    }
}

-(CGSize)getTextViewHeightWithContent:(NSString *)content Font:(UIFont *)font width:(CGFloat)width
{
    CGFloat tvHeight =0.0f;
    SBTextView *textViewTemp = [[SBTextView alloc] initWithFrame:CGRectMake(0, 0, width, 5000)];
    //textViewTemp.textContainerInset = UIEdgeInsetsZero;
    //textViewTemp.textContainer.lineFragmentPadding = 0;
    content = [self replaceSpecialStringWith:content];
    textViewTemp.text = content;
    textViewTemp.font = font;
    [textViewTemp sizeToFit];
    if([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f){
        tvHeight = [textViewTemp.layoutManager usedRectForTextContainer:textViewTemp.textContainer].size.height+2*fabs(textViewTemp.contentInset.top);
    }else{
        tvHeight = textViewTemp.contentSize.height;
    }
    CGSize size = CGSizeMake(textViewTemp.FW, tvHeight);
    NSLog(@"%f",tvHeight);
    return size;
}

//特殊字符的替换
- (NSString *)replaceSpecialStringWith:(NSString *)string{
    string = [string stringByReplacingOccurrencesOfString:@"    &nbsp;&nbsp;&nbsp;&nbsp;" withString:@"    "];
    string = [string stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    string = [string stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\r\n"];
    string = [string stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r\n"];
    string = [string stringByReplacingOccurrencesOfString:@"<p/>" withString:@"\r\n"];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"&lt:" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt:" withString:@">"];
    return string;
}

@end
