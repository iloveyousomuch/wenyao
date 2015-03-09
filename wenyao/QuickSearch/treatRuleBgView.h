//
//  treatRuleBgView.h
//  wenyao
//
//  Created by Meng on 14/12/10.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBTextView.h"

@protocol treatRuleBgViewDelegate <NSObject>

- (void)treatRuleBgViewButtonClick:(NSDictionary *)buttonDict;

@end


@interface treatRuleBgView : UIView

@property (nonatomic ,strong) NSDictionary * infoDict;

- (instancetype)initWithArr:(NSArray *)arr;

@property (nonatomic ,assign) id<treatRuleBgViewDelegate>delegate;

@end
