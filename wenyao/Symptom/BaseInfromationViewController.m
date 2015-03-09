//
//  BaseInfromationViewController.m
//  quanzhi
//
//  Created by Meng on 14-8-7.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseInfromationViewController.h"
#import "Constant.h"
#import "HTTPRequestManager.h"
#import "ZhPMethod.h"
#import "Categorys.h"
#import "JGProgressHUD.h"

#define F_TITLE  16
#define F_DESC   14


@interface BaseInfromationViewController ()<UINavigationControllerDelegate,JGProgressHUDDelegate>
{
    UIView * topView;
    UIFont *cellTitleFont;
    UIFont *cellContentFont;
    
    NSInteger m_descFont;
    NSInteger m_titleFont;
    BOOL m_collected;
    BOOL isUp;
    UILabel * label;
}

@property (nonatomic ,strong) NSMutableArray * propertiesArray;
@end

@implementation BaseInfromationViewController
@synthesize myTableView;

- (id)init{
    if (self = [super init]) {
        isUp = YES;
        m_descFont = F_DESC;
        m_titleFont = F_TITLE;
        cellTitleFont = [UIFont boldSystemFontOfSize:m_titleFont];
        cellContentFont = [UIFont systemFontOfSize:m_descFont];
        m_collected = NO;
        topView = [[UIView alloc] init];
        label = [[UILabel alloc] init];
    }
    return self;
}




- (void)zoomClick{
    if (m_descFont == 20) {
        isUp = NO;
    }else if(m_descFont == 14){
        isUp = YES;
    }
    
    if (isUp) {
        m_descFont+=3;
        m_titleFont+=3;
    }else{
        m_descFont = 14;
        m_titleFont = 16;
    }
    cellTitleFont = [UIFont boldSystemFontOfSize:m_titleFont];
    cellContentFont = [UIFont systemFontOfSize:m_descFont];
    [myTableView reloadData];
    [self setUpTopView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.dataSource.count) {
        return;
    }
    NSMutableDictionary * setting = [NSMutableDictionary dictionary];
    setting[@"spmCode"] = self.spmCode;
    [[HTTPRequestManager sharedInstance] symptomDetailWithParam:setting completionSuc:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
             self.dataSource = resultObj[@"body"];
            NSArray *propertiesArray = self.dataSource[@"properties"];
            for(NSDictionary *dict in propertiesArray){
                [self.propertiesArray addObject:[dict mutableCopy]];
            }
            for (int i = 0; i < [self.propertiesArray count]; i++) {
                
                NSMutableDictionary * dic = [NSMutableDictionary dictionary];
                [dic addEntriesFromDictionary:self.propertiesArray[i]];
                if (!dic[@"content"]) {//如果content内容不存在 那么就删除这一项
                    [self.propertiesArray removeObjectAtIndex:i];
                }else{
                [dic setObject:[NSNumber numberWithBool:NO] forKey:@"isExpand"];
                [dic setObject:[NSNumber numberWithBool:NO] forKey:@"isShow"];
                [self.propertiesArray replaceObjectAtIndex:i withObject:dic];
                }
            }
            [self setUpTopView];
            [self.myTableView reloadData];
        }
    } failure:^(id failMsg) {
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"基本信息";
    self.navigationController.delegate = self;
    self.dataSource = [[NSMutableDictionary alloc] init];
    self.propertiesArray = [[NSMutableArray alloc] init];
    [self makeTableView];
    [self setUpTopView];
    
    
    
}

- (void)dealloc
{
    
}

- (void)makeTableView{
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H-35) style:UITableViewStylePlain];
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.backgroundColor = UIColorFromRGB(0xecf0f1);
    [self.myTableView setSeparatorColor:UIColorFromRGB(0xdbdbdb)];
    [self.view addSubview:self.myTableView];
}
#pragma mark - 设置UITableView顶部的topView
- (void)setUpTopView{
    UIFont * topFont = cellContentFont;
    NSString * desc = self.dataSource[@"desc"];
    [topView setFrame:CGRectMake(0, 0, APP_W, (desc.length > 0 ? (getTextSize(desc, topFont, 300).height+35) : 0))];
    topView.layer.borderWidth = 0.8f;
    topView.layer.borderColor = UICOLOR(227, 227, 227).CGColor;;
    topView.backgroundColor = UICOLOR(255, 255, 255);
    [label setFrame:CGRectMake(12, 15, APP_W - 24, getTextSize(desc, topFont, 300).height)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = UIColorFromRGB(0x333333);
    label.text = desc;
    label.numberOfLines = 0;
    label.font = cellContentFont;
    [topView addSubview:label];
    self.myTableView.tableHeaderView = topView;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_W, 10)];
    sectionView.backgroundColor = UIColorFromRGB(0xecf0f1);
    return sectionView;
}

//cell展开的高度
- (CGFloat)calculateHeigtOffsetWithFontSize:(UIFont *)fontSize withTextSting:(NSString *)text
{
    CGSize adjustSize = getTextSize(text, fontSize, APP_W-20);
    //CGSize adjustSize = [text sizeWithFont:fontSize constrainedToSize:CGSizeMake(APP_W-20, 999) lineBreakMode:NSLineBreakByWordWrapping];
    

    CGFloat offset = adjustSize.height - 21.0f;
    offset = ceilf(offset);
    if(offset > 0.0)
        return offset;
    return 0.0;
}


