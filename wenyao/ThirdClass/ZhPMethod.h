//
//  ZhPMethod.h
//  quanzhi
//
//  Created by Pan@QW on 14-6-6.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

@interface ZhPMethod : NSObject

@end

@interface InfoButton : UIButton

@property(nonatomic,retain)id info;

@end


BOOL isPhoneNumber(NSString* text);
BOOL isEmailAddress(NSString* text);
NSDate* str2date(NSString* strDate, NSString* dateFormat);
NSString* date2str(NSDate* date, NSString* dateFormat);
void dumpView(UIView* aView);
CGSize getTextSize(NSString* text, UIFont* font, CGFloat width);
UIImage* color2Image(UIColor* color);
void showShadow(UIView* view, CGSize size);
void showAlert(id msg);
UILabel* addLabelObjEx(UIView* view, NSArray* p);
UILabel* addLabelObj(UIView* view, NSArray* p);

#define RECT(x,y,w,h)       CGRectMake(x,y,w,h)
#define RECT_OBJ(x,y,w,h)   NSStringFromCGRect(RECT(x,y,w,h))
#define addDay(date, num)   [date dateByAddingTimeInterval:num*(24*3600)]
#define mainThread(f, o)    [self performSelectorOnMainThread:@selector(f) withObject:o waitUntilDone:YES]
#define mainThreadEx(t, f, o)    [t performSelectorOnMainThread:@selector(f) withObject:o waitUntilDone:YES]
#define IMG_VIEW(x)         [[UIImageView alloc] initWithImage:[UIImage imageNamed:x]]
#define NOTIF_ADD(n, f)     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(f) name:n object:nil]
#define NOTIF_POST(n, o)    [[NSNotificationCenter defaultCenter] postNotificationName:n object:o]
#define NOTIF_REMV()        [[NSNotificationCenter defaultCenter] removeObserver:self]
#define isEmptyStr(x)       (!x || [x isEqual:[NSNull null]] || [x isEqualToString:@""])

UIView* getParentView(UIView* view, Class parentClass);
#define parentView(v, className) (className*)getParentView(v, [className class])
UITableViewCell* parentCell(UIView* view);
NSIndexPath* parentCellIndexPath(UIView* view);
BOOL isEqualCoordinate(CLLocationCoordinate2D acoor, CLLocationCoordinate2D bcoor, CGFloat jd);

@interface Notice : NSObject
+ (Notice*)shared;
- (void)add:(NSString*)text;
@end
#define showNotice(txt) [[Notice shared] add:txt]

