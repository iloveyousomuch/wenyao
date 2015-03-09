//
//  RegisterViewController.h
//  wenyao
//
//  Created by Meng on 14-9-30.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"

@protocol RegisterViewControllerDelegate <NSObject>

- (void)returnRegisterNumber:(NSString *)number Password:(NSString *)password;

@end

@interface RegisterViewController : BaseViewController

@property (nonatomic ,weak) id<RegisterViewControllerDelegate> delegate;

@end
