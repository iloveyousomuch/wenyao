//
//  NSString+AbandonStringBlank.m
//  wenyao
//
//  Created by Meng on 15/1/20.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "NSString+AbandonStringBlank.h"

@implementation NSString (AbandonStringBlank)

+ (NSString *)abandonStringBlank:(NSString *)string
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
