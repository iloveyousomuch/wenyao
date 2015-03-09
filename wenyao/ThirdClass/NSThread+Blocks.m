//
//  NSThread+Blocks.m
//  quanzhi
//
//  Created by ZhongYun on 14-3-29.
//  Copyright (c) 2014年 ZhongYun. All rights reserved.
//

#import "NSThread+Blocks.h"

#ifndef __IPHONE_4_0
#import <dispatch/dispatch.h>
#endif

@implementation NSThread (BlocksAdditions)
- (void)performBlock:(void (^)())block
{
	if ([[NSThread currentThread] isEqual:self])
		block();
	else
		[self performBlock:block waitUntilDone:NO];
}
- (void)performBlock:(void (^)())block waitUntilDone:(BOOL)wait
{
    [NSThread performSelector:@selector(ng_runBlock:)
                     onThread:self
                   withObject:[block copy]
                waitUntilDone:wait];
}
+ (void)ng_runBlock:(void (^)())block
{
	block();
}
+ (void)performBlockInBackground:(void (^)())block{
#ifdef __IPHONE_4_0
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
		block();
	});
#else
	[NSThread performSelectorInBackground:@selector(ng_runBlock:)
	                           withObject:[[block copy] autorelease]];
#endif
}

+ (void)performBlockOnMainThread:(void (^)())block{
	
#ifdef __IPHONE_4_0
	dispatch_async(dispatch_get_main_queue(), ^{
		block();
	});
#else
	[NSThread performSelectorOnMainThread:@selector(ng_runBlock:)
	                           withObject:[[block copy] autorelease]];
#endif
}

@end
