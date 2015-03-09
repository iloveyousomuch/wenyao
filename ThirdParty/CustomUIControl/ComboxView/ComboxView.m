//
//  ComboxView.m
//  wenyao
//
//  Created by xiezhenghong on 14-9-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "ComboxView.h"
#import "Constant.h"


@interface ComboxView ()<UITableViewDataSource,UITableViewDelegate>


@property (nonatomic, strong) UIButton      *backGroundTouch;


@end

@implementation ComboxView

- (id)initWithFrame:(CGRect)frame
{
    CGRect rect = [UIScreen mainScreen].bounds;
    rect.origin.y += frame.origin.y;
    self = [super initWithFrame:rect];
    if (self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        frame.origin.y = 0;
        self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        self.backGroundTouch = [UIButton buttonWithType:UIButtonTypeCustom];
        
        self.backGroundTouch.frame = rect;
        self.backGroundTouch.userInteractionEnabled = YES;
        self.backGroundTouch.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.75];
        [self.backGroundTouch addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.backGroundTouch];
        [self addSubview:self.tableView];
        self.alpha = 0.0;
    }
    return self;
}

- (void)dismissView
{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if([self.comboxDeleagte respondsToSelector:@selector(comboxViewDidDisappear:)]){
            [self.comboxDeleagte comboxViewDidDisappear:self];
        }
    }];
    
}

- (void)showInView:(UIView *)superView
{
    if(!self.superview) {
        [superView addSubview:self];
    }
    [superView bringSubviewToFront:self];
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)setDelegate:(id<UITableViewDelegate,UITableViewDataSource>)delegate
{
    _delegate = delegate;
    self.tableView.delegate = delegate;
    self.tableView.dataSource = delegate;
    [self.tableView reloadData];
}


@end
