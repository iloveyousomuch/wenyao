//
//  XMPP+XMPPMessage.h
//  iPhoneXMPP
//
//  Created by xiezhenghong on 14-3-16.
//
//

#import <Foundation/Foundation.h>
#import "XMPPMessage.h"

@interface XMPPMessage(XMPP)

+ (XMPPMessage *)messageTypeWithText:(NSString *)plainText
                              withTo:(XMPPJID *)toJid
                           timestamp:(NSUInteger)timestamp
                                UUID:(NSString *)UUID;

+ (XMPPMessage *)messageTypeWithAudio:(NSString *)plainText
                               withTo:(XMPPJID *)toJid
                             duartion:(NSUInteger)duartion
                            timestamp:(NSUInteger)timestamp
                            audioPath:(NSString *)path;

+ (XMPPMessage *)messageTypeWithImage:(NSString *)plainText
                               withTo:(XMPPJID *)toJid
                            timestamp:(NSUInteger)timestamp
                            imagePath:(NSString *)path;

+ (XMPPMessage *)messageTypeWithLocation:(NSString *)plainText
                                  withTo:(XMPPJID *)toJid
                               timestamp:(NSUInteger)timestamp
                               imagePath:(NSString *)path;

@end
