//
//  ReturnIndexView.m
//  wenyao
//
//  Created by qwfy0006 on 15/3/2.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "ReturnIndexView.h"

#import "AppDelegate.h"
#import "Constant.h"
#import "ReturnIndexCell.h"

#define  BOUNDS [[UIScreen mainScreen] bounds]

@interface ReturnIndexView()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

@implementation ReturnIndexView

- (id)initWithImage:(NSArray *)images title:(NSArray *)titles
{
    self = [super init];
    if (self) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ReturnIndexView" owner:nil options:nil];
        self = array[0];
        self.imageArray = (NSMutableArray *)[NSArray arrayWithArray:images];
        self.titleArray = (NSMutableArray *)[NSArray arrayWithArray:titles];
        [self setUpTableView];
    }
    return self;
}

- (void)setUpTableView
{
    
    UIImageView *headaer = [[UIImageView alloc] initWithFrame:CGRectMake(BOUNDS.size.width - 7 - 10, 67, 7, 3)];
    headaer.image = [UIImage imageNamed:@"triangle.PNG"];
    headaer.userInteractionEnabled = YES;
    [self addSubview:headaer];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(APP_W-120, 70, 119, 40*self.titleArray.count) style:UITableViewStylePlain];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self addSubview:self.tableView];
    self.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = UIColorFromRGB(0x555555);
    self.tableView.scrollEnabled = NO;
}

#pragma mark----------------------------------------列表代理-----------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ReturnIndexCellIdentifier = @"ReturnIndexCell";
    ReturnIndexCell *cell = (ReturnIndexCell *)[tableView dequeueReusableCellWithIdentifier:ReturnIndexCellIdentifier];
    if(cell == nil){
        UINib *nib = [UINib nibWithNibName:@"ReturnIndexCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:ReturnIndexCellIdentifier];
        cell = (ReturnIndexCell *)[tableView dequeueReusableCellWithIdentifier:ReturnIndexCellIdentifier];
        
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.titleLabel.text = self.titleArray[indexPath.row];
    cell.iconImage.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(RetunIndexView:didSelectedIndex:)]) {
        [self.delegate RetunIndexView:self didSelectedIndex:indexPath];
    }
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark----------------------------------------列表代理-----------------------------------------

+ (ReturnIndexView *)sharedManagerWithImage:(NSArray *)images title:(NSArray *)titles
{
    return [[self alloc] initWithImage:images title:titles];
}
- (void)show
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.frame = CGRectMake(0, 0, BOUNDS.size.width, BOUNDS.size.height);
    [UIView animateWithDuration:0.8 animations:^{
        [app.window addSubview:self];
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSelf)];
    [self.bgView addGestureRecognizer:tap];
}

- (void)dismissSelf
{
    [self hide];
}


- (void)hide
{
    [UIView animateWithDuration:0.8 animations:^{
        self.delegate = nil;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
    }];
}


@end
