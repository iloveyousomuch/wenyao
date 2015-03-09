//
//  PossibleDiseaseViewController.m
//  quanzhi
//
//  Created by Meng on 14-8-7.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "PossibleDiseaseViewController.h"
#import "PossibleDiseaseCell.h"
#import "Constant.h"
#import "ZhPMethod.h"
#import "HTTPRequestManager.h"
#import "DiseaseDetailViewController.h"

#import "JGProgressHUD.h"

#define F_TITLE  14
#define F_DESC   12
#define NODATAVIEWTAG 14061010

@interface PossibleDiseaseViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView * _tableView;
    PossibleDiseaseCell * myCell;
    UIFont *cellTitleFont;
    UIFont *cellContentFont;
    UIView *_nodataView;
    
    
    NSInteger m_descFont;
    NSInteger m_titleFont;
    BOOL m_collected;
    BOOL isUp;
}
@property (nonatomic ,strong) NSMutableArray * dataArray;

@end

@implementation PossibleDiseaseViewController

- (id)init{
    if (self = [super init]) {
        isUp = YES;
        m_descFont = F_DESC;
        m_titleFont = F_TITLE;
        m_collected = NO;
        cellTitleFont = [UIFont boldSystemFontOfSize:m_titleFont];
        cellContentFont = [UIFont systemFontOfSize:m_descFont];
    }
    return self;
}

- (void)dealloc
{
    
}

- (void)zoomClick{
    if (m_descFont == 18) {
        isUp = NO;
    }else if(m_descFont == 12){
        isUp = YES;
    }
    
    if (isUp) {
        m_descFont+=3;
        m_titleFont+=3;
    }else{
        m_descFont = 12;
        m_titleFont = 12;
    }
    cellTitleFont = [UIFont boldSystemFontOfSize:m_titleFont];
    cellContentFont = [UIFont systemFontOfSize:m_descFont];
    [_tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.dataArray.count) {
        return;
    }
    
 
    NSMutableDictionary * setting = [NSMutableDictionary dictionary];
    setting[@"spmCode"] = self.spmCode;
    [[HTTPRequestManager sharedInstance] associationDiseaseWithParam:setting completionSuc:
     ^(id resultObj) {
         if ([resultObj[@"result"] isEqualToString:@"OK"]) {
             NSLog(@"相关疾病 = %@",resultObj);
             self.dataArray = resultObj[@"body"][@"data"];
             if (self.dataArray.count > 0) {
                 [_tableView reloadData];
             }else{
                 [self showNoDataViewWithString:@"暂无该可能疾病"];
             }
         }
    } failure:^(id failMsg) {
        
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"可能疾病";
    self.dataArray = [NSMutableArray array];
    cellTitleFont = [UIFont boldSystemFontOfSize:m_titleFont];
    cellContentFont = [UIFont systemFontOfSize:m_descFont];
    [self makeUpTableView];
}

- (void)setUpRightBarButton{
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"分享" style:UIBarButtonItemStyleBordered target:self action:@selector(shareBtnClick)];
    self.navigationController.navigationItem.rightBarButtonItem = rightBarButton;
}

- (void)makeUpTableView{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H-35)];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableView];
    
}

- (CGFloat)calculateHeigtOffsetWithFontSize:(UIFont *)fontSize withTextSting:(NSString *)text
{
    CGSize adjustSize = [text sizeWithFont:fontSize constrainedToSize:CGSizeMake(250, 999) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat offset = adjustSize.height - 21.0f;
    offset = ceilf(offset);
    if(offset > 0.0)
        return offset;
    return 0.0;
}

- (void)adjustCellHeightWithView:(UIView *)target offset:(CGFloat)offset
{
    CGRect rect = target.frame;
    rect.size.height += offset;
    target.frame = rect;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = self.dataArray[indexPath.row][@"name"];
    NSString *content = self.dataArray[indexPath.row][@"desc"];
    CGFloat offset = [self calculateHeigtOffsetWithFontSize:cellTitleFont withTextSting:title];
    offset += [self calculateHeigtOffsetWithFontSize:cellContentFont withTextSting:content];
    return 60 + offset;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellIdentifier = @"cellIdentifier";
    PossibleDiseaseCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSBundle * bundle = [NSBundle mainBundle];
        NSArray * cellViews = [bundle loadNibNamed:@"PossibleDiseaseCell" owner:self options:nil];
        cell = [cellViews objectAtIndex:0];
        
        cell.selectedBackgroundView = [[UIView alloc]init];
        cell.selectedBackgroundView.backgroundColor = UIColorFromRGB(0xdfe4e6);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == 0) {
        cell.leftImageView.backgroundColor = UICOLOR(238, 88, 71);
    }else if (indexPath.row == 1) {
        cell.leftImageView.backgroundColor = UICOLOR(244, 121, 59);
    }else if (indexPath.row == 2) {
        cell.leftImageView.backgroundColor = UICOLOR(249, 196, 38);
    }else{
        cell.leftImageView.backgroundColor = UICOLOR(206, 212, 216);
    }
   
    cell.numLabel.text = (indexPath.row < 9?[NSString stringWithFormat:@"0%d",indexPath.row+1] : [NSString stringWithFormat:@"%d",indexPath.row+1]);
    CGFloat height = 0.0;
    CGFloat offset = [self calculateHeigtOffsetWithFontSize:cellTitleFont withTextSting:self.dataArray[indexPath.row][@"name"]];
    height = offset;
    if(offset > 0.0)
        [self adjustCellHeightWithView:cell.titleLabel offset:offset];
    
    offset = [self calculateHeigtOffsetWithFontSize:cellContentFont withTextSting:self.dataArray[indexPath.row][@"desc"]];
    height += offset;
    if(offset > 0.0)
        [self adjustCellHeightWithView:cell.subTitleLabel offset:offset];
    cell.leftImageView.frame = CGRectMake(10, (height+60)/2-20, 40, 40);
    cell.numLabel.frame = CGRectMake(20, (height+60)/2-20+12, 20, 15);
    cell.subTitleLabel.numberOfLines = 0;
    cell.titleLabel.font = cellTitleFont;
    cell.titleLabel.text = self.dataArray[indexPath.row][@"name"];
    cell.subTitleLabel.font = cellContentFont;
    cell.subTitleLabel.text = self.dataArray[indexPath.row][@"desc"];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, height+60-1, APP_W, 0.5)];
    [separator setBackgroundColor:UIColorFromRGB(0xdbdbdb)];
    [cell.contentView addSubview:separator];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSIndexPath*    selection = [_tableView indexPathForSelectedRow];
    if (selection) {
        [_tableView deselectRowAtIndexPath:selection animated:YES];
    }
    
    DiseaseDetailViewController* dvc = [[DiseaseDetailViewController alloc] initWithNibName:@"DiseaseDetailViewController" bundle:nil];
    //dvc.diseaseType = @"A";
    dvc.diseaseType = self.dataArray[indexPath.row][@"type"];
    
    dvc.diseaseId = self.dataArray[indexPath.row][@"diseaseClassId"];
    dvc.title = self.dataArray[indexPath.row][@"name"];
    dvc.containerViewController = self.containerViewController;
    if (self.containerViewController) {
        [self.containerViewController.navigationController pushViewController:dvc animated:YES];
    }else
    {
        [self.navigationController pushViewController:dvc animated:YES];
    }

}

