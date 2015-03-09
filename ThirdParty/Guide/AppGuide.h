//
//  AppGuide.h
//  quanzhi
//
//  Created by ZhongYun on 14-1-28.
//  Copyright (c) 2014年 ZhongYun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppGuide : UIView
@property(nonatomic,retain)NSArray* imgNames;
@end

void showAppGuide(NSArray* images);
