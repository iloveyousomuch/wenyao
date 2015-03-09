//
//  relateBgView.m
//  wenyao
//
//  Created by Meng on 14/12/10.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "relateBgView.h"
#import "ZhPMethod.h"
#import "Constant.h"
#import "Categorys.h"
#import "DisesaeDetailInfoButton.h"

#define kLineTag   8088//绿色线条的tag值
@implementation relateBgView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//relateBgViewDiseaseButtonClick

- (instancetype)init
{
    if (self = [super init]) {
        
        UIView * greenLine = [[UIView alloc]init];
        greenLine.backgroundColor = GREENTCOLOR;
        greenLine.tag = kLineTag;
        [self addSubview:greenLine];
        
        DisesaeDetailInfoButton * button = [DisesaeDetailInfoButton buttonWithType:UIButtonTypeCustom];
        button.tag = kButtonTag;
        button.layer.borderWidth = 0.5;
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 3;
        button.layer.borderColor = GREENTCOLOR.CGColor;
        [button addTarget:self action:@selector(relateBgViewButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        SBTextView * sameLabel = [[SBTextView alloc] init];
        sameLabel.tag = kSameLabelTag;
        [self addSubview:sameLabel];
        
        
        SBTextView * sameContentLabel = [[SBTextView alloc] init];
        sameContentLabel.tag = kSameLabelContentTag;
        [self addSubview:sameContentLabel];
        
        SBTextView * differentLabel = [[SBTextView alloc] init];
        differentLabel.tag = kDifferentLabelTag;
        [self addSubview:differentLabel];
        
        SBTextView * differentContentLabel = [[SBTextView alloc] init];
        differentContentLabel.tag = kDifferentCOntentLabelTag;
        [self addSubview:differentContentLabel];
        
    }
    return self;
}

- (void)setInfoDict:(NSDictionary *)infoDict
{
    
    CGFloat relate_y = 0;
    UIView * greenLine = (UIView *)[self viewWithTag:kLineTag];
    [greenLine setFrame:CGRectMake(0, relate_y, APP_W-20, 0.5)];
    
    relate_y += kY;
    
    UIFont * font = infoDict[@"font"];
    NSString * buttonTitle = infoDict[@"relateTitle"];
    //CGSize syptomStrSize = CGSizeFromString(infoDict[@"symptomStrSize"]);
    
    NSString * sameStr = @"相同症状:";
    CGSize syptomStrSize = getTextSize(sameStr, font, APP_W-20);
    
    DisesaeDetailInfoButton * btn = (DisesaeDetailInfoButton *)[self viewWithTag:kButtonTag];
    btn.buttonName = buttonTitle;
    [btn setTitleColor:GREENTCOLOR forState:UIControlStateNormal];
    btn.titleLabel.font = font;
    [btn setFrame:CGRectMake(k0, relate_y, getTextSize(buttonTitle, font, APP_W-20).width + 20, kRelateButtonHeight)];
    [btn setTitle:buttonTitle forState:UIControlStateNormal];
    
    SBTextView * sameLabel = (SBTextView *)[self viewWithTag:kSameLabelTag];
    sameLabel.text = @"相同症状:";
    sameLabel.font = font;
    //[sameLabel setFrame:CGRectMake(k0, btn.FY + btn.FH + kB , syptomStrSize.width, syptomStrSize.height)];
    [sameLabel setFrame:CGRectMake(k0, btn.FY + btn.FH + kB , syptomStrSize.width, syptomStrSize.height)];
    
    CGSize text1Size = CGSizeFromString(infoDict[@"relateText1Size"]);
    SBTextView * sameContentLabel = (SBTextView *)[self viewWithTag:kSameLabelContentTag];
    sameContentLabel.text = infoDict[@"relateText1"];
    sameContentLabel.font = font;
    [sameContentLabel setFrame:CGRectMake(k0, sameLabel.FY + sameLabel.FH + kB, text1Size.width, text1Size.height)];
    
    
    SBTextView * differentLabel = (SBTextView *)[self viewWithTag:kDifferentLabelTag];
    differentLabel.font = font;
    differentLabel.text = @"不同症状:";
    [differentLabel setFrame:CGRectMake(k0, sameContentLabel.FY + sameContentLabel.FH + kB, syptomStrSize.width, syptomStrSize.height)];
    
    CGSize text2Size = CGSizeFromString(infoDict[@"relateText2Size"]);
    SBTextView * differentContentLabel = (SBTextView *)[self viewWithTag:kDifferentCOntentLabelTag];
    differentContentLabel.font = font;
    differentContentLabel.text = infoDict[@"relateText2"];
    [differentContentLabel setFrame:CGRectMake(k0, differentLabel.FY + differentLabel.FH + kB, text2Size.width, text2Size.height)];
    
}


- (void)relateBgViewButtonClick:(DisesaeDetailInfoButton *)btn
{
    btn.enabled = NO;
    if ([self.delegate respondsToSelector:@selector(relateBgViewDiseaseButtonClick:button:)]) {
        [self.delegate relateBgViewDiseaseButtonClick:btn.buttonName button:btn];
    }
}

@end
