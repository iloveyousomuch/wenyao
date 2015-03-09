//
//  XHMessageBubbleFactory.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-4-25.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHMessageBubbleFactory.h"
#import "XHMacro.h"

@implementation XHMessageBubbleFactory

+ (UIImage *)bubbleImageViewForOfficialType:(XHBubbleMessageType)type
{
    NSString *messageTypeString = nil;
    if(type == XHBubbleMessageTypeSending) {
        messageTypeString = @"weChatBubble_Sending_Solid_无角.png";
    }else{
        messageTypeString = @"weChatBubble_Receiving_Solid_无角.png";
    }
    
    UIImage *bublleImage = [UIImage imageNamed:messageTypeString];
    UIEdgeInsets bubbleImageEdgeInsets = [self bubbleImageEdgeInsetsWithStyle:XHBubbleImageViewStyleWeChat];
    return XH_STRETCH_IMAGE(bublleImage, bubbleImageEdgeInsets);
}


+ (UIImage *)bubbleImageViewForType:(XHBubbleMessageType)type
                                  style:(XHBubbleImageViewStyle)style
                              meidaType:(XHBubbleMessageMediaType)mediaType {
    NSString *messageTypeString;
    
    switch (style) {
        case XHBubbleImageViewStyleWeChat:
            // 类似微信的
            messageTypeString = @"weChatBubble";
            break;
        default:
            break;
    }
    
    switch (type) {
        case XHBubbleMessageTypeSending:
            // 发送
            messageTypeString = [messageTypeString stringByAppendingString:@"_Sending"];
            break;
        case XHBubbleMessageTypeReceiving:
            // 接收
            messageTypeString = [messageTypeString stringByAppendingString:@"_Receiving"];
            break;
        default:
            break;
    }
    
    switch (mediaType) {

        case XHBubbleMessageMediaTypeText:
        case XHBubbleMessageMediaTypeStarStore:
        case XHBubbleMessageMediaTypeStarClient:
            messageTypeString = [messageTypeString stringByAppendingString:@"_Solid"];
            break;
        case XHBubbleMessageMediaTypeAutoSubscription:
        case XHBubbleMessageMediaTypeDrugGuide:
        case XHBubbleMessageMediaTypePurchaseMedicine:
            messageTypeString = [messageTypeString stringByAppendingString:@"_Solid"];
            break;
        case XHBubbleMessageMediaTypeActivity:
        case XHBubbleMessageMediaTypeLocation:
            messageTypeString = @"weChatBubble_Sending_Solid_Activity.png";
            break;
        default:
            break;
    }
    
    
    UIImage *bublleImage = [UIImage imageNamed:messageTypeString];
    UIEdgeInsets bubbleImageEdgeInsets = [self bubbleImageEdgeInsetsWithStyle:style];
    return XH_STRETCH_IMAGE(bublleImage, bubbleImageEdgeInsets);
}

+ (UIEdgeInsets)bubbleImageEdgeInsetsWithStyle:(XHBubbleImageViewStyle)style {
    UIEdgeInsets edgeInsets;
    switch (style) {
        case XHBubbleImageViewStyleWeChat:
            // 类似微信的
            edgeInsets = UIEdgeInsetsMake(30, 28, 85, 28);
            break;
        default:
            break;
    }
    return edgeInsets;
}

@end
