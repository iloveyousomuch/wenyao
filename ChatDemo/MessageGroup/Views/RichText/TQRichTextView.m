//
//  TQRichTextView.m
//  TQRichTextViewDemo
//
//  Created by fuqiang on 13-9-12.
//  Copyright (c) 2013年 fuqiang. All rights reserved.
//

#import "TQRichTextView.h"
#import <CoreText/CoreText.h>
#import "TQRichTextEmojiRun.h"
#import "TQRichTextURLRun.h"
#import "Constant.h"

@implementation TQRichTextView
@synthesize typeSetter;

- (void)setup
{
    self.backgroundColor = [UIColor redColor];
    _text = @"";
    _font = [UIFont systemFontOfSize:16.0];
    _textColor = [UIColor blackColor];
    _lineSpacing = 0.5f;
    _richUrlRunsArray = [[NSMutableArray alloc] init];
    _richTextRunsArray = [[NSMutableArray alloc] init];
    _richEmailRunsArray = [[NSMutableArray alloc] init];
    _richPhoneRunsArray = [[NSMutableArray alloc] init];
    _richTextRunRectDic = [[NSMutableDictionary alloc] init];
}

-(id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Draw Rect
- (void)drawRect:(CGRect)rect
{
    //要绘制的文本
        //绘图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //修正坐标系
    CGAffineTransform textTran = CGAffineTransformIdentity;
    textTran = CGAffineTransformMakeTranslation(0.0, self.bounds.size.height);
    textTran = CGAffineTransformScale(textTran, 1.0, -1.0);
    CGContextConcatCTM(context, textTran);
    //绘制

    CFRange lineRange = CFRangeMake(0,0);
    
    float drawLineX = 0;
    float drawLineY = self.bounds.origin.y + self.bounds.size.height - self.font.ascender;
    BOOL drawFlag = YES;
    while(drawFlag)
    {
        NSLog(@"宽度 %f",self.bounds.size.width);
        CFIndex testLineLength = CTTypesetterSuggestLineBreak(typeSetter,lineRange.location,self.bounds.size.width);
check:  lineRange = CFRangeMake(lineRange.location,testLineLength);
        CTLineRef line = CTTypesetterCreateLine(typeSetter,lineRange);
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        
        //边界检查
        CTRunRef lastRun = CFArrayGetValueAtIndex(runs, CFArrayGetCount(runs) - 1);
        CGFloat lastRunAscent;
        CGFloat laseRunDescent;
        CGFloat lastRunWidth  = CTRunGetTypographicBounds(lastRun, CFRangeMake(0,0), &lastRunAscent, &laseRunDescent, NULL);
        CGFloat lastRunPointX = drawLineX + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(lastRun).location, NULL);
        
        if ((lastRunWidth + lastRunPointX) > self.bounds.size.width)
        {
            testLineLength--;
            CFRelease(line);
goto check;
        }
        //绘制普通行元素
        drawLineX = CTLineGetPenOffsetForFlush(line,0,self.bounds.size.width);
        CGContextSetTextPosition(context,drawLineX,drawLineY);
        CTLineDraw(line,context);
        
        //绘制替换过的特殊文本单元
        for (int i = 0; i < CFArrayGetCount(runs); i++)
        {
            CTRunRef run = CFArrayGetValueAtIndex(runs, i);
            NSDictionary* attributes = (__bridge NSDictionary*)CTRunGetAttributes(run);
            TQRichTextBaseRun *textRun = [attributes objectForKey:@"TQRichTextAttribute"];
            if (textRun)
            {
                CGFloat runAscent,runDescent;
                CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
                CGFloat runPointX = drawLineX + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                CGFloat runPointY = drawLineY - (-runDescent);
                CGRect runRect;
                if([_font pointSize] > 16.8)
                    runRect = CGRectMake(runPointX, runPointY,22.5, 22.5);
                else
                    runRect = CGRectMake(runPointX, runPointY,18.5, 18.5);
                [textRun drawRunWithRect:runRect];

            }
            TQRichTextBaseRun *hyperlink = [attributes objectForKey:kHyperlinkKey];
            if(hyperlink)
            {
                CGFloat runAscent,runDescent;
                CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
                CGFloat runPointX = drawLineX + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                CGFloat runPointY = drawLineY - (-runDescent);
                CGRect runRect = CGRectMake(runPointX - 2.5, runPointY - 2.5, width + 5, runAscent - runDescent + 5);
                [self.richTextRunRectDic setObject:hyperlink forKey:[NSValue valueWithCGRect:runRect]];
            }
        }
        CFRelease(line);
        if(lineRange.location + lineRange.length >= self.textAnalyzed.length)
        {
            drawFlag = NO;
        }
        drawLineY -= self.font.ascender + (- self.font.descender) + self.lineSpacing;
        lineRange.location += lineRange.length;
    }
}

