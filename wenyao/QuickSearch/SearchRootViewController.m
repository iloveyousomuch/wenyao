//
//  SearchParentViewController.m
//  wenyao
//
//  Created by Meng on 14-9-20.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "SearchRootViewController.h"
#import "HTTPRequestManager.h"
#import "ZhPMethod.h"
#import "DiseaseDetailViewController.h"
#import "Constant.h"
#import "MJRefresh.h"
#import "SearchDisease_SymptomListViewController.h"
#import "SearchMedicineListViewController.h"

@interface SearchRootViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UIView * _nodataView;
    UIView *  footView;
    UIView * bgView;
    
    NSInteger currentPage;

}
@property (nonatomic ,strong) UITableView * mTableView;
@property (nonatomic ,strong) NSMutableArray * dataSource;
@property (nonatomic ,strong) NSMutableArray * searchHistoryArray;
@end

@implementation SearchRootViewController
@synthesize searchBar = _searchBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.mTableView.rowHeight = 35;
    }
    return self;
}

- (void)setSearchBar:(UISearchBar *)searchBar
{
    _searchBar = searchBar;
    
}

- (void)setKeyWord:(NSString *)keyWord{
    _keyWord = keyWord;
    [self keyWordSet];
}

- (void)keyWordSet
{
    
    if (self.keyWord.length == 0 || self.keyWord == nil) {
        
        if (_nodataView) {
            [_nodataView removeFromSuperview];
            _nodataView = nil;
        }
        if (bgView) {
            [bgView removeFromSuperview];
            bgView = nil;
        }
        //判断搜索类型
        switch (self.histroySearchType)
        {
            case 0:
                self.searchHistoryArray = [[NSMutableArray alloc] initWithArray:getHistoryConfig(@"medicineSearch")];
                break;
            case 1:
                self.searchHistoryArray = [[NSMutableArray alloc] initWithArray:getHistoryConfig(@"diseaseSearch")];
                break;
            case 2:
                self.searchHistoryArray = [[NSMutableArray alloc] initWithArray:getHistoryConfig(@"symptomSearch")];
                break;
            default:
                break;
        }
        if (self.searchHistoryArray.count > 0) {
            footView.hidden = NO;
            [footView setFrame:CGRectMake(0, self.mTableView.frame.size.height+self.mTableView.frame.origin.y, APP_W, 200)];
            [self.mTableView reloadData];
        }else{
            [self showNoSearchHistory];
        }
    }else{
        if (bgView) {
            [bgView removeFromSuperview];
            bgView = nil;
        }
        
        [footView setFrame:CGRectMake(0, self.mTableView.frame.size.height+self.mTableView.frame.origin.y, APP_W, 0)];
        footView.hidden = YES;
        self.mTableView.frame = CGRectMake(0, 0, APP_W, APP_H-35-NAV_H);
        currentPage = 1;
        [self.mTableView addFooterWithTarget:self action:@selector(footerRereshing)];
        self.mTableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
        self.mTableView.footerReleaseToRefreshText = @"松开加载更多数据了";
        self.mTableView.footerRefreshingText = @"正在帮你加载中";
        self.loadMore = NO;
        [self loadDataWithKeyWord:self.keyWord];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpTableView];
    [self setUpTableViewFootView];
}

#pragma mark ------ setup ------
- (void)setUpTableView{
    self.mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H + 20) style:UITableViewStylePlain];
    self.mTableView.delegate = self;
    self.mTableView.dataSource = self;
    self.mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.mTableView.backgroundColor = UIColorFromRGB(0xecf0f1);
    [self.view addSubview:self.mTableView];
}

- (void)setUpTableViewFootView{
    
    footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 20)];
    footView.backgroundColor = [UIColor whiteColor];
    footView.clipsToBounds = YES;
    
    UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"清空搜索记录icon.png"]];
    image.frame = CGRectMake(APP_W*0.35 - 20, 15, 15, 15);
    
    UIButton * clearBtn = [[UIButton alloc]initWithFrame:CGRectMake(APP_W*0.35, 15, 100, 15)];
