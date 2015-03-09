//
//  AppGuide.m
//  quanzhi
//
//  Created by ZhongYun on 14-1-28.
//  Copyright (c) 2014年 ZhongYun. All rights reserved.
//

#import "AppGuide.h"
#import "PageControl.h"
#import "Constant.h"
#import "AppDelegate.h"


#define TAG_BASE            100000

#define OFFSET_H    (APP_H==460?0:46)
#define COMMON_DOT  COLOR(216, 168, 254)
#define ACTIVE_DOT  COLOR(118, 52, 176)
#define TAG(v)              (v>=TAG_BASE?v-TAG_BASE:v+TAG_BASE)



UIColor* getColor(UIImage* image, int x, int y)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = image.CGImage;
    CGFloat width =  CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  8,        //每个颜色值8bit
                                                  width*4, //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit
                                                  colorSpace,
                                                  (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    unsigned char *imgdata = CGBitmapContextGetData(context);
    if(imgdata == NULL){
        return [UIColor whiteColor];
    }
    UIColor* resColor = COLOR(imgdata[1], imgdata[2], imgdata[3]);
    CGContextRelease(context);
    CGColorSpaceRelease( colorSpace );
    
    return resColor;
}


@interface AppGuide()<UIScrollViewDelegate>
{
    UIScrollView* m_scrollView;
    PageControl* m_pageControl;
    
    UIView *m_viOne;
    UIView *m_viTwo;
}
@end

@implementation AppGuide

- (id)init
{
    CGRect frame = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        m_scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        m_scrollView.pagingEnabled = YES; //自动滚动到subview的边界
        //m_scrollView.bounces = NO; //拖动超出范围
        m_scrollView.showsHorizontalScrollIndicator = NO;
        m_scrollView.userInteractionEnabled = YES;
        m_scrollView.delegate = self;
        [self addSubview:m_scrollView];
        
        m_pageControl = [[PageControl alloc] init];
        if(HIGH_RESOLUTION) {
            m_pageControl.frame = CGRectMake((self.bounds.size.width-60)/2, 500+OFFSET_H, 60, 10);
        }else{
            m_pageControl.frame = CGRectMake((self.bounds.size.width-60)/2, 460 + OFFSET_H, 60, 10);
        }
        m_pageControl.commonColor = [UIColor lightGrayColor];
        m_pageControl.activeColor = APP_COLOR_STYLE;
        m_pageControl.commonImage = [UIImage imageNamed:@"dot01.png"];
        m_pageControl.activeImage = [UIImage imageNamed:@"dot11.png"];
        m_pageControl.backgroundColor = [UIColor clearColor];
        [self addSubview:m_pageControl];
    }
    return self;
}

- (void)dealloc
{
    [m_scrollView release];
    //[m_pageControl release];
    [super dealloc];
}

- (void)setImgNames:(NSArray *)imgNames
{
    [self clearImages];
    if (!imgNames || imgNames.count==0)
        return;
    _imgNames = [imgNames copy];
    [self buildScrollViewPics:imgNames];

    m_pageControl.numberOfPages = imgNames.count;
    m_pageControl.currentPage = 0;
    
    m_scrollView.contentOffset = CGPointMake(0, 0);
}

- (void)buildScrollViewPics:(NSArray*)imgNames
{

    
    for (int i = 0; i < imgNames.count; i++)
    {
        CGRect rect = CGRectMake(i*APP_W, 0, APP_W, self.bounds.size.height);

        UIImageView* imgbg = [[UIImageView alloc] initWithFrame:rect];
        imgbg.userInteractionEnabled = YES;
        imgbg.image = [UIImage imageNamed:imgNames[i]];
        [m_scrollView addSubview:imgbg];
        [imgbg release];
        
        UIImageView* imgPage = IMG_VIEW([imgNames objectAtIndex:i]);
        imgPage.frame = rect;
        //imgPage.backgroundColor = getColor([UIImage imageNamed:imgNames[i]], 0, 0);
        imgPage.contentMode = UIViewContentModeScaleAspectFit;
        imgPage.tag = TAG(i*2+0);
        imgPage.clipsToBounds = YES;
        [m_scrollView addSubview:imgPage];
        //+ self.frame.size.width * 2
        //+ self.frame.size.width * 2
        if (i == 2) {
            
        }
        [imgPage release];
    }
    CGRect rect = CGRectMake(0, 0, APP_W, self.bounds.size.height);
    UIImage* imgClose = [UIImage imageNamed:@"gBtnClose.png"];
    UIButton* btnClose = [[UIButton alloc] init];
    CGFloat y = 333 + OFFSET_H;
    CGFloat w = imgClose.size.width+40, h = imgClose.size.height+20;
    [btnClose addTarget:self action:@selector(onBtnCloseTouched:) forControlEvents:UIControlEventTouchUpInside];
    if(HIGH_RESOLUTION) {
        btnClose.frame = CGRectMake(100 + self.frame.size.width , y + 88, 120, 40);
    }else{
        btnClose.frame = CGRectMake(100 + self.frame.size.width , y + 73, 120, 40);
    }
    btnClose.layer.masksToBounds = YES;
    btnClose.layer.borderWidth = 1.0f;
    btnClose.layer.cornerRadius = 2.0f;
    btnClose.layer.borderColor = UIColorFromRGB(0x45c01a).CGColor;
    [btnClose setTitle:@"立即体验" forState:UIControlStateNormal];
    [btnClose setTitleColor:UIColorFromRGB(0x45c01a) forState:UIControlStateNormal];
    [btnClose setBackgroundColor:[UIColor clearColor]];
    btnClose.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    btnClose.alpha = 1.0;
    [m_scrollView addSubview:btnClose];
    [btnClose release];
    
    m_scrollView.contentSize = CGSizeMake(imgNames.count*self.frame.size.width, self.frame.size.height);
    m_scrollView.contentOffset = CGPointMake(0, 0);
}

