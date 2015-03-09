//
//  FactoryDetail.m
//  quanzhi
//
//  Created by ZhongYun on 14-6-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "FactoryDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DrugDetailViewController.h"
#import "MedicineListViewController.h"
#import "HTTPRequestManager.h"
#import "AFNetworking.h"
#import "ZhPMethod.h"
#import "Categorys.h"
#import "FactoryMedicineListViewController.h"
#import "UIViewController+isNetwork.h"
#import "ReturnIndexView.h"
#import "AppDelegate.h"

#define MAX_DESC_H  12 * 4
@interface FactoryDetailViewController ()<ReturnIndexViewDelegate>
{
    UIView * labelView;
    UILabel * subLabel;
    UIView * medicineView;
    
    CGFloat subTextHeight;
    
    UIScrollView * scrollView;
    
    BOOL isExpand;
    UIButton * textMore;
    UIImageView* arrImg;
}
@property (nonatomic ,strong) NSMutableDictionary * dataDic;
@property (nonatomic ,strong) NSMutableArray * moreDataSource;
@property (nonatomic ,strong) ReturnIndexView *indexView;
@property (nonatomic ,assign) CGSize oriScrollViewSize;

@end

@implementation FactoryDetailViewController

- (id)init{
    if (self = [super init]) {
    }
    return self;
}

- (void)subViewDidLoad{
    
    isExpand = NO;
    self.dataDic = [NSMutableDictionary dictionary];
    self.moreDataSource = [NSMutableArray array];
    
    labelView = [[UIView alloc] init];
    labelView.backgroundColor = [UIColor whiteColor];
    subLabel = [[UILabel alloc] init];
    medicineView = [[UIView alloc] init];
    medicineView.backgroundColor = [UIColor whiteColor];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H)];
    scrollView.backgroundColor =[UIColor clearColor];
    scrollView.pagingEnabled = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:scrollView];
    [self setFactoryId:self.factoryId];
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    if([self isNetWorking]){
        [self addNetView];
        return;
    }
    [self subViewDidLoad];
    [self setUpRightItem];
}

#pragma mark---------------------------------------------跳转到首页-----------------------------------------------

- (void)setUpRightItem
{
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -6;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-unfold.PNG"] style:UIBarButtonItemStylePlain target:self action:@selector(returnIndex)];
    self.navigationItem.rightBarButtonItems = @[fixed,rightItem];
}
- (void)returnIndex
{
    self.indexView = [ReturnIndexView sharedManagerWithImage:@[@"icon home.PNG"] title:@[@"首页"]];
    self.indexView.delegate = self;
    [self.indexView show];
}
- (void)RetunIndexView:(ReturnIndexView *)ReturnIndexView didSelectedIndex:(NSIndexPath *)indexPath
{
    [self.indexView hide];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self performSelector:@selector(delayPopToHome) withObject:nil afterDelay:0.01];
}
- (void)delayPopToHome
{
    [app.tabBarController setSelectedIndex:0];
}
#pragma mark---------------------------------------------跳转到首页-----------------------------------------------

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = @"品牌详情";
}

- (void)BtnClick{
    
    if(![self isNetWorking]){
        for(UIView *v in [self.view subviews]){
            if(v.tag == 999){
                [v removeFromSuperview];
            }
        }
        [self subViewDidLoad];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.title = @"";
}

- (void)setFactoryId:(NSString *)factoryId{
    _factoryId = [factoryId copy];
    [self loadData];
}

- (void)loadData{
    [[HTTPRequestManager sharedInstance] queryFactoryDetail:@{@"factoryCode":self.factoryId} completionSuc:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            [self.dataDic removeAllObjects];
            [self.dataDic addEntriesFromDictionary:resultObj[@"body"][@"FactoryInfo"]];
            [self performSelectorOnMainThread:@selector(loadDetail) withObject:nil waitUntilDone:YES];
        }
    } failure:^(id failMsg) {
        NSLog(@"%@",failMsg);
    }];
}

- (void)loadDetail{
    [[HTTPRequestManager sharedInstance] queryFactoryProductList:@{@"factoryCode":self.factoryId, @"currPage":@1, @"pageSize":@10} completionSuc:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            [self.moreDataSource removeAllObjects];
            [self.moreDataSource addObjectsFromArray:resultObj[@"body"][@"data"]];
            [self performSelectorOnMainThread:@selector(buildDetailObjs) withObject:nil waitUntilDone:YES];
        }
    } failure:^(id failMsg) {
        NSLog(@"%@",failMsg);
    }];
}

