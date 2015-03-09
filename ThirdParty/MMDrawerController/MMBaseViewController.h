//
//  BaseViewController.h
//  zhihu
//
//  Created by xiezhenghong on 14-8-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMBaseViewController : UIViewController
{
    BOOL        isKeyBoardShow;
}
@property (nonatomic, strong) UIToolbar   *bottomToolBar;

@end
