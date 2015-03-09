//
//  SymptomViewController.m
//  quanzhi
//
//  Created by Meng on 14-8-6.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "SymptomViewController.h"
#import "Constant.h"
#import "SymptomDetailViewController.h"
#import "HTTPRequestManager.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
//#import "ChineseString.h"
#import "UIViewController+isNetwork.h"
#import "ReturnIndexView.h"

@interface SymptomViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,ReturnIndexViewDelegate>
{
    BATableView * myTableView;
    UIView * _nodataView;
}
@property (nonatomic ,strong) NSMutableArray *rightIndexArray;
//设置每个section下的cell内容
@property (nonatomic ,strong) NSMutableArray *LetterResultArr;

@property (nonatomic ,strong) NSMutableArray * usualArray;
@property (nonatomic ,strong) NSMutableArray * unusualArray;
@property (nonatomic ,strong) NSMutableArray * dataSource;
@property (nonatomic, strong) ReturnIndexView *indexView;

@end

@implementation SymptomViewController
@synthesize rightIndexArray,LetterResultArr;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)backToPreviousController:(id)sender
{
//    if(self.containerViewController) {
//        [self.containerViewController.navigationController popViewControllerAnimated:YES];
//    }else{
    @try {
        [self.navigationController popViewControllerAnimated:YES];
        }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        
    }
    //}
}

- (void)dealloc
{
    
}



- (void)subViewWillAppear{
    
    if (self.dataSource.count > 0) {
        return;
    }
    NSMutableDictionary * setting = [NSMutableDictionary dictionary];
    setting[@"currPage"] = @"1";
    setting[@"pageSize"] = @"0";
    __weak typeof (self) weakSelf = self;
    if (self.requestType == wikiSym) {
        [[HTTPRequestManager sharedInstance] getAllSymptomListWithParam:setting completionSuc:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                [weakSelf httpRequestResult:resultObj];
            }
        } failure:^(id failMsg) {
            NSLog(@"请求失败");
        }];
    }else if (self.requestType == bodySym){
        [setting addEntriesFromDictionary:self.requsetDic];
        if (self.spmCode.length > 0) {
            setting[@"bodyCode"] = self.spmCode;
        }
        [[HTTPRequestManager sharedInstance] querySpmInfoListByBodyWithParam:setting completionSuc:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                [weakSelf httpRequestResult:resultObj];
            }
        } failure:^(id failMsg) {
            
        }];
    }else if (self.requestType == searchSym){
        setting[@"keyword"] = self.spmCode;
        [[HTTPRequestManager sharedInstance] querySpmByKeyword:setting completion:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                [weakSelf httpRequestResult:resultObj];
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)BtnClick{
    
    if(![self isNetWorking]){
        for(UIView *v in [self.view subviews]){
            if(v.tag == 999){
                [v removeFromSuperview];
            }
        }
        [self subViewWillAppear];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if([self isNetWorking]){
        [self addNetView];
        return;
    }
    [self subViewWillAppear];
    
}
- (void)httpRequestResult:(id)resultObj
{
    if (_nodataView) {
        [_nodataView removeFromSuperview];
        _nodataView = nil;
    }
    self.dataSource = resultObj[@"body"][@"data"];
    if (self.dataSource.count == 0) {
        [self showNoDataViewWithString:@"暂无相关症状"];
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        for (NSDictionary * dic in self.dataSource) {
            if ([[dic objectForKey:@"usual"] isEqualToNumber:@1]) {
                [self.usualArray addObject:dic];//常见
            }
            else{
                [self.unusualArray addObject:dic];//不常见
            }
        }
        //self.unusualArray = self.dataSource;
        //NSLog(@"不常见1 = %@",self.unusualArray);
        if (self.usualArray.count > 0) {
            [self.rightIndexArray insertObject:@"常" atIndex:0];
            [self.LetterResultArr insertObject:self.usualArray atIndex:0];
        }
        NSArray * letters = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
        NSMutableArray * currArray = [[NSMutableArray alloc]initWithArray:self.unusualArray];
        for (int i=0; i<letters.count; i++) {
            NSMutableArray * arr = [NSMutableArray array];//存放当前字母所对应dic的数组
            for (int j = 0; j < self.unusualArray.count; j++) {
                NSDictionary * dic = self.unusualArray[j];//当前的字典
                if ([dic[@"liter"] isEqualToString:letters[i]]) {
                    [arr addObject:dic];
                    [currArray removeObject:dic];
                }else
                continue;
            }
            //遍历完一次之后
            if (arr.count > 0) {
                [self.rightIndexArray addObject:letters[i]];
                [self.LetterResultArr addObject:arr];
            }
        }

        if (currArray.count > 0) {
            [self.rightIndexArray addObject:@"#"];
            [self.LetterResultArr addObject:currArray];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [myTableView reloadData];
        });
    });
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.requestType == wikiSym) {
        self.title = @"症状百科";
    }
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    self.dataSource = [NSMutableArray array];
    self.usualArray = [NSMutableArray array];
    self.unusualArray = [NSMutableArray array];
    self.rightIndexArray = [NSMutableArray array];
    self.LetterResultArr = [NSMutableArray array];
    [self makeTableView];
    // Do any additional setup after loading the view.
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