//    clearBtn.layer.borderWidth = 0.5;
//    clearBtn.layer.borderColor = UIColorFromRGB(0xd1d1d1).CGColor;
    clearBtn.titleLabel.font = Font(15);
    [clearBtn setTitle:@"清空搜索历史" forState:0];
    [clearBtn setTitleColor:UIColorFromRGB(0x666666) forState:0];
    [clearBtn setBackgroundColor:[UIColor clearColor]];
    [clearBtn addTarget:self action:@selector(onClearBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [footView addSubview:image];
    [footView addSubview:clearBtn];
    NSLog(@"高度%f",footView.frame.size.height);
   
    self.mTableView.tableFooterView.frame = footView.frame;
    self.mTableView.tableFooterView = footView;
}

#pragma mark ------数据请求------
- (void)loadDataWithKeyWord:(NSString *)keyWord
{
    NSMutableDictionary * setting = [NSMutableDictionary dictionary];
    setting[@"keyword"] = keyWord;
    setting[@"currPage"] = @(currentPage);
    setting[@"pageSize"] = @10;
    if (self.histroySearchType == 0){
        setting[@"type"] = @"0";
    }else if (self.histroySearchType == 1){
        setting[@"type"] = @"1";
    }else if (self.histroySearchType == 2){
        setting[@"type"] = @"2";
    }
    [[HTTPRequestManager sharedInstance] searchByKeyword:setting completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            if(self.loadMore)
            {
                NSArray *array = resultObj[@"body"][@"data"];
                if(array.count > 0)
                    [self.dataSource addObjectsFromArray:array];
            }else{
                self.dataSource = [NSMutableArray array];
               [self.dataSource addObjectsFromArray: resultObj[@"body"][@"data"]];
            }
            if (self.dataSource.count > 0) {
                if (_nodataView) {
                    [_nodataView removeFromSuperview];
                    _nodataView = nil;
                }
                [self.mTableView reloadData];
                currentPage++;
                [self.mTableView footerEndRefreshing];
            }else{
                //没有搜索结果
                [self showNoDataViewWithString:@"没有搜索结果"];
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}


- (void)footerRereshing
{
    self.loadMore = YES;
    [self loadDataWithKeyWord:self.keyWord];
}

#pragma mark ------ Table view data source -------

- (NSInteger)tableView:(UITableView *)tawbleView numberOfRowsInSection:(NSInteger)section{
    if (self.keyWord.length == 0) {
        return self.searchHistoryArray.count;
    }
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellIdentifier = @"cellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.font = Font(12);
    if (self.keyWord.length > 0) {
        cell.textLabel.frame = CGRectMake(14, cell.textLabel.frame.origin.y, cell.textLabel.frame.size.width, cell.textLabel.frame.size.height);
        cell.textLabel.text = self.dataSource[indexPath.row][@"kwName"];
        cell.textLabel.font = Font(16.0f);
        cell.textLabel.textColor = UIColorFromRGB(0x666666);
    
        UIView *bkView = [[UIView alloc]initWithFrame:cell.frame];
        bkView.backgroundColor = UIColorFromRGB(0xdfe4e6);
        cell.selectedBackgroundView = bkView;
        
    }else{
        cell.textLabel.text = self.searchHistoryArray[indexPath.row];
        cell.textLabel.font = Font(15.0f);
        cell.textLabel.textColor = UIColorFromRGB(0x666666);
        
    }
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(14, 44.5, APP_W - 14, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [cell addSubview:line];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath*    selection = [self.mTableView indexPathForSelectedRow];
    if (selection) {
        [self.mTableView deselectRowAtIndexPath:selection animated:YES];
    }
    if (self.keyWord.length > 0 && self.dataSource.count > 0) {//搜索表
        if ([self.searchHistoryArray containsObject:self.keyWord]) {
            [self.searchHistoryArray removeObject:self.keyWord];
        }
        if (self.searchHistoryArray.count == 5) {
            [self.searchHistoryArray removeObjectAtIndex:self.searchHistoryArray.count-1];
        }
        
        [self.searchHistoryArray insertObject:self.keyWord atIndex:0];
        NSDictionary * dic = self.dataSource[indexPath.row];
        switch (self.histroySearchType) {
            case 0:
            {
                setHistoryConfig(@"medicineSearch", self.searchHistoryArray);
                SearchMedicineListViewController * medicineList = [[SearchMedicineListViewController alloc] init];
                medicineList.kwId = dic[@"kwId"];
                medicineList.title = dic[@"kwName"];
                [self.navigation pushViewController:medicineList animated:YES];
            }
                break;
            case 1:
            {
                setHistoryConfig(@"diseaseSearch", self.searchHistoryArray);
                SearchDisease_SymptomListViewController * searchDisease_Symptom = [[SearchDisease_SymptomListViewController alloc] init];
                searchDisease_Symptom.requsetType = RequsetTypeDisease;
                searchDisease_Symptom.kwId = dic[@"kwId"];
                searchDisease_Symptom.title = dic[@"kwName"];
                [self.navigation pushViewController:searchDisease_Symptom animated:YES];
            }
                break;
            case 2:
            {
                setHistoryConfig(@"symptomSearch", self.searchHistoryArray);
                SearchDisease_SymptomListViewController * searchDisease_Symptom = [[SearchDisease_SymptomListViewController alloc] init];
                searchDisease_Symptom.requsetType = RequsetTypeSymptom;
                searchDisease_Symptom.kwId = dic[@"kwId"];
                searchDisease_Symptom.title = dic[@"kwName"];
                
                searchDisease_Symptom.containerViewController = self.containerViewController;
                //[self.navigation pushViewController:searchDisease_Symptom animated:YES];
                if (self.containerViewController) {
                    [self.containerViewController.navigationController pushViewController:searchDisease_Symptom animated:YES];
                }else
                {
                    [self.navigationController pushViewController:searchDisease_Symptom animated:YES];
                }
            }
                break;
            default:
                break;
        }
    }else{
        NSString * historyKeyWord = self.searchHistoryArray[indexPath.row];
        self.keyWord = historyKeyWord;
        [self keyWordSet];
        if ([self.delegate respondsToSelector:@selector(searchBarText:)]) {
            [self.delegate searchBarText:historyKeyWord];
        }

    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.keyWord.length == 0) {
        return 30;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.keyWord.length == 0) {
        UIView * v = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , APP_W, 12)];
        v.backgroundColor = UICOLOR(238, 238, 238);
        
        UIImage* icon = [UIImage imageNamed:@"clock.png"];
        UIImageView* iconView = [[UIImageView alloc ] initWithImage:icon];
        iconView.frame = RECT(14, 9, icon.size.width, icon.size.height);
        [v addSubview:iconView];
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(14+icon.size.width+5, 9, 200, 12)];
        label.font = [UIFont systemFontOfSize:12.0f];
        label.text = @"最近搜索";
        [v addSubview:label];
        return v;
    }
    return nil;
}

 
- (void)onClearBtnTouched:(UIButton *)button{
    [self.searchHistoryArray removeAllObjects];
    switch (self.histroySearchType) {
        case 0://清除药品搜索历史
            setHistoryConfig(@"medicineSearch",nil);
            break;
        case 1://清除疾病搜索历史
            setHistoryConfig(@"diseaseSearch",nil);
            break;
        case 2://清除症状搜索历史
            setHistoryConfig(@"symptomSearch",nil);
            break;
        default:
            break;
    }
    self.keyWord = @"";
    [self keyWordSet];
}

#pragma mark ------其他函数方法------
- (void)viewDidCurrentView{
    
}

//显示没有历史搜索记录view
-(void)showNoDataViewWithString:(NSString *)nodataPrompt
{
    if (_nodataView) {
        [_nodataView removeFromSuperview];
        _nodataView = nil;
    }
    _nodataView = [[UIView alloc]initWithFrame:self.view.bounds];
    //_nodataView.backgroundColor = COLOR(242, 242, 242);
    _nodataView.backgroundColor = BG_COLOR;
    
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]init];
    [tap addTarget:self action:@selector(keyboardHidenClick)];
    [_nodataView addGestureRecognizer:tap];
    UIImage * searchImage = [UIImage imageNamed:@"没有搜索结果icon.png"];
    
    UIImageView *dataEmpty = [[UIImageView alloc]initWithFrame:RECT(0, 0, searchImage.size.width, searchImage.size.height)];
    dataEmpty.center = CGPointMake(APP_W/2, 110);
    dataEmpty.image = searchImage;
    [_nodataView addSubview:dataEmpty];
    
    UILabel* lable_ = [[UILabel alloc]initWithFrame:RECT(0,dataEmpty.frame.origin.y + dataEmpty.frame.size.height + 10, nodataPrompt.length*20,30)];
    lable_.font = Font(12);
    lable_.textColor = COLOR(137, 136, 155);
    lable_.textAlignment = NSTextAlignmentCenter;
    lable_.center = CGPointMake(APP_W/2, lable_.center.y);
    lable_.text = nodataPrompt;
        
    [_nodataView addSubview:lable_];
    [self.view insertSubview:_nodataView atIndex:self.view.subviews.count];
}

//显示没有搜索记录

- (void)showNoSearchHistory
{
    if (bgView) {
        [bgView removeFromSuperview];
        bgView = nil;
    }
    bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    //bgView.backgroundColor = COLOR(242, 242, 242);
    bgView.backgroundColor = BG_COLOR;
    
    UILabel* lable_ = [[UILabel alloc]initWithFrame:RECT(0,140, APP_W, 30)];
    lable_.font = Font(15);
    lable_.textColor = UIColorFromRGB(0x7f8d96);
    lable_.textAlignment = NSTextAlignmentCenter;
    lable_.center = CGPointMake(APP_W/2, lable_.center.y);
    lable_.text = @"暂无搜索记录";
    [bgView addSubview:lable_];
    [self.view insertSubview:bgView atIndex:self.view.subviews.count];
}

- (void)keyboardHidenClick{
    if (self.scrollBlock) {
        self.scrollBlock();
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.scrollBlock) {
        self.scrollBlock();
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