- (void)buildDetailObjs{
    
    
    CGSize titleSize = getTextSize(self.dataDic[@"name"], FontB(14), APP_W-20);
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, APP_W-20, titleSize.height)];
    titleLabel.text = self.dataDic[@"name"];
    titleLabel.font = FontB(16);
    titleLabel.textColor = UIColorFromRGB(0x333333);
    [labelView addSubview:titleLabel];
    
    CGSize subLabelSize = getTextSize(self.dataDic[@"desc"], Font(14), APP_W-20);
    subTextHeight = subLabelSize.height;
    CGFloat sub_h;
    if (subLabelSize.height > 165) {
        sub_h = 165;
    }else{
        sub_h = subLabelSize.height+5;
    }
   
//    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:self.dataDic[@"desc"]];
//    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
//    [paragraphStyle1 setLineSpacing:3];
//    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [self.dataDic[@"desc"] length])];
    
    
    [subLabel setFrame:CGRectMake(10, 34, APP_W-20, sub_h)];
    subLabel.font = Font(14);
    subLabel.numberOfLines = 0;
    subLabel.text = self.dataDic[@"desc"];
    subLabel.textColor = UIColorFromRGB(0x333333);
    [labelView addSubview:subLabel];
    
    CGFloat view_h = subLabel.frame.origin.y + subLabel.frame.size.height + 10;
    
    if (subLabelSize.height > 160) {
        if(!textMore){
            textMore = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            arrImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DownAccessory.png"]];
        }
        textMore.frame = CGRectMake(APP_W-83, subLabel.frame.origin.y + subLabel.frame.size.height + 10, 83, 30);
        textMore.titleLabel.font = Font(12);
        [textMore setTitle:@"更多" forState:UIControlStateNormal];
        [textMore setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [textMore addTarget:self action:@selector(textMoreButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        
        arrImg.frame = RECT(50, (textMore.frame.size.height-arrImg.frame.size.height)/2,
                            arrImg.frame.size.width, arrImg.frame.size.height);
        [textMore addSubview:arrImg];
        view_h += textMore.frame.size.height;
        [labelView addSubview:textMore];
    }
    [labelView setFrame:CGRectMake(0, 0, APP_W, view_h)];
    [scrollView addSubview:labelView];
    
    
    if(self.moreDataSource.count == 0){
        return;
    }
    //主要产品
    CGSize tSize = getTextSize(@"主要产品", FontB(14), APP_W);
    UILabel * titleLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, APP_W, tSize.height)];
    titleLab.text = @"主要产品";
    titleLab.font = FontB(14);
    [medicineView addSubview:titleLab];
    
    UILabel * line = [[UILabel alloc] initWithFrame:CGRectMake(0, titleLab.frame.origin.y + titleLab.frame.size.height + 10, APP_W, 2)];
    line.tag = 12345;
    line.backgroundColor = UICOLOR(57, 182, 11);
    [medicineView addSubview:line];
    
    
    
    ////////////// 添加药品列表 /////////////////////
    
    CGFloat pos_y = line.frame.origin.y + line.frame.size.height + 10;
    int num = (self.moreDataSource.count / 3);
    if (self.moreDataSource.count%3 > 0)
        num++;
    CGFloat mw = 77;
    CGFloat mh = mw+2+12*2;
    CGFloat me = (APP_W-mw*3)/4;
    CGFloat mx = me;
    NSInteger countDataSource = 0;
    if (self.moreDataSource.count > 6) {
        countDataSource = 6;
    } else {
        countDataSource = self.moreDataSource.count;
    }
    for (int i = 0; i < countDataSource; i++) {
        NSDictionary* item = self.moreDataSource[i];
        InfoButton* detailBtn = [[InfoButton alloc] initWithFrame:RECT(mx, pos_y, mw, mh)];
        detailBtn.info = item;
        [detailBtn addTarget:self action:@selector(onMedicDetailTouched:) forControlEvents:UIControlEventTouchUpInside];
        [medicineView addSubview:detailBtn];
        
        NSString* imgurl = PORID_IMAGE(item[@"proId"]);
        UIImageView* medicImg = [[UIImageView alloc] initWithFrame:RECT(0, 0, detailBtn.frame.size.width, detailBtn.frame.size.width)];
//        medicImg.layer.borderColor = COLOR(207, 207, 207).CGColor;
//        medicImg.layer.borderWidth = 0.5;
        medicImg.backgroundColor = [UIColor clearColor];
        [medicImg setImageWithURL:[NSURL URLWithString:imgurl]
                 placeholderImage:[UIImage imageNamed:@"药品默认图片.png"]];
        medicImg.clipsToBounds = YES;
        medicImg.contentMode = UIViewContentModeScaleToFill;
        [detailBtn addSubview:medicImg];
        
        UILabel* medicTitle = [[UILabel alloc] initWithFrame:RECT(0, medicImg.frame.size.height+5, detailBtn.frame.size.width, 24)];
        medicTitle.text = item[@"proName"];
        medicTitle.textAlignment = NSTextAlignmentCenter;
        medicTitle.textColor = [UIColor darkGrayColor];
        medicTitle.font = Font(12);
        medicTitle.numberOfLines = 1;
        [detailBtn addSubview:medicTitle];
        
        mx += (detailBtn.frame.size.width + me);
        if ((APP_W-mx)<me || (item==[self.moreDataSource lastObject])) {
            mx = me;
            pos_y += (detailBtn.frame.size.height + 10);
        }
        NSLog(@"detailBtn.h = %f",detailBtn.frame.size.height);
    }
    NSInteger numb;
    CGFloat block_h = 0;
    if (self.moreDataSource.count > 3) {
        numb = 2;
        block_h = 10;
    }else{
        numb = 1;
    }
    
    [medicineView setFrame:CGRectMake(0, labelView.frame.origin.y + labelView.frame.size.height + 10, APP_W, line.frame.origin.y + line.frame.size.height + 10 + 103*numb + 10 + block_h)];
    NSLog(@"medicineView.h = %f",medicineView.frame.size.height);
    [scrollView addSubview:medicineView];
    
    CGFloat button_h = 0.0;
    
    if (self.moreDataSource.count > 6) {
        UIButton * moreButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [moreButton setFrame:CGRectMake(220, medicineView.frame.origin.y + medicineView.frame.size.height + 10, 80, 28)];
        [moreButton setBackgroundImage:[UIImage imageNamed:@"获取验证码_绿.png"] forState:UIControlStateNormal];
        moreButton.tag = 567;
        [moreButton setTitle:@"更多药品" forState:UIControlStateNormal];
        [moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [moreButton addTarget:self action:@selector(moreButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:moreButton];
        button_h = moreButton.frame.origin.y + moreButton.frame.size.height;
    }
    
    NSLog(@"%f",button_h);

    if (self.moreDataSource.count > 6) {
        scrollView.contentSize = CGSizeMake(APP_W, button_h + 20);
    } else {
        scrollView.contentSize = CGSizeMake(APP_W, medicineView.frame.origin.y+medicineView.frame.size.height + 20);
    }
    self.oriScrollViewSize = scrollView.contentSize;
}

- (void)onMedicDetailTouched:(InfoButton*)sender
{
    DrugDetailViewController * drug = [[DrugDetailViewController alloc] init];
    drug.proId = sender.info[@"proId"];
    drug.facComeFrom = @"1";
    [self.navigationController pushViewController:drug animated:YES];
}

- (void)moreButtonClick{
    FactoryMedicineListViewController *viewControllerList = [[FactoryMedicineListViewController alloc] initWithNibName:@"FactoryMedicineListViewController" bundle:nil];
    viewControllerList.strFactoryID = self.factoryId;
    [self.navigationController pushViewController:viewControllerList animated:YES];
}

- (void)textMoreButtonClick{
    
        if (isExpand) {
            [subLabel setFrame:CGRectMake(10, 34, APP_W-20, 165)];
            isExpand = NO;
            [textMore setTitle:@"更多" forState:UIControlStateNormal];
            arrImg.image = [UIImage imageNamed:@"DownAccessory.png"];
        }else{
            [subLabel setFrame:CGRectMake(10, 34, APP_W-20, subTextHeight+10)];
            [textMore setTitle:@"收起" forState:UIControlStateNormal];
            arrImg.image = [UIImage imageNamed:@"UpAccessory.png"];
            isExpand = YES;
        }
    
    NSInteger numb;
    CGFloat block_h = 0;
    if (self.moreDataSource.count > 3) {
        numb = 2;
        block_h = 10;
    }else{
        numb = 1;
    }
    UILabel * line = (UILabel *)[medicineView viewWithTag:12345];
    [UIView animateWithDuration:0.4 animations:^{

        [textMore setFrame:CGRectMake(APP_W-83, subLabel.frame.origin.y + subLabel.frame.size.height, 83, 30)];
        [labelView setFrame:CGRectMake(0, 0, APP_W, textMore.frame.size.height + textMore.frame.origin.y)];
        [medicineView setFrame:CGRectMake(0, labelView.frame.origin.y + labelView.frame.size.height + 10, APP_W, line.frame.origin.y + line.frame.size.height + 10 + 103*numb + 10 + block_h)];
        if (self.moreDataSource.count > 6) {
            UIButton * btn = (UIButton *)[scrollView viewWithTag:567];
            [btn setFrame:CGRectMake(220, medicineView.frame.origin.y + medicineView.frame.size.height + 10, 80, 28)];
        }else{
        }
    }];
    if (isExpand) {

        if (self.moreDataSource.count > 6) {
            UIButton * btn = (UIButton *)[scrollView viewWithTag:567];
            scrollView.contentSize = CGSizeMake(APP_W, btn.frame.origin.y + btn.frame.size.height + 20);
        }else{
            scrollView.contentSize = CGSizeMake(APP_W, medicineView.frame.origin.y+medicineView.frame.size.height+20.0f);
        }
    } else {
        scrollView.contentSize = self.oriScrollViewSize;
    }
    
    
}

@end
