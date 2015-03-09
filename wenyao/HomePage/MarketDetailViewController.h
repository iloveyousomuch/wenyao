//
//  MarketDetailViewController.h
//  quanzhi
//
//  Created by xiezhenghong on 14-7-3.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"


@interface MarketDetailViewController : BaseViewController

//previewMode为1 是预览模式
@property (nonatomic, assign) NSUInteger                previewMode;
@property (nonatomic, strong) NSString                  *htmlUrl;
@property (nonatomic, strong) NSMutableDictionary       *infoDict;
@property (nonatomic, strong) NSString                  *activityId;
//userType 进入营销活动页面类型值  (userType的值依次累加)
//   1.从“我“进去userType=1     2.从聊天页面进去userType=2
@property (nonatomic,assign)  NSInteger              userType;

@property (nonatomic,assign) NSInteger imStatus;


@property (nonatomic, strong) IBOutlet UIScrollView     *scrollView;
@property (nonatomic, strong) IBOutlet UIImageView      *imageView;
@property (nonatomic, strong) IBOutlet UILabel          *contentLabel;

@property (nonatomic, strong) IBOutlet UILabel          *titleLabel;

@property (nonatomic, strong) IBOutlet UILabel          *dateLabel;

@end