//cell的收缩高度
- (CGFloat)calculateCollapseHeigtOffsetWithFontSize:(UIFont *)fontSize withTextSting:(NSString *)text withRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat singelHeight = fontSize.lineHeight;
    CGSize adjustSize = getTextSize(text, fontSize, APP_W-20);
    //CGSize adjustSize = [text sizeWithFont:fontSize constrainedToSize:CGSizeMake(APP_W-20, 999) lineBreakMode:NSLineBreakByWordWrapping];
    NSUInteger linecount = ceil(adjustSize.height /singelHeight);
    CGFloat adjustHeight = 0.0;
    if(linecount > 3) {
        adjustHeight = 3 * (singelHeight + 0.5);
        self.propertiesArray[indexPath.section][@"isShow"] = [NSNumber numberWithBool:YES];
    }else{
        adjustHeight = adjustSize.height;
    }
    CGFloat offset = adjustHeight - 21.f;
    if(offset > 0.0)
        return offset + 5.5;
    return 0;
}

- (void)adjustCellHeightWithView:(UIView *)target offset:(CGFloat)offset
{
    CGRect rect = target.frame;
    rect.size.height += offset;
    target.frame = rect;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *content = [self replaceSpecialStringWith:self.propertiesArray[indexPath.section][@"content"]];
    CGFloat offset = 0.0;
    NSDictionary *dict = self.propertiesArray[indexPath.section];
    if([dict[@"isExpand"] boolValue]){
        offset = [self calculateHeigtOffsetWithFontSize:cellContentFont withTextSting:content];
    }else{
        offset = [self calculateCollapseHeigtOffsetWithFontSize:cellContentFont withTextSting:content withRowAtIndexPath:indexPath];
    }
    if ([dict[@"isShow"] boolValue]) {
        return 103.0f + offset;
    }
    return 80.0f + offset;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = 10;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.propertiesArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"cellIdentifier";
    SymBaseInfroCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSBundle * bundle = [NSBundle mainBundle];
        NSArray * cellViews = [bundle loadNibNamed:@"SymBaseInfroCell" owner:self options:nil];
        cell = [cellViews objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(10, 45, APP_W - 10, 0.5)];
        line.backgroundColor = UIColorFromRGB(0xdbdbdb);
        [cell addSubview:line];
        
    }
    cell.delegate = self;
    CGFloat offset = 0;
    NSDictionary *dict = self.propertiesArray[indexPath.section];
    NSString *content = [self replaceSpecialStringWith:dict[@"content"]];
    
    cell.ExtendButton.titleLabel.font = Font(12);
    cell.ExtendButton.titleLabel.textColor = UIColorFromRGB(0x666666);
    if([dict[@"isExpand"] boolValue]){
        cell.subTitleLabel.numberOfLines = 999;
        offset = [self calculateHeigtOffsetWithFontSize:cellContentFont withTextSting:content];
        [cell.ExtendButton setTitle:@"收起" forState:UIControlStateNormal];
        cell.arrowImageView.image = [UIImage imageNamed:@"UpAccessory.png"];
    }else{
        cell.subTitleLabel.numberOfLines = 3;
        [cell.ExtendButton setTitle:@"更多" forState:UIControlStateNormal];
        cell.arrowImageView.image = [UIImage imageNamed:@"DownAccessory.png"];
        offset = [self calculateCollapseHeigtOffsetWithFontSize:cellContentFont withTextSting:content withRowAtIndexPath:indexPath];
    }
    if ([dict[@"isShow"] boolValue]) {
        cell.ExtendButton.hidden = NO;
        cell.arrowImageView.hidden = NO;
    }
    [self adjustCellHeightWithView:cell.subTitleLabel offset:offset];
    cell.ExtendButton.frame = CGRectMake(250, cell.subTitleLabel.frame.origin.y+cell.subTitleLabel.frame.size.height, 60, 20);
    cell.arrowImageView.frame = CGRectMake(290, cell.subTitleLabel.frame.origin.y+cell.subTitleLabel.frame.size.height+6, 15, 8);

    cell.titleLabel.font = cellTitleFont;
    cell.titleLabel.textColor = UIColorFromRGB(0x333333);
    cell.titleLabel.text = dict[@"title"];
    
    
    cell.subTitleLabel.font = cellContentFont;
    cell.subTitleLabel.text = content;
    cell.subTitleLabel.frame = CGRectMake(12, 50, APP_W - 20, cell.subTitleLabel.frame.size.height);
    return cell;
}

#pragma mark - cell中button点击事件
- (void)clickExpandEventWithIndexPath:(SymBaseInfroCell *)cell
{
    NSIndexPath * indexP = [self.myTableView indexPathForCell:cell];
    if (self.propertiesArray[indexP.section][@"isExpand"] == [NSNumber numberWithBool:YES]) {
        self.propertiesArray[indexP.section][@"isExpand"] = [NSNumber numberWithBool:NO];
    }else{
        self.propertiesArray[indexP.section][@"isExpand"] = [NSNumber numberWithBool:YES];
    }
    [self.myTableView reloadRowsAtIndexPaths:@[indexP] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)viewDidCurrentView
{
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
