//
//  DiseaseClassViewController.m
//  quanzhi
//
//  Created by ZhongYun on 14-6-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "DiseaseClassViewController.h"
#import "DiseaseDetailViewController.h"
#import "DiseaseClass.h"
#import "ZhPMethod.h"
#import "Constant.h"
#import "DiseaseClassViewTableViewCell.h"


#define BTN_H       30
#define BTN_E       10
#define BTN_NUM     3

@interface DiseaseClassViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView* m_table;
    NSMutableArray* m_data;
}
@end

@implementation DiseaseClassViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"常见疾病";
        self.view.backgroundColor = [UIColor whiteColor];
        
        m_data = [[NSMutableArray alloc] init];
        m_table = [[UITableView alloc] initWithFrame:RECT(0, 0, APP_W, APP_H-NAV_H-35)
                                               style:UITableViewStylePlain];
        m_table.backgroundColor = [UIColor clearColor];
        m_table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        m_table.bounces = YES;
        m_table.rowHeight = 55;
        m_table.delegate = self;
        m_table.dataSource = self;
        [self.view addSubview:m_table];
        [self loadData];
    }
    return self;
}

- (void)loadData
{
    NSMutableArray* dlist = [[DiseaseClass shared] getList];
    for (NSMutableDictionary* item in dlist) {
        if ([item[@"level"] intValue] == 1) {
            [m_data addObject:item];

            NSMutableDictionary* tmp = [NSMutableDictionary dictionary];
            tmp[@"classId"] = myFormat(@"%@_2", item[@"classId"]);
            tmp[@"extended"] = @0;
            tmp[@"sublist"] = item[@"sublist"];
            [m_data addObject:[tmp mutableCopy]];
        }
    }
    [m_table reloadData];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = m_table.rowHeight;
    if(indexPath.row % 2 == 0) {
        BOOL bisBtnCell = [m_data[indexPath.row + 1][@"extended"] boolValue];
        if(bisBtnCell) {
            rowHeight -= 20;
        }
    }
    if (m_data[indexPath.row][@"extended"] != nil) {
        int ext = [m_data[indexPath.row][@"extended"] intValue];
        if (ext == 1) {
            NSArray* list = m_data[indexPath.row][@"sublist"];
            int num = list.count / BTN_NUM;
            if (list.count%BTN_NUM > 0 ) {
                num++;
            }
            rowHeight = (BTN_E + BTN_H) * num + BTN_E;
        } else {
            rowHeight = 0;
        }
    }
    return rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DiseaseClassViewTableViewCell *cell = (DiseaseClassViewTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    BOOL bisBtnCell = (m_data[indexPath.row][@"extended"] != nil);
    if (!bisBtnCell) {
        NSIndexPath* tmpIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        int ext = [m_data[tmpIndexPath.row][@"extended"] intValue];
        ext = (ext==1 ? 0 : 1);
        m_data[tmpIndexPath.row][@"extended"] = @(ext);
        [m_table reloadRowsAtIndexPaths:@[indexPath,tmpIndexPath] withRowAnimation:0];
        if(ext)
        {
            [cell.accessAvatar setImage:[UIImage imageNamed:@"UpAccessory.png"]];
        }
        else{
            [cell.accessAvatar setImage:[UIImage imageNamed:@"DownAccessory.png"]];
        }
    }
    else
    {

    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL bisBtnCell = (m_data[indexPath.row][@"extended"] != nil);
    static NSString *diseaseClassCellIdentifier = @"diseaseClassCellIdentifier";

    DiseaseClassViewTableViewCell* cell = nil;
    //[tableView dequeueReusableCellWithIdentifier:diseaseClassCellIdentifier];
    if (cell==nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DiseaseClassViewTableViewCell" owner:self options:nil] objectAtIndex:0];
        //cell.backgroundColor = (bisBtnCell ? UIColorFromRGB(0xf6f6f6) : [UIColor whiteColor]);
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;    
        cell.clipsToBounds = YES;
    }
    if (bisBtnCell)
    {
        [self buildButtonObjs:cell AtIndexPath:indexPath];
        cell.accessAvatar.hidden = YES;
        cell.nameLabel.hidden = YES;
        cell.avatar.hidden = YES;
    }else{
        cell.nameLabel.text = m_data[indexPath.row][@"name"];
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",m_data[indexPath.row][@"name"]]];
        if(image){
            cell.avatar.image = image;
        }
        int ext = [m_data[indexPath.row + 1][@"extended"] intValue];
        
        if(ext)
        {
            [cell.accessAvatar setImage:[UIImage imageNamed:@"UpAccessory.png"]];
        }
        else{
            [cell.accessAvatar setImage:[UIImage imageNamed:@"DownAccessory.png"]];
        }
        NSArray* list = m_data[indexPath.row + 1][@"sublist"];
        NSMutableString *subItem = [NSMutableString string];
        for (NSDictionary* item in list) {
            [subItem appendFormat:@"%@/",item[@"name"]];
        }
        [cell.subCateLabel setTextColor:[UIColor darkGrayColor]];
        cell.subCateLabel.text = subItem;
    }
    
    return cell;
}

- (void)collapseButtonObjs:(UITableViewCell*)cell AtIndexPath:(NSIndexPath *)indexPath
{
    [cell.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *button = (UIButton *)obj;
        if(button.tag == 999) {
            [button removeFromSuperview];
        }
    }];
    
    
    
}

- (void)buildButtonObjs:(UITableViewCell*)cell AtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* list = m_data[indexPath.row][@"sublist"];
    CGFloat x = BTN_E, y = BTN_E, w = (APP_W-BTN_E*(BTN_NUM))/BTN_NUM, h=BTN_H;
    for (NSDictionary* item in list) {
        InfoButton* btn = [[InfoButton alloc] initWithFrame:RECT(x, y, w, h)];
//        btn.layer.borderWidth = 0.5;
//        btn.layer.borderColor = UIColorFromRGB(0xd1d1d1).CGColor;
        btn.info = item;
        btn.titleLabel.font = Font(12);
        btn.tag = 999;
        [btn setTitle:item[@"name"] forState:0];
        [btn setTitleColor:[UIColor darkGrayColor] forState:0];
        [btn setBackgroundImage:[UIImage imageNamed:@"jb_list.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onDisBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btn];
        
        x += (w + BTN_E);
        if ((APP_W-x) < w) {
            x = BTN_E;
            y += (BTN_E + h);
        }
    }
}

- (void)onDisBtnTouched:(InfoButton*)sender
{
    DiseaseDetailViewController* vc = [[DiseaseDetailViewController alloc] initWithNibName:@"DiseaseDetailViewController" bundle:nil];
    vc.diseaseType = @"A";
    vc.diseaseId = sender.info[@"classId"];
    vc.title = sender.info[@"name"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