#pragma mark - Analyze Text
//-- 解析文本内容
- (NSString *)analyzeText:(NSString *)string
{
    [self.richTextRunsArray removeAllObjects];
    [self.richUrlRunsArray removeAllObjects];
    [self.richPhoneRunsArray removeAllObjects];
    [self.richEmailRunsArray removeAllObjects];
    [self.richTextRunRectDic removeAllObjects];
    NSString *result = @"";
    NSMutableArray *array = self.richTextRunsArray;
    result = [TQRichTextEmojiRun analyzeText:string runsArray:&array];
    array = self.richUrlRunsArray;
    [TQRichTextURLRun analyzeText:result runsArray:&array];
    array = self.richPhoneRunsArray;
    [TQRichTextURLRun analyzeTelephone:result runsArray:&array];
    array = self.richEmailRunsArray;
    [TQRichTextURLRun analyzeEmailAddress:result runsArray:&array];
    [self.richTextRunsArray makeObjectsPerformSelector:@selector(setOriginalFont:) withObject:self.font];

    return result;
    
}

#pragma mark -
#pragma mark TouchEvent
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [(UITouch *)[touches anyObject] locationInView:self];
    CGPoint runLocation = CGPointMake(location.x, self.frame.size.height - location.y);
    
    if (self.delegage && [self.delegage respondsToSelector:@selector(richTextView: touchBeginRun:)])
    {
        __weak TQRichTextView *weakSelf = self;
        [self.richTextRunRectDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             CGRect rect = [((NSValue *)key) CGRectValue];
             TQRichTextBaseRun *run = obj;
             if(CGRectContainsPoint(rect, runLocation))
             {
                 [weakSelf.delegage richTextView:weakSelf touchBeginRun:run];
             }
        }];
    }
}

//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    CGPoint location = [(UITouch *)[touches anyObject] locationInView:self];
//    CGPoint runLocation = CGPointMake(location.x, self.frame.size.height - location.y);
//    
//    if (self.delegage && [self.delegage respondsToSelector:@selector(richTextView: touchEndRun:)])
//    {
//        [self.richTextRunRectDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
//         {
//             __weak TQRichTextView *weakSelf = self;
//             CGRect rect = [((NSValue *)key) CGRectValue];
//             TQRichTextBaseRun *run = obj;
//             if(CGRectContainsPoint(rect, runLocation))
//             {
//                 [weakSelf.delegage richTextView:weakSelf touchEndRun:run];
//             }
//         }];
//    }
//}

#pragma mark - Set
- (void)setText:(NSString *)text
{
    if(![_text isEqualToString:text])
    {
        _text = text;
        //@"wwwww[ha]wwwwwwwwwwwww"
        _textAnalyzed =@"wwwww wwwwwwwwwwww";//[self analyzeText:_text];
        
        NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:self.textAnalyzed];
        //设置字体
        CTFontRef aFont = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, self.font.pointSize, NULL);
        [attString addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)aFont range:NSMakeRange(0,attString.length)];
        CFRelease(aFont);
        //设置颜色
        [attString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)self.textColor.CGColor range:NSMakeRange(0,attString.length)];
        //文本处理
        for (TQRichTextBaseRun *textRun in self.richTextRunsArray)
        {
            [textRun replaceTextWithAttributedString:attString];
        }
        [self addAttributeWithAttString:attString rangArray:self.richPhoneRunsArray];
        [self addAttributeWithAttString:attString rangArray:self.richEmailRunsArray];
        [self addAttributeWithAttString:attString rangArray:self.richUrlRunsArray];
        if(typeSetter){
            CFRelease(typeSetter);typeSetter = NULL;
        }
        typeSetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attString);
        [self setNeedsDisplay];
    }
}

-(void)addAttributeWithAttString:(NSMutableAttributedString *)attstring rangArray:(NSArray *)rangeArray
{
    for (TQRichTextBaseRun *textRun in rangeArray)
    {
        [attstring addAttribute:(id)kCTUnderlineStyleAttributeName value:(id)[NSNumber numberWithInt:kCTUnderlineStyleSingle] range:textRun.range];
        [attstring addAttribute:(id)kCTUnderlineColorAttributeName value:(id)[UIColor blueColor].CGColor range:textRun.range];
        [attstring addAttribute:(id)kCTForegroundColorAttributeName value:(id)[UIColor blueColor].CGColor range:textRun.range];
        [attstring addAttribute:kHyperlinkKey value:textRun range:textRun.range];
    }
}

- (void)setFont:(UIFont *)font
{
    _font = font;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [self setNeedsDisplay];
}

- (void)setLineSpacing:(float)lineSpacing
{
    _lineSpacing = lineSpacing;
    [self setNeedsDisplay];
}

-(void)dealloc
{
    CFRelease(typeSetter);
}
@end
