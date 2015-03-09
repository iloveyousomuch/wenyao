//
//  ListPopView.m
//  quanzhi
//
//  Created by ZhongYun on 14-6-24.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "ListPopView.h"
#import "Categorys.h"
#import "Constant.h"
#import "ZhPMethod.h"

#define ROW_H           42
#define EDGE_H          7
#define MAX_ROW_NUM     7
#define ANI_DURATION     0.3

@interface ListPopView ()<UITableViewDelegate, UITableViewDataSource>
{
    NSInteger m_type;
    UILabel* m_title;
    UITableView* m_table;
    NSMutableArray* m_data;
    UIButton* btnOK;
    
    UIView* m_bgView;
    UIView* m_popView;
}
@end

@implementation ListPopView

- (ListPopView*)initWithType:(int)type
{
    if (self = [super init]) {
        m_type = type;
        m_data = [[NSMutableArray alloc] init];
        
        self.hidden = YES;
        self.frame = RECT(0, 0, SCREEN_W, SCREEN_H);
        self.backgroundColor = [UIColor clearColor];
        
        m_bgView = [[UIView alloc] initWithFrame:self.bounds];
        m_bgView.backgroundColor = [UIColor blackColor];
        m_bgView.alpha = 0.3;
        [self addSubview:m_bgView];
        
        NSInteger rowNum = MIN(m_data.count, MAX_ROW_NUM);
        CGFloat view_h = ROW_H + rowNum*ROW_H + EDGE_H + ROW_H;
        m_popView = [[UIView alloc] initWithFrame:RECT(0, self.FH-view_h, self.FW, view_h)];
        m_popView.backgroundColor = UIColorFromRGB(0xf2f2f2);
        [self addSubview:m_popView];
        
        
        m_title = addLabelObjEx(self, @[@(50), RECT_OBJ(0, 0, m_popView.FW, ROW_H), [UIColor darkGrayColor], FontB(14), @""]);
        m_title.textAlignment = NSTextAlignmentCenter;
        [m_popView addSubview:m_title];
        
        m_table = [[UITableView alloc] initWithFrame:RECT(0, m_title.FH, m_popView.FW, rowNum*ROW_H)
                                               style:UITableViewStylePlain];
        m_table.backgroundColor = [UIColor clearColor];
        m_table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        m_table.rowHeight = ROW_H;
        m_table.delegate = self;
        m_table.dataSource = self;
        m_table.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
        m_table.layer.borderWidth = 0.5;
        [m_popView addSubview:m_table];
        
        btnOK = [[UIButton alloc] initWithFrame:RECT(0, view_h-ROW_H, m_popView.FW, ROW_H)];
        btnOK.layer.borderWidth = 0.5;
        btnOK.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
        btnOK.backgroundColor = [UIColor whiteColor];
        btnOK.titleLabel.font = FontB(14);
        [btnOK setTitle:@"确定" forState:0];
        [btnOK setTitleColor:APP_COLOR_STYLE forState:0];
        [btnOK addTarget:self action:@selector(onOkBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        [btnOK setBackgroundImage:color2Image([UIColor whiteColor]) forState:0];
        [m_popView addSubview:btnOK];
    }
    return self;
}

- (void)show
{
    self.hidden = NO;
    m_popView.FY = SCREEN_H;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [UIView animateWithDuration:ANI_DURATION animations:^{
        m_popView.FY = (SCREEN_H - m_popView.FH);
    }];
}

- (void)onOkBtnTouched:(UIButton*)sender
{
    [UIView animateWithDuration:ANI_DURATION animations:^{
        m_popView.FY = SCREEN_H;
    } completion:^(BOOL finished) {
        self.hidden  = YES;
        m_popView.FY = (SCREEN_H - m_popView.FH);
        [self removeFromSuperview];
        mainThread(returnSelected, nil);
    }];
}

- (void)returnSelected
{
    if (self.respBlock) {
        NSMutableArray* reslist = [[NSMutableArray alloc] init];
        for (int i = 0; i < m_data.count; i++) {
            if ([m_data[i][@"selected"] intValue] == 1) {
                [reslist addObject:@(i)];
                if (m_type == POP_RADIO) {
                    break;
                }
            }
        }
        
        if (reslist.count > 0) {
            self.respBlock(reslist);
        }
    }
    
    self.selected = nil;
    [m_data removeAllObjects];
    [m_table reloadData];
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];
    m_title.text = title;
}

- (void)setData:(NSArray *)data
{
    _data = data;
    [m_data removeAllObjects];
    for (NSDictionary* item in data) {
        NSMutableDictionary* tmp = [[NSMutableDictionary alloc] init];
        tmp[@"data"] = [item mutableCopy];
        tmp[@"id"] = @(arc4random());
        tmp[@"selected"] = @0;
        [m_data addObject:tmp];
    }
    [self updateViewsFrame];
    [self updateSelectStatus:self.selected];
    [m_table reloadData];
}

- (void)setSelected:(NSArray *)selected
{
    _selected = selected;
    if (m_data.count > 0){
        [self updateSelectStatus:selected];
        [m_table reloadData];
    }
}

- (void)updateSelectStatus:(NSArray*)selList
{
    if (selList == nil) return;
    for (id item in selList) {
        int row = [item intValue];
        if (row >= 0) {
            m_data[row][@"selected"] = @1;
            if (m_type == POP_RADIO) {
                break;
            }
        }
    }
}

- (void)updateViewsFrame
{
    NSInteger rowNum = MIN(m_data.count, MAX_ROW_NUM);
    CGFloat view_h = ROW_H + rowNum*ROW_H + EDGE_H + ROW_H;
    m_popView.frame = RECT(0, self.FH-view_h, APP_W, view_h);
    m_title.frame = RECT(0, 0, self.FW, ROW_H);
    m_table.frame = RECT(0, m_title.FH, self.FW, rowNum*ROW_H);
    btnOK.frame = RECT(0, view_h-ROW_H, self.FW, ROW_H);
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return m_table.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (m_type == POP_RADIO) {
        NSMutableArray* tmplist = [NSMutableArray array];
        m_data[indexPath.row][@"selected"] = @(1);
        [m_table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:0];
        
        for (int i = 0; i < m_data.count; i++) {
            if (i != indexPath.row) {
                if ([m_data[i][@"selected"] intValue] == 1) {
                    m_data[i][@"selected"] = @0;
                    [tmplist addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    break;
                }
            }
        }
        
        [m_table reloadRowsAtIndexPaths:tmplist withRowAnimation:0];
    } else {
        NSInteger selStatus = [m_data[indexPath.row][@"selected"] intValue];
        selStatus = (selStatus==1 ? 0 : 1);
        m_data[indexPath.row][@"selected"] = @(selStatus);
        [m_table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:0];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* dataRow = m_data[indexPath.row];
    NSString* str = [NSString stringWithFormat:@"cell_%@", dataRow[@"_id"]];
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:str];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:str];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = Font(12);
        
        UIImageView* selIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"未选中.png"]];
        selIcon.tag = 20;
        selIcon.frame = RECT(10, (m_table.rowHeight-selIcon.FH)/2, selIcon.FW, selIcon.FH);
        [cell addSubview:selIcon];
        
        //addLabelObjEx(self, @[@(21), RECT_OBJ(40, 0, self.FW-40, 12), [UIColor darkGrayColor], Font(14), @""]);
    }
    
    BOOL bisDict = [dataRow[@"data"] isKindOfClass:[NSDictionary class]];
    NSString* value = @"";
    if (!bisDict) {
        value = myFormat(@"        %@", dataRow[@"data"]);
    } else if (self.showField && bisDict) {
        value = myFormat(@"        %@", dataRow[@"data"][self.showField]);
    }
    cell.textLabel.text = value;
    
    NSString* imageName = ([dataRow[@"selected"] intValue] == 1 ? @"选中.png" : @"未选中.png");
    ((UIImageView*)[cell viewWithTag:20]).image = [UIImage imageNamed: imageName];
    return cell;
}

@end


