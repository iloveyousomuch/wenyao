//
//  NSThread+Blocks.h
//  quanzhi
//
//  Created by ZhongYun on 14-3-29.
//  Copyright (c) 2014年 ZhongYun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSThread (BlocksAdditions)
- (void)performBlock:(void (^)())block;
- (void)performBlock:(void (^)())block waitUntilDone:(BOOL)wait;
+ (void)performBlockInBackground:(void (^)())block;
+ (void)performBlockOnMainThread:(void (^)())block;

@end