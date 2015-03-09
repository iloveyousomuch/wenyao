//
//  CusAnnotationView.m
//  MAMapKit_static_demo
//
//  Created by songjian on 13-10-16.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "CusAnnotationView.h"
#import "CustomCalloutView.h"
#import "Constant.h"
#import "ZhPMethod.h"
#import "MySelfTapGestureRecognizer.h"


//#define kWidth  150.f
//#define kHeight 60.f
#define kWidth  21.f
#define kHeight 32.f

#define kHoriMargin 5.f
#define kVertMargin 5.f

#define kPortraitWidth  50.f
#define kPortraitHeight 50.f

#define kCalloutWidth   200.0
#define kCalloutHeight  70.0

@interface CusAnnotationView ()

@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic, strong) UILabel *nameLabel;
/**
 *  标注的背景色 蓝色 or  红色
 */
@property (nonatomic ,strong) UIImage *bgImage;
@end

@implementation CusAnnotationView

@synthesize calloutView;
@synthesize portraitImageView   = _portraitImageView;
@synthesize nameLabel           = _nameLabel;

#pragma mark - Handle Action

- (void)btnAction:(MySelfTapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(callOutViewStore:)]) {
        [self.delegate callOutViewStore:tap.storeDic];
    }
}

#pragma mark - Override

- (NSString *)name
{
    return self.nameLabel.text;
}

- (void)setName:(NSString *)name
{
    self.nameLabel.text = name;
}

- (UIImage *)portrait
{
    return self.portraitImageView.image;
}

- (void)setPortrait:(UIImage *)portrait
{
    self.portraitImageView.image = portrait;
}

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected)
    {
        return;
    }
    
    if (selected)
    {
        if (self.calloutView   == nil)
        {
            //地图-气泡-选中@2x.png
            
            if (self.annType == 1) {
                self.bgImage = [UIImage imageNamed:@"地图-气泡-选中.png"];
            }else if (self.annType == 2){
                self.bgImage = [UIImage imageNamed:@"地图-气泡-小-选中.png"];
            }
            
            NSString * title = self.storeDic[@"name"];//240
            CGSize size = getTextSize(title, Font(16), APP_W-20);
            if (size.width > 240) {
                size = getTextSize(title, Font(16), 240);
            }
            UIView * bgView = [[UIView alloc] init];
            bgView.userInteractionEnabled = YES;
            
            CGFloat height = 8;
            UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, height, size.width, size.height)];
            label.text = title;
            label.numberOfLines = 0;
            label.textColor = [UIColor whiteColor];
            label.font = Font(16);
            [bgView addSubview:label];
            height += size.height + 8;
            
            UILabel * subLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, label.frame.origin.y + label.frame.size.height + 8, size.width, 12)];
            subLabel.text = @"详情>>";
            subLabel.textColor = [UIColor whiteColor];
            subLabel.font = Font(14);
            [bgView addSubview:subLabel];
            height += 12 + 8;
            
            [bgView setFrame:CGRectMake(0, 0, size.width + 20, height)];
            
            
            MySelfTapGestureRecognizer * tap = [[MySelfTapGestureRecognizer alloc] init];
            tap.storeDic = self.storeDic;
            [bgView addGestureRecognizer:tap];
            [tap addTarget:self action:@selector(btnAction:)];
            
            
            /* Construct custom callout. */
            self.calloutView = [[CustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, bgView.frame.size.width, bgView.frame.size.height + 10)];
            
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,-CGRectGetHeight(self.calloutView.bounds) / 2.f);
            // + self.calloutOffset.y
            [self.calloutView addSubview:bgView];
            
            CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
            popAnimation.duration = 0.4;
            popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                                    [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                                    [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                                    [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
            popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [self.calloutView.layer addAnimation:popAnimation forKey:nil];
        }
        
        [self addSubview:self.calloutView];
    }
    else
    {
        if (self.annType == 1) {
            self.bgImage = [UIImage imageNamed:@"地图-气泡.png"];
        }else if (self.annType == 2){
            self.bgImage = [UIImage imageNamed:@"地图-气泡-小.png"];
        }
        
        [self.calloutView removeFromSuperview];
        self.calloutView = nil;
    }
    
    [super setSelected:selected animated:animated];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL inside = [super pointInside:point withEvent:event];
    /* Points that lie outside the receiver’s bounds are never reported as hits, 
     even if they actually lie within one of the receiver’s subviews. 
     This can occur if the current view’s clipsToBounds property is set to NO and the affected subview extends beyond the view’s bounds.
     */
    if (!inside && self.selected)
    {
        inside = [self.calloutView pointInside:[self convertPoint:point toView:self.calloutView] withEvent:event];
    }
    
    return inside;
}

#pragma mark - Life Cycle

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        
        self.backgroundColor = [UIColor clearColor];
        UIImage * redImage = [UIImage imageNamed:@"point_red.png"];
        //self.bounds = RECT(0, 0, redImage.size.width*2, redImage.size.height*2);
        //[self setImage:redImage];
        self.iconView = [[UIImageView alloc] init];
        self.iconView.userInteractionEnabled = YES;
        [self.iconView setImage:redImage];
        [self addSubview:self.iconView];
        
        self.tagLabel = [[UILabel alloc] init];
        self.tagLabel.backgroundColor = [UIColor clearColor];
        self.tagLabel.text = @"A";
        self.tagLabel.font = FontB(15);
        self.tagLabel.textColor = [UIColor whiteColor];
        self.tagLabel.textAlignment = NSTextAlignmentCenter;
        [self.iconView addSubview:self.tagLabel];
        
        /* Create portrait image view and add to view hierarchy. */
        
        /* Create name label. */
    }
    
    return self;
}

- (void)setBgImage:(UIImage *)bgImage
{
    _bgImage = bgImage;
    self.bounds = CGRectMake(0.f, 0.f, bgImage.size.width*2, bgImage.size.height*2);
    [self.iconView setImage:bgImage];
    [self.iconView setFrame:RECT(0, 0, bgImage.size.width*2, bgImage.size.height*2)];
    [self.tagLabel setFrame:RECT(0, 0, bgImage.size.width*2, bgImage.size.height*2-11)];
}

- (void)setAnnType:(NSInteger)annType
{
    _annType = annType;
    if (annType == 1) {
        self.bgImage = [UIImage imageNamed:@"地图-气泡.png"];
    }else if (annType == 2){
        self.bgImage = [UIImage imageNamed:@"地图-气泡-小.png"];
    }
}

@end
