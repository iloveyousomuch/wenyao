//
//  TQRichTextEmojiRun.m
//  TQRichTextViewDemo
//
//  Created by fuqiang on 13-9-21.
//  Copyright (c) 2013年 fuqiang. All rights reserved.
//

#import "TQRichTextEmojiRun.h"
#import "Constant.h"

@implementation TQRichTextEmojiRun

- (id)init
{
    self = [super init];
    if (self) {
        self.type = richTextEmojiRunType;
        self.isResponseTouch = NO;
    }
    return self;
}

- (BOOL)drawRunWithRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSString *emojiString = [NSString stringWithFormat:@"%@.png",self.originalText];
    
    UIImage *image = [UIImage imageNamed:emojiString];
    if (image)
    {
        CGContextDrawImage(context, rect, image.CGImage);
    }
    return YES;
}

+ (NSArray *) emojiStringArray
{
    return [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"faceMap_ch" ofType:@"plist"]];
}

+ (NSString *)analyzeText:(NSString *)string runsArray:(NSMutableArray **)runArray
{
    NSMutableString *copyString = [NSMutableString stringWithString:string];
    NSRegularExpression *regExp = [[NSRegularExpression alloc] initWithPattern:
                                   EmotionItemPattern options:NSRegularExpressionCaseInsensitive
                                                                         error:nil];
    NSArray *result = [regExp matchesInString:string options:
                       NSMatchingReportCompletion range:
                       NSMakeRange(0, [string length])];
    NSUInteger count = [result count];
    if (0 == count)
        return copyString;
    [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSRange aRange = [obj range];
        NSString *emojiString = [string substringWithRange:aRange];
        aRange.location -= idx * 3;
        [copyString replaceCharactersInRange:aRange withString:PlaceHolder];
        aRange.length = 1;
        TQRichTextEmojiRun *emoji = [[TQRichTextEmojiRun alloc] init];
        emoji.range = aRange;
        emoji.originalText = emojiString;
        if(runArray)
            [*runArray addObject:emoji];
    }];
    return copyString;
}

//+ (NSString *)analyzeText:(NSString *)string runsArray:(NSMutableArray **)runArray
//{
//    NSString *markL = @"[";
//    NSString *markR = @"]";
//    NSMutableArray *stack = [[NSMutableArray alloc] init];
//    NSMutableString *newString = [[NSMutableString alloc] initWithCapacity:string.length];
//    //偏移索引 由于会把长度大于1的字符串替换成一个空白字符。这里要记录每次的偏移了索引。以便简历下一次替换的正确索引
//    int offsetIndex = 0;
//    for (int i = 0; i < string.length; i++)
//    {
//        NSString *s = [string substringWithRange:NSMakeRange(i, 1)];
//        if (([s isEqualToString:markL]) || ((stack.count > 0) && [stack[0] isEqualToString:markL]))
//        {
//            if (([s isEqualToString:markL]) && ((stack.count > 0) && [stack[0] isEqualToString:markL]))
//            {
//                for (NSString *c in stack)
//                {
//                    [newString appendString:c];
//                }
//                [stack removeAllObjects];
//            }
//            
//            [stack addObject:s];
//            
//            if ([s isEqualToString:markR] || (i == string.length - 1))
//            {
//                NSMutableString *emojiStr = [[NSMutableString alloc] init];
//                for (NSString *c in stack)
//                {
//                    [emojiStr appendString:c];
//                }
//                
//                if ([[TQRichTextEmojiRun emojiStringArray] containsObject:emojiStr])
//                {
//                    TQRichTextEmojiRun *emoji = [[TQRichTextEmojiRun alloc] init];
//                    emoji.range = NSMakeRange(i + 1 - emojiStr.length - offsetIndex, 1);
//                    emoji.originalText = emojiStr;
//                    [*runArray addObject:emoji];
//                    [newString appendString:@" "];
//                    
//                    offsetIndex += emojiStr.length - 1;
//                }
//                else
//                {
//                    [newString appendString:emojiStr];
//                }
//                [stack removeAllObjects];
//            }
//        }
//        else
//        {
//            [newString appendString:s];
//        }
//    }
//
//    return newString;
//}

@end
