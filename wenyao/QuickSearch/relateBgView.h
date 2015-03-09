//
//  relateBgView.h
//  wenyao
//
//  Created by Meng on 14/12/10.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SBTextView.h"
@class DisesaeDetailInfoButton;

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


#define kButtonTag                  800
#define kSameLabelTag               801
#define kSameLabelContentTag        802
#define kDifferentLabelTag          803
#define kDifferentCOntentLabelTag   804

@protocol relateBgViewDelegate <NSObject>

//- (void)relateBgViewDiseaseButtonClick:(NSString *)buttonName;

- (void)relateBgViewDiseaseButtonClick:(NSString *)buttonName button:(DisesaeDetailInfoButton *)button;

@end


@interface relateBgView : UIView

@property (nonatomic ,strong) NSDictionary * infoDict;

@property (nonatomic ,assign) id<relateBgViewDelegate>delegate;
@end
