//
//  DiseaseClass.h
//  quanzhi
//
//  Created by ZhongYun on 14-6-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiseaseClass : NSObject
+ (DiseaseClass*)shared;
- (void)initData;

- (NSMutableArray*)getTree:(NSMutableDictionary*)parent Resp:(void(^)(id))block;
- (NSMutableArray*)getList;
@end