- (void)viewDidCurrentView
{
    if (self.dataArray.count) {
        return;
    }
    NSMutableDictionary * setting = [NSMutableDictionary dictionary];
    setting[@"spmCode"] = self.spmCode;
    [[HTTPRequestManager sharedInstance] associationDiseaseWithParam:setting completionSuc:
     ^(id resultObj) {
         if ([resultObj[@"result"] isEqualToString:@"OK"]) {
             self.dataArray = resultObj[@"body"][@"data"];
             if (self.dataArray.count > 0) {
                 [_tableView reloadData];
             }else{
                 [self showNoDataViewWithString:@"暂无该可能疾病"];
             }
         }
     } failure:^(id failMsg) {
         
     }];
}

- (void)shareBtnClick
{
    NSLog(@"需要加入分享模块");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)zoomOutSubViews
{
    CGFloat pointSize = cellTitleFont.pointSize;
    if (pointSize >= 20)
        return;
    ++pointSize;
    cellTitleFont = [UIFont boldSystemFontOfSize:pointSize];
    pointSize = cellContentFont.pointSize;
    ++pointSize;
    cellContentFont = [UIFont systemFontOfSize:pointSize];
    [_tableView reloadData];
}

- (void)zoomInSubViews
{
    CGFloat pointSize = cellTitleFont.pointSize;
    if (pointSize <= 8)
        return;
    --pointSize;
    cellTitleFont = [UIFont boldSystemFontOfSize:pointSize];
    pointSize = cellContentFont.pointSize;
    --pointSize;
    cellContentFont = [UIFont systemFontOfSize:pointSize];
    [_tableView reloadData];
}


#pragma mark - INDICTOR
-(void)showNoDataViewWithString:(NSString *)nodataPrompt
{
    if (nodataPrompt==nil) {
        nodataPrompt = @"暂无数据";
    }
    
    if (_nodataView==nil) {
        _nodataView = [[UIView alloc]initWithFrame:self.view.bounds];
        _nodataView.backgroundColor = UIColorFromRGB(0xecf0f1);
        
        UIImageView *dataEmpty = [[UIImageView alloc]initWithFrame:RECT(0, 0, 75, 75)];
        dataEmpty.center = CGPointMake(APP_W/2, 130);
        dataEmpty.image = [UIImage imageNamed:@"无可能疾病icon.png"];
        [_nodataView addSubview:dataEmpty];
        
        UILabel* lable_ = [[UILabel alloc]initWithFrame:RECT(0,200, nodataPrompt.length*20,30)];
        lable_.tag = 201405220;
        lable_.font = Font(15);
        lable_.textColor = UIColorFromRGB(0x7e8d97);
        lable_.textAlignment = NSTextAlignmentCenter;
        lable_.center = CGPointMake(APP_W/2, 200);
        lable_.text = nodataPrompt;
        
        [_nodataView addSubview:lable_];
        [[UIApplication sharedApplication].keyWindow addSubview:_nodataView];
        [self.view insertSubview:_nodataView atIndex:self.view.subviews.count];
    }else
    {
        UILabel *label_ = (UILabel *)[_nodataView viewWithTag:201405220];
        label_.text = nodataPrompt;
        label_.textAlignment =NSTextAlignmentCenter;
        label_.frame = RECT(0,175, nodataPrompt.length*20,30);
        label_.center = CGPointMake(APP_W/2, label_.center.y);
        _nodataView.hidden = NO;
    }
}

////调整无数据提示
//- (void)_nodataViewFrameChange
//{
//    UIView *view_ = [self.view viewWithTag:NODATAVIEWTAG];
//    if (view_) {
//        CGRect rect = view_.frame;
//        rect.origin.y = 64;
//        view_.frame = rect;
//    }
//}
@end