- (void)onBtnCloseTouched:(UIButton*)sender
{
    //添加透明层
    m_viOne = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    m_viOne.alpha = 0;
    
    UIImageView *imageOne = [[UIImageView alloc] init];
    if(HIGH_RESOLUTION) {
        imageOne.frame = CGRectMake(0, 0, m_viOne.frame.size.width, m_viOne.frame.size.height);
        imageOne.image  = [UIImage imageNamed:@"浮层1-568.png"];
    }else{
        imageOne.frame = CGRectMake(0, 0, m_viOne.frame.size.width, m_viOne.frame.size.height);
        imageOne.image  = [UIImage imageNamed:@"浮层1-480.PNG"];
    }
    
    [m_viOne addSubview:imageOne];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFirstBgView)];
    [m_viOne addGestureRecognizer:tap];
    
    [[UIApplication sharedApplication].keyWindow addSubview:m_viOne];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        m_viOne.alpha = 0.8;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        
        
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"showGuide_%@",APP_VERSION]];
        [userDefault synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:APP_CHECK_VERSION object:nil];
    }];
}

- (void)dismissFirstBgView
{
    //添加透明层
    m_viTwo = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    m_viTwo.alpha = 0;
    
    UIImageView *imageTwo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, m_viTwo.frame.size.width, m_viTwo.frame.size.height)];
    if(HIGH_RESOLUTION) {
        imageTwo.frame = CGRectMake(0, 0, m_viTwo.frame.size.width, m_viTwo.frame.size.height);
        imageTwo.image  = [UIImage imageNamed:@"浮层2-568.png"];
    }else{
        imageTwo.frame = CGRectMake(0, 0, m_viTwo.frame.size.width, m_viTwo.frame.size.height);
        imageTwo.image  = [UIImage imageNamed:@"浮层2-480.PNG"];
    }
    
    imageTwo.alpha = 1;
    [m_viTwo addSubview:imageTwo];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSecondBgView)];
    [m_viTwo addGestureRecognizer:tap];
    
    [[UIApplication sharedApplication].keyWindow addSubview:m_viTwo];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        m_viOne.alpha = 0;
        m_viTwo.alpha = 0.8;
    } completion:^(BOOL finished) {
        [m_viOne removeFromSuperview];
    }];
}

- (void)dismissSecondBgView
{
    [UIView animateWithDuration:0.5 animations:^{
        m_viTwo.alpha = 0;
    } completion:^(BOOL finished) {
        [m_viTwo removeFromSuperview];
        [self removeFromSuperview];
    }];
}


- (void)clearImages
{
    for (int i = 0; i < m_scrollView.subviews.count; i++) {
        UIView* subview = [m_scrollView.subviews objectAtIndex:i];
        if (subview.tag >= TAG_BASE) {
            [subview removeFromSuperview];
        }
    }
    m_pageControl.numberOfPages = 0;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int w = 0, i = 0;
    for (i = 0; i < m_pageControl.numberOfPages; i++)
    {
        if (scrollView.contentOffset.x <= w)
            break;
        w += self.bounds.size.width;
    }
    m_pageControl.currentPage = i;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"%f",((_imgNames.count - 1) * APP_W + 50));
//    if(scrollView.contentOffset.x >= ((_imgNames.count - 1) * APP_W + 50))
//    {
//        [self onBtnCloseTouched:nil];
//    }

}

@end

void showAppGuide(NSArray* images)
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if([[userDefault objectForKey:[NSString stringWithFormat:@"showGuide_%@",APP_VERSION]] boolValue]){
        [[NSNotificationCenter defaultCenter] postNotificationName:APP_CHECK_VERSION object:nil];
        return;
    }
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    AppGuide* guide = [[AppGuide alloc] init];
    guide.imgNames = images;
    [[UIApplication sharedApplication].keyWindow addSubview:guide];
    [guide release];
}

