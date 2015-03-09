//
//  XMPP+XMPPMessage.m
//  iPhoneXMPP
//
//  Created by xiezhenghong on 14-3-16.
//
//

#import "XMPP+XMPPMessage.h"
#import "NSXMLElement+XMPP.h"
#import "NSData+XMPP.h"
#include "Constant.h"



@implementation XMPPMessage(XMPP)
+ (XMPPMessage *)basicMessageGenerator:(NSString *)plainText
                                withTo:(XMPPJID *)toJid
{
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:toJid];
    [message addBody:plainText];
    return message;
}


+ (XMPPMessage *)messageTypeWithText:(NSString *)plainText
                              withTo:(XMPPJID *)toJid
                           timestamp:(NSUInteger)timestamp
                                UUID:(NSString *)UUID
{
    XMPPMessage *message = [XMPPMessage basicMessageGenerator:plainText withTo:toJid];
    NSXMLElement *custom = [NSXMLElement elementWithName:@"custom" xmlns:@"com:roger:other"];
    [custom addChild:[NSXMLElement elementWithName:@"category" numberValue:[NSNumber numberWithInt:TextMessage]]];
    [custom addChild:[NSXMLElement elementWithName:@"timestamp" numberValue:[NSNumber numberWithInt:timestamp]]];
    [custom addChild:[NSXMLElement elementWithName:@"UUID" stringValue:UUID]];
    [message addChild:custom];
    return message;
}

+ (XMPPMessage *)messageTypeWithAudio:(NSString *)plainText
                               withTo:(XMPPJID *)toJid
                             duartion:(NSUInteger)duartion
                            timestamp:(NSUInteger)timestamp
                            audioPath:(NSString *)path
{
    XMPPMessage *message = [XMPPMessage basicMessageGenerator:plainText withTo:toJid];
    NSXMLElement *custom = [NSXMLElement elementWithName:@"custom" xmlns:@"com:roger:other"];
    [custom addChild:[NSXMLElement elementWithName:@"category" numberValue:[NSNumber numberWithInt:AudioMessage]]];
    [custom addChild:[NSXMLElement elementWithName:@"timestamp" numberValue:[NSNumber numberWithInt:timestamp]]];
    NSData *audioData = [NSData dataWithContentsOfFile:path];
    [custom addChild:[NSXMLElement elementWithName:@"richbody" stringValue:[audioData xmpp_base64Encoded]]];
    [custom addChild:[NSXMLElement elementWithName:@"duartion" numberValue:[NSNumber numberWithInt:duartion]]];
    
    [message addChild:custom];
    return message;
}

+ (XMPPMessage *)messageTypeWithImage:(NSString *)plainText
                               withTo:(XMPPJID *)toJid
                            timestamp:(NSUInteger)timestamp
                            imagePath:(NSString *)path
{
    XMPPMessage *message = [XMPPMessage basicMessageGenerator:plainText withTo:toJid];
    NSXMLElement *custom = [NSXMLElement elementWithName:@"custom" xmlns:@"com:roger:other"];
    [custom addChild:[NSXMLElement elementWithName:@"category" numberValue:[NSNumber numberWithInt:ImageMessage]]];
    [custom addChild:[NSXMLElement elementWithName:@"timestamp" numberValue:[NSNumber numberWithInt:timestamp]]];

    NSData *imageData = [NSData dataWithContentsOfFile:path];
    [custom addChild:[NSXMLElement elementWithName:@"richbody" stringValue:[imageData xmpp_base64Encoded]]];
    [message addChild:custom];
    return message;
}

+ (XMPPMessage *)messageTypeWithLocation:(NSString *)plainText
                               withTo:(XMPPJID *)toJid
                            timestamp:(NSUInteger)timestamp
                            imagePath:(NSString *)path
{
    XMPPMessage *message = [XMPPMessage basicMessageGenerator:plainText withTo:toJid];
    NSXMLElement *custom = [NSXMLElement elementWithName:@"custom" xmlns:@"com:roger:other"];
    [custom addChild:[NSXMLElement elementWithName:@"category" numberValue:[NSNumber numberWithInt:LocationMessage]]];
    [custom addChild:[NSXMLElement elementWithName:@"timestamp" numberValue:[NSNumber numberWithInt:timestamp]]];

//    NSData *imageData = [NSData dataWithContentsOfFile:path];
//    [custom addChild:[NSXMLElement elementWithName:@"richbody" stringValue:[imageData xmpp_base64Encoded]]];
    [message addChild:custom];
    return message;
}

@end
