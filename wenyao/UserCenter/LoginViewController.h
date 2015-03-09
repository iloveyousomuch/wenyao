//
//  LoginViewController.h
//  WenYao
//
//  Created by Meng on 14-9-2.
//  Copyright (c) 2014年 江苏苏州. All rights reserved.
//

#import "BaseViewController.h"

@interface LoginViewController : BaseViewController

@property (nonatomic, assign)   BOOL                isPresentType;
@property (nonatomic, assign)   UINavigationController    *parentNavgationController;
@property (nonatomic, copy) void(^backBlocker)(void);
@property (nonatomic, copy) void(^loginSuccessBlock)(void);

@end
