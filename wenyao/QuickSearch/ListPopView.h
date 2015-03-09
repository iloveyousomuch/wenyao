//
//  ListPopView.h
//  quanzhi
//
//  Created by ZhongYun on 14-6-24.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

#define POP_CHECK   1
#define POP_RADIO   2

@interface ListPopView : UIView
- (ListPopView*)initWithType:(int)type;
- (void)show;
@property(nonatomic, copy)NSString* title;
@property(nonatomic, copy)NSString* showField;
@property(nonatomic, retain)NSArray* selected;
@property(nonatomic, retain)NSArray* data;
@property(nonatomic, copy)void(^respBlock)(NSArray* result);
@end