- (void)makeTableView
{
    myTableView = [[BATableView alloc] init];
    if (self.requestType == wikiSym) {
        myTableView = [[BATableView alloc]initWithFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H-35)];
    }else{
        myTableView = [[BATableView alloc]initWithFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H)];
    }

    myTableView.backgroundColor = UIColorFromRGB(0xecf0f1);
    myTableView.delegate = self;
    [self.view addSubview:myTableView];
}

#pragma mark - UITableViewDataSource
- (NSArray *) sectionIndexTitlesForABELTableView:(BATableView *)tableView {
    return self.rightIndexArray;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.rightIndexArray.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.LetterResultArr[section];
    return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellName = @"UITableViewCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];

        UIView *bkView = [[UIView alloc]initWithFrame:cell.frame];
        bkView.backgroundColor = UIColorFromRGB(0xdfe4e6);
        cell.selectedBackgroundView = bkView;
        
        cell.selectedBackgroundView = [[UIView alloc]init];
        cell.selectedBackgroundView.backgroundColor = UIColorFromRGB(0xdfe4e6);
    }
    cell.textLabel.frame = CGRectMake(10, cell.textLabel.frame.origin.y, cell.textLabel.frame.size.width, cell.textLabel.frame.size.height);
    cell.textLabel.text = self.LetterResultArr[indexPath.section][indexPath.row][@"name"];
    cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
    cell.textLabel.textColor = UIColorFromRGB(0x333333);
    
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 44-0.5, 320, 0.5)];
    [separator setBackgroundColor:UIColorFromRGB(0xdbdbdb)];
    [cell.contentView addSubview:separator];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 28;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * v = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , APP_W, 28)];
    v.backgroundColor = UIColorFromRGB(0xf2f2f2);
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 28)];
    label.font = [UIFont systemFontOfSize:12.0f];
    label.textColor = UIColorFromRGB(0x666666);
    if (section == 0 && self.usualArray.count > 0) {
        label.text = @"常见症状";
    }else{
       label.text = self.rightIndexArray[section];
    }
    [v addSubview:label];
    return v;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath*    selection = [myTableView.tableView indexPathForSelectedRow];
    if (selection) {
        [myTableView.tableView deselectRowAtIndexPath:selection animated:YES];
    }
//    if (app.currentNetWork == kNotReachable) {
//        [SVProgressHUD showErrorWithStatus:@"当前暂无网络,请稍后重试!" duration:0.8f];
//        return;
//    }
    SymptomDetailViewController * symptomDetailViewController = [[SymptomDetailViewController alloc] init];
    symptomDetailViewController.title = self.LetterResultArr[indexPath.section][indexPath.row][@"name"];
    symptomDetailViewController.spmCode = self.LetterResultArr[indexPath.section][indexPath.row][@"spmCode"];
    symptomDetailViewController.containerViewController = self.containerViewController;
    
    if (self.containerViewController) {
        [self.containerViewController.navigationController pushViewController:symptomDetailViewController animated:YES];
    }else{
        [self.navigationController pushViewController:symptomDetailViewController animated:YES];
    }
}

- (NSString *)getCachedSymptomListPath
{
    NSString *homePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"Documents/symptomList.plist"]];
    return homePath;
}

- (void)cacheAllSymptom:(NSDictionary *)dicCache
{
    NSFileManager *fmManager = [NSFileManager defaultManager];
    NSString *strCacheList = [self getCachedSymptomListPath];
    if ([fmManager fileExistsAtPath:strCacheList]) {
        [fmManager removeItemAtPath:strCacheList error:nil];
    }
    [dicCache writeToFile:strCacheList atomically:YES];
}

- (NSDictionary *)getCachedSymptom
{
    NSString *strCacheList = [self getCachedSymptomListPath];
    NSDictionary *dicCache = [NSDictionary dictionaryWithContentsOfFile:strCacheList];
    return dicCache;
}

- (void)viewDidCurrentView
{
    if (self.dataSource.count) {
        return;
    }
    if (app.currentNetWork == kNotReachable) {
        NSDictionary *dicCached = [self getCachedSymptom];
        [self httpRequestResult:dicCached];
        if(!self.dataSource.count > 0){
            [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
            return;
        }
    } else {
        NSMutableDictionary * setting = [NSMutableDictionary dictionary];
        if (self.requestType == wikiSym) {
            setting[@"currPage"] = @"1";
            setting[@"pageSize"] = @"0";
            [[HTTPRequestManager sharedInstance] getAllSymptomListWithParam:setting completionSuc:^(id resultObj) {
                if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                    [self httpRequestResult:resultObj];
                    [self cacheAllSymptom:resultObj];
                }
            } failure:^(id failMsg) {
                NSLog(@"请求失败");
            }];
        }
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.scrollBlock) {
        self.scrollBlock();
    }
}

#pragma mark - INDICTOR
-(void)showNoDataViewWithString:(NSString *)nodataPrompt
{
    if (_nodataView) {
        [_nodataView removeFromSuperview];
        _nodataView = nil;
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

@end
