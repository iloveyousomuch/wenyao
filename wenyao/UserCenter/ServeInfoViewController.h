//
//  ServeInfoViewController.h
//  wenyao
//
//  Created by Meng on 14-9-30.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, WebRequestType){
    WebRequestTypeServeClauses, //服务条款
    WebRequestTypeFunctionIntroduce, //功能介绍
    WebRequestTypeUserProtocol, //用户协议
    WebRequestTypeAboutWenyao, //关于问药
};

@interface ServeInfoViewController : BaseViewController

@property(nonatomic) WebRequestType webRequestType; // default is WebRequestTypeServeClauses

@end
