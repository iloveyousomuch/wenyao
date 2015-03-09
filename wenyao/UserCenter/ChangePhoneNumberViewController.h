//
//  ChangePhoneNumberViewController.h
//  wenyao
//
//  Created by Meng on 14-9-30.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"

@protocol ChangePhoneNumberViewControllerDelegate <NSObject>

- (void)returnNumber:(NSString *)number;

@end


@interface ChangePhoneNumberViewController : BaseViewController

@property (nonatomic ,weak) id<ChangePhoneNumberViewControllerDelegate>delegate;

@end
