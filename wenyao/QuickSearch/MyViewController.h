//
//  MyViewController.h
//  wenyao
//
//  Created by qwyf0006 on 15/2/9.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//


//代替  KnowLedgeViewController

#import "BaseViewController.h"

@interface MyViewController : BaseViewController

@property (nonatomic, strong) NSDictionary  *source;
@property (nonatomic ,copy) NSString * knowledgeTitle;
@property (nonatomic ,strong) NSString * knowledgeContent;
@property(nonatomic,strong)NSString *viewtitle;

@end
