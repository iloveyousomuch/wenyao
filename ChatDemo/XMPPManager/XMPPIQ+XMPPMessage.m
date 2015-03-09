//
//  XMPPIQ+XMPPIQ_Message.m
//  wenyao-store
//
//  Created by xiezhenghong on 14-10-8.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "XMPPIQ+XMPPMessage.h"
#import "NSXMLElement+XMPP.h"
#import "XHMessage.h"
#import "AppDelegate.h"
#import "Constant.h"

@implementation XMPPIQ (Message)

+ (XMPPIQ *)messageTypeWithText:(NSString *)plainText
                         withTo:(NSString *)toJid
                      avatarUrl:(NSString *)avatarUrl
                           from:(NSString *)fromName
                      timestamp:(double)timestamp
                           UUID:(NSString *)UUID
{
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"id" stringValue:UUID];
    NSXMLElement *notification = [NSXMLElement elementWithName:@"notification" xmlns:@"androidpn:iq:notification"];
    
    [notification addChild:[NSXMLElement elementWithName:@"id" stringValue:UUID]];
    [notification addChild:[NSXMLElement elementWithName:@"apiKey" stringValue:@"1234567890"]];
    [notification addChild:[NSXMLElement elementWithName:@"title" stringValue:@""]];
    [notification addChild:[NSXMLElement elementWithName:@"message" stringValue:plainText]];
    [notification addChild:[NSXMLElement elementWithName:@"uri" stringValue:avatarUrl]];
    [notification addChild:[NSXMLElement elementWithName:@"fromUser" stringValue:fromName]];
    [notification addChild:[NSXMLElement elementWithName:@"msType" numberValue:[NSNumber numberWithInt:XHBubbleMessageMediaTypeText]]];
    [notification addChild:[NSXMLElement elementWithName:@"timestamp" stringValue:[NSString stringWithFormat:@"%.0f",timestamp]]];
    [notification addChild:[NSXMLElement elementWithName:@"to" stringValue:toJid]];
    [notification addChild:[NSXMLElement elementWithName:@"token" stringValue:app.configureList[APP_USER_TOKEN]]];
    [iq addChild:notification];
    
    return iq;
}

+ (XMPPIQ *)messageTypeWithEvaluate:(NSString *)plainText
                             withTo:(NSString *)toJid
                               star:(CGFloat)star
                          avatarUrl:(NSString *)avatarUrl
                               from:(NSString *)fromName
                          timestamp:(double)timestamp
                               UUID:(NSString *)UUID
{
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"id" stringValue:UUID];
    NSXMLElement *notification = [NSXMLElement elementWithName:@"notification" xmlns:@"androidpn:iq:notification"];
    
    [notification addChild:[NSXMLElement elementWithName:@"id" stringValue:UUID]];
    [notification addChild:[NSXMLElement elementWithName:@"apiKey" stringValue:@"1234567890"]];
    [notification addChild:[NSXMLElement elementWithName:@"title" stringValue:[NSString stringWithFormat:@"%f",star]]];
    [notification addChild:[NSXMLElement elementWithName:@"message" stringValue:plainText]];
    [notification addChild:[NSXMLElement elementWithName:@"uri" stringValue:avatarUrl]];
    [notification addChild:[NSXMLElement elementWithName:@"fromUser" stringValue:[NSString stringWithFormat:@"%@",fromName]]];
    [notification addChild:[NSXMLElement elementWithName:@"msType" numberValue:[NSNumber numberWithInt:XHBubbleMessageMediaTypeStarClient]]];
    [notification addChild:[NSXMLElement elementWithName:@"timestamp" stringValue:[NSString stringWithFormat:@"%f",timestamp]]];
    [notification addChild:[NSXMLElement elementWithName:@"to" stringValue:[NSString stringWithFormat:@"%@",toJid]]];
    [notification addChild:[NSXMLElement elementWithName:@"token" stringValue:app.configureList[APP_USER_TOKEN]]];
    [iq addChild:notification];
    
    return iq;
}


@end
