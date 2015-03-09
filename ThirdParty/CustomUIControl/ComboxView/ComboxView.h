//
//  ComboxView.h
//  wenyao
//
//  Created by xiezhenghong on 14-9-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ComboxView;

@protocol ComboxViewDelegate <NSObject>

- (void)comboxViewDidDisappear:(ComboxView *)combox;

@end


@interface ComboxView : UIView

@property (nonatomic, assign) id<ComboxViewDelegate>    comboxDeleagte;
@property (nonatomic, assign) id<UITableViewDelegate,UITableViewDataSource> delegate;
@property (nonatomic, strong) UITableView   *tableView;

- (void)showInView:(UIView *)superView;
- (void)dismissView;




@end
