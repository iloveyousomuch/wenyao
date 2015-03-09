//
//  XHMessageModel.h
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-4-24.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "XHMessageBubbleFactory.h"

@class XHMessage;

@protocol XHMessageModel <NSObject>

@required
- (NSString *)text;
- (NSString *)richBody;
- (UIImage *)photo;
- (NSString *)thumbnailUrl;
- (NSString *)originPhotoUrl;

- (UIImage *)videoConverPhoto;
- (NSString *)videoPath;
- (NSString *)videoUrl;

- (NSString *)voicePath;
- (NSString *)voiceUrl;
- (NSString *)voiceDuration;
- (NSString *)UUID;
- (UIImage *)localPositionPhoto;
- (NSString *)geolocations;
- (CLLocation *)location;
- (CGFloat)starMark;
- (NSString *)emotionPath;
- (NSInteger)sended;
- (UIImage *)avator;
- (NSString *)avatorUrl;
- (CLLocation *)location;
- (NSString *)title;
- (NSString *)activityUrl;
- (NSArray *)tagList;
- (BOOL)officialType;
- (BOOL)isMarked;
- (XHBubbleMessageMediaType)messageMediaType;

- (XHBubbleMessageType)bubbleMessageType;

@optional

- (NSString *)sender;

- (NSDate *)timestamp;

@end

