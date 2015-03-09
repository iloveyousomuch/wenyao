//
//  TQRichTextURLRun.h
//  TQRichTextViewDemo
//
//  Created by fuqiang on 13-9-23.
//  Copyright (c) 2013年 fuqiang. All rights reserved.
//

#import "TQRichTextBaseRun.h"

typedef enum  {
    URLText = 1,
    EMAILText = 2,
    TELEPHONEText = 3
} HyperLinkType;


@interface TQRichTextURLRun : TQRichTextBaseRun

+ (NSString *)analyzeText:(NSString *)string runsArray:(NSMutableArray **)array;
+ (NSString *)analyzeTelephone:(NSString *)string runsArray:(NSMutableArray  **)runArray;
+ (NSString *)analyzeEmailAddress:(NSString *)string runsArray:(NSMutableArray  **)runArray;
+ (HyperLinkType)analyzeStringType:(NSString *)string;


@end
