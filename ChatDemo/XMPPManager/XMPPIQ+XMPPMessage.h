//
//  XMPPIQ+XMPPIQ_Message.h
//  wenyao-store
//
//  Created by xiezhenghong on 14-10-8.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPIQ.h"

@interface XMPPIQ (Message)

+ (XMPPIQ *)messageTypeWithText:(NSString *)plainText
                         withTo:(NSString *)toJid
                      avatarUrl:(NSString *)avatarUrl
                           from:(NSString *)fromName
                      timestamp:(double)timestamp
                           UUID:(NSString *)UUID;

+ (XMPPIQ *)messageTypeWithEvaluate:(NSString *)plainText
                             withTo:(NSString *)toJid
                               star:(CGFloat)star
                          avatarUrl:(NSString *)avatarUrl
                               from:(NSString *)fromName
                          timestamp:(double)timestamp
                               UUID:(NSString *)UUID;

@end
