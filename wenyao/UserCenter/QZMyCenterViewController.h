//
//  QZMyCenterViewController.h
//  wenyao
//
//  Created by Meng on 15/1/15.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Extension.h"
@protocol BeforeAndAfterLoginViewDelegate <NSObject>

@required
/**
 *  点击登录按钮
 */
- (void)loginButtonClick;
/**
 *  点击个人头像
 */
- (void)personHeadImageClick;

@end

@interface QZMyCenterViewController : UIViewController

@end


//登录前的View
@interface BeforeLoginView : UIView

@property (nonatomic ,strong) id<BeforeAndAfterLoginViewDelegate> delegate;

@end


//登录后的View

@interface AfterLoginView : UIView

@property (nonatomic ,strong) UIImageView   *headImageView;
@property (nonatomic ,strong) UILabel       *nameLabel;
@property (nonatomic ,strong) id<BeforeAndAfterLoginViewDelegate> delegate;

@end


