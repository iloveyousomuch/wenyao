//
//  ZhPMethod.m
//  quanzhi
//
//  Created by Pan@QW on 14-6-6.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "ZhPMethod.h"
#import "Constant.h"
#import "Categorys.h"
#import "NSTimer+Blocks.h"

@implementation ZhPMethod

@end

@implementation InfoButton
@end


BOOL isPhoneNumber(NSString* text)
{
    
    
    //NSString *regex = @"[0-9]{11}";
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    NSString * regex = @"^([1])([0-9]{10})$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([predicate evaluateWithObject:text]) {
        return YES;
    }
    return NO;
}

BOOL isEmailAddress(NSString* text)
{
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([predicate evaluateWithObject:text]) {
        return YES;
    }
    return NO;
}

NSDate* str2date(NSString* strDate, NSString* dateFormat)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [dateFormatter setDateFormat:dateFormat];
    NSDate *resdate = [dateFormatter dateFromString:strDate];
    return resdate;
}

NSString* date2str(NSDate* date, NSString* dateFormat)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [dateFormatter setDateFormat:dateFormat];
    NSString* strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

void getViews(UIView* aView, int indent, NSMutableString* outString)
{
    for (int i = 0; i < indent; i++) {
        [outString appendString:@"--"];
    }
    
    //if (!aView.hidden)
    {
        //[outString appendFormat:@"[%d] %@\n", indent, [[aView class] description]];
        [outString appendFormat:@"[%d] %@ %@ (%d)\n", indent, [[aView class] description],
         NSStringFromCGRect(aView.frame), aView.tag];
    }
    
    
    
    for (UIView *view in [aView subviews]) {
        getViews(view, indent+1, outString);
    }
}

void dumpView(UIView* aView)
{
    NSMutableString *outString = [[NSMutableString alloc] init];
    getViews(aView, 0, outString);
}

CGSize getTextSize(NSString* text, UIFont* font, CGFloat width)
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 5000)];
    label.font = font;
    label.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    label.numberOfLines = 0;
    label.text = text;
    [label sizeToFit];
    return label.frame.size;
}

UIImage* color2Image(UIColor* color)
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage*theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

void showShadow(UIView* view, CGSize size)
{
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = size;
    view.layer.shadowOpacity = 0.4;
    view.layer.shadowRadius = 1;
}

void showAlert(id msg)
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:[NSString stringWithFormat:@"%@", msg]
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

//p: tag, frame, textColor, font, Text
UILabel* addLabelObjEx(UIView* view, NSArray* p)
{
    NSInteger tag = [p[0] integerValue];
    CGRect frame = CGRectFromString(p[1]);
    
    UILabel* label = (UILabel*)[view viewWithTag:tag];
    if (label == nil) {
        label = [[UILabel alloc] initWithFrame:frame];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = p[2];
        label.font = p[3];
        label.tag = tag;
        label.text = p[4];
        //label.layer.borderWidth = 0.5;
        label.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
        label.numberOfLines = 0;
        [view addSubview:label];
        
        return (UILabel*)[view viewWithTag:tag];
    }
    
    label.frame = frame;
    label.textColor = p[2];
    label.font = p[3];
    label.text = p[4];
    
    return label;
}

//p: tag, frame, textColor, font
UILabel* addLabelObj(UIView* view, NSArray* p)
{
    NSInteger tag = [p[0] integerValue];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectFromString(p[1])];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = p[2];
    label.font = p[3];
    label.tag = tag;
    label.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    label.numberOfLines = 0;
    //label.layer.borderWidth = 0.5;
    [view addSubview:label];

    return (UILabel*)[view viewWithTag:tag];
}


UIView* getParentView(UIView* view, Class parentClass)
{
    UIView* superView = view;
    while ( superView!=nil ) {
        if ( [superView isKindOfClass:parentClass] ) {
            return (UIView*)superView;
        }
        superView = superView.superview;
    }
    return nil;
}

UITableViewCell* parentCell(UIView* view)
{
    return parentView(view, UITableViewCell);
}

NSIndexPath* parentCellIndexPath(UIView* view)
{
    UITableViewCell* cell = parentView(view, UITableViewCell);
    if (cell) {
        UITableView* table = parentView(cell, UITableView);
        if (table) {
            return [table indexPathForCell:cell];
        }
    }
    return nil;
}

BOOL isEqualCoordinate(CLLocationCoordinate2D acoor, CLLocationCoordinate2D bcoor, CGFloat jd)
{
    if ((ABS(acoor.latitude-bcoor.latitude) < jd) &&
        (ABS(acoor.longitude-bcoor.longitude) < jd)) {
            return YES;
        }
    return NO;
}


#define NOTICE_BOX_TAG  55326
#define TXT_EDGE        5
#define MAX_EDGE        30
#define MAX_WIDTH       (APP_W - MAX_EDGE*2)
@interface Notice ()
{
    NSMutableArray* list;
    UIView* bgview;
    UIView* blackView;
    UILabel* label;
}
@end

@implementation Notice

+ (Notice*)shared
{
    static Notice* p = nil;
    if (!p) {
        p = [[Notice alloc] init];
    }
    return p;
}

- (id)init
{
    if (self = [super init]) {
        list = [[NSMutableArray alloc] init];
        bgview = [[UIView alloc] initWithFrame:CGRectZero];
        bgview.backgroundColor = [UIColor clearColor];
        bgview.hidden = YES;
        [[UIApplication sharedApplication].keyWindow addSubview:bgview];
        
        blackView = [[UIView alloc] initWithFrame:CGRectZero];
        blackView.layer.backgroundColor = COLOR(42, 42, 42).CGColor;
        blackView.layer.cornerRadius = 3;
        blackView.alpha = 0.8;
        showShadow(blackView, CGSizeMake(1, 1));
        [bgview addSubview:blackView];
        
        label = addLabelObj(bgview, @[@(NOTICE_BOX_TAG+1), RECT_OBJ(0, 0, 0, 0), COLOR(255, 255, 255), Font(12)]);
    }
    return  self;
}

- (void)add:(NSString*)text
{
    [list addObject:text];
    
    if (bgview.hidden) {
        [self show];
    }
}

- (void)show
{
    if (list.count == 0) return;
    
    CGFloat spc = 4;
    
    CGFloat h = getTextSize(list[0], Font(12), MAX_WIDTH).height;
    label.frame = RECT(spc+TXT_EDGE, spc+TXT_EDGE, MAX_WIDTH, h);
    label.text = list[0];
    [label sizeToFit];
    [list removeObjectAtIndex:0];
    
    CGFloat vw = TXT_EDGE + label.FW + TXT_EDGE + spc*2;
    CGFloat vh = TXT_EDGE + label.FH + TXT_EDGE + spc*2;
    bgview.frame = RECT((APP_W-vw)*0.5, (APP_H-vh)*0.8, vw, vh);
    blackView.frame = RECT(spc, spc, vw-spc*2, vh-spc*2);
    
    bgview.alpha = 1;
    bgview.hidden = NO;
    
    [NSTimer scheduledTimerWithTimeInterval:2 block:^{
        [UIView animateWithDuration:0.3 animations:^{
            bgview.alpha = 0;
        } completion:^(BOOL finished) {
            bgview.hidden = YES;
            if (list.count > 0) {
                mainThread(show, nil);
            }
        }];
    } repeats:NO];
}

@end