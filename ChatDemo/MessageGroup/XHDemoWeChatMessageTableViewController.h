//
//  XHDemoWeChatMessageTableViewController.h
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-4-27.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHMessageTableViewController.h"
#import "AppDelegate.h"

typedef enum AccountType
{
    NormalType = 0,
    OfficialType = 1
}AccountType;

@interface XHDemoWeChatMessageTableViewController : XHMessageTableViewController

@property (nonatomic, strong) NSCondition       *taskLock;
@property (nonatomic, strong) NSDictionary      *infoDict;
@property (nonatomic, assign) AccountType       accountType;

@end
