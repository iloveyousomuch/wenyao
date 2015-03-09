//
//  Categorys.m
//  quanzhi
//
//  Created by Meng on 14-1-9.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "Categorys.h"
#import <objc/runtime.h>

@implementation UIView (Postion)
-(CGFloat)FX {return self.frame.origin.x;}
-(CGFloat)FY {return self.frame.origin.y;}
-(CGFloat)FW {return self.frame.size.width;}
-(CGFloat)FH {return self.frame.size.height;}
-(CGFloat)BX {return self.bounds.origin.x;}
-(CGFloat)BY {return self.bounds.origin.y;}
-(CGFloat)BW {return self.bounds.size.width;}
-(CGFloat)BH {return self.bounds.size.height;}

-(CGFloat)EX {return self.frame.origin.x + self.frame.size.width;}
-(CGFloat)EY {return self.frame.origin.y + self.frame.size.height;}

-(void)setFX:(CGFloat)FX {CGRect frame=self.frame;frame.origin.x=FX;self.frame=frame;}
-(void)setFY:(CGFloat)FY {CGRect frame=self.frame;frame.origin.y=FY;self.frame=frame;}
-(void)setFW:(CGFloat)FW {CGRect frame=self.frame;frame.size.width=FW;self.frame=frame;}
-(void)setFH:(CGFloat)FH {CGRect frame=self.frame;frame.size.height=FH;self.frame=frame;}
-(void)setBX:(CGFloat)BX {CGRect frame=self.bounds;frame.origin.x=BX;self.bounds=frame;}
-(void)setBY:(CGFloat)BY {CGRect frame=self.bounds;frame.origin.y=BY;self.bounds=frame;}
-(void)setBW:(CGFloat)BW {CGRect frame=self.bounds;frame.size.width=BW;self.bounds=frame;}
-(void)setBH:(CGFloat)BH {CGRect frame=self.bounds;frame.size.height=BH;self.bounds=frame;}
@end

@implementation NSDictionary (MutableDeepCopy)
-(NSMutableDictionary *)mutableDeepCopy
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithCapacity:[self count]];
    NSArray *keys=[self allKeys];
    for(id key in keys)
    {
        id value=[self objectForKey:key];
        id copyValue = nil;
        if ([value respondsToSelector:@selector(mutableDeepCopy)]) {
            //如果key对应的元素可以响应mutableDeepCopy方法(还是NSDictionary)，调用mutableDeepCopy方法复制
            copyValue=[value mutableDeepCopy];
        } else if([value isKindOfClass:[NSNumber class]]) {
            copyValue=[value copy];
        } else if([value respondsToSelector:@selector(mutableCopy)]) {
            copyValue=[value mutableCopy];
        }
        if(copyValue==nil)
            copyValue=[value copy];
        [dict setObject:copyValue forKey:key];
        
    }
    return dict;
}
@end


@implementation NSString (NoNullString)
- (NSString*)noNull
{
    return (self && ![self isEqual:[NSNull null]] ? self : @"");
}
@end


@implementation UIAlertView (Block)
static char key;
id oldDelegate = nil;

- (void)showWithBlock:(UIAlertViewButtonClick)block
{
    if (block) {
        //移除所有关联
        objc_removeAssociatedObjects(self);
        //创建关联
        objc_setAssociatedObject(self, &key, block, OBJC_ASSOCIATION_COPY);
        oldDelegate = self.delegate;
        self.delegate = self;
    }
    [self show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //获取关联的对象，通过关键字。
    UIAlertViewButtonClick block = objc_getAssociatedObject(self, &key);
    if (block) {
        block(buttonIndex);
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView  // before animation and showing view
{
    if ([oldDelegate respondsToSelector:@selector(willPresentAlertView:)]) {
        [oldDelegate performSelector:@selector(willPresentAlertView:) withObject:alertView];
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView;  // after animation
{
    if ([oldDelegate respondsToSelector:@selector(didPresentAlertView:)]) {
        [oldDelegate performSelector:@selector(didPresentAlertView:) withObject:alertView];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation
{
    if ([oldDelegate respondsToSelector:@selector(alertView: didDismissWithButtonIndex:)]) {
        [oldDelegate performSelector:@selector(alertView: didDismissWithButtonIndex:) withObject:alertView withObject:nil];
    }
}

@end


