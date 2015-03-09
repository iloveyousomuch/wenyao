//
//  NSString+MD5HexDigest.h
//  quanzhi
//
//  Created by xiezhenghong on 14-8-12.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

@interface NSString (md5)

-(NSString *) md5HexDigest;

@end
