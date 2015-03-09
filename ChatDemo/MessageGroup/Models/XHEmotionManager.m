//
//  XHEmotionManager.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-5-3.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHEmotionManager.h"

@implementation XHEmotionManager

- (id)init
{
    self = [super init];
    if(self){
        self.emotions = [NSMutableArray arrayWithCapacity:100];
    }
    return self;
}

- (void)dealloc {
    [self.emotions removeAllObjects];
    self.emotions = nil;
}

@end
