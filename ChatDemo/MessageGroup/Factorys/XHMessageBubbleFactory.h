//
//  XHMessageBubbleFactory.h
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-4-25.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, XHBubbleMessageType) {
    XHBubbleMessageTypeSending = 0,
    XHBubbleMessageTypeReceiving
};

typedef NS_ENUM(NSUInteger, XHBubbleImageViewStyle) {
    XHBubbleImageViewStyleWeChat = 0
};

typedef NS_ENUM(NSInteger, XHBubbleMessageMediaType) {
    XHBubbleMessageMediaTypeText = 1,
    XHBubbleMessageMediaTypePhoto = 2,
    XHBubbleMessageMediaTypeStarStore = 3,
    XHBubbleMessageMediaTypeQuitout = 4,
    XHBubbleMessageMediaTypeActivity = 5,
    XHBubbleMessageMediaTypeStarClient = 6,
    XHBubbleMessageMediaTypeAutoSubscription = 7,
    XHBubbleMessageMediaTypeDrugGuide = 8,
    XHBubbleMessageMediaTypePurchaseMedicine = 9,
    XHBubbleMessageMediaTypeLocation = 10,
    XHBubbleMessageMediaTypeVoice = 11,
    XHBubbleMessageMediaTypeEmotion = 12,
    XHBubbleMessageMediaTypeLocalPosition = 13,
    
};

typedef NS_ENUM(NSInteger, XHBubbleMessageMenuSelecteType) {
    XHBubbleMessageMenuSelecteTypeTextCopy = 0,
    XHBubbleMessageMenuSelecteTypeTextTranspond = 1,
    XHBubbleMessageMenuSelecteTypeTextFavorites = 2,
    XHBubbleMessageMenuSelecteTypeTextMore = 3,
    
    XHBubbleMessageMenuSelecteTypePhotoCopy = 4,
    XHBubbleMessageMenuSelecteTypePhotoTranspond = 5,
    XHBubbleMessageMenuSelecteTypePhotoFavorites = 6,
    XHBubbleMessageMenuSelecteTypePhotoMore = 7,
    
    XHBubbleMessageMenuSelecteTypeVideoTranspond = 8,
    XHBubbleMessageMenuSelecteTypeVideoFavorites = 9,
    XHBubbleMessageMenuSelecteTypeVideoMore = 10,
    
    XHBubbleMessageMenuSelecteTypeVoicePlay = 11,
    XHBubbleMessageMenuSelecteTypeVoiceFavorites = 12,
    XHBubbleMessageMenuSelecteTypeVoiceTurnToText = 13,
    XHBubbleMessageMenuSelecteTypeVoiceMore = 14,
};

@interface XHMessageBubbleFactory : NSObject

+ (UIImage *)bubbleImageViewForType:(XHBubbleMessageType)type
                                  style:(XHBubbleImageViewStyle)style
                              meidaType:(XHBubbleMessageMediaType)mediaType;

+ (UIImage *)bubbleImageViewForOfficialType:(XHBubbleMessageType)type;

@end
