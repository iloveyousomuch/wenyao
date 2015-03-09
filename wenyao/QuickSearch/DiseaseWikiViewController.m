//
//  DiseaseWikiViewController.m
//  quanzhi
//
//  Created by Meng on 14-9-16.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "DiseaseWikiViewController.h"
#import "BATableView.h"
#import "HTTPRequestManager.h"
#import "DiseaseDetailViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
@interface DiseaseWikiViewController ()<BATableViewDelegate>
{
    BATableView * myTableView;
}
@property (nonatomic ,strong) NSMutableArray *rightIndexArray;
//设置每个section下的cell内容
@property (nonatomic ,strong) NSMutableArray *LetterResultArr;

@property (nonatomic ,strong) NSMutableArray * usualArray;
@property (nonatomic ,strong) NSMutableArray * unusualArray;
@property (nonatomic ,strong) NSMutableArray * dataSource;
@end

@implementation DiseaseWikiViewController
@synthesize rightIndexArray,LetterResultArr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    
    if (self.dataSource.count > 1) {
        return;
    }
    if (app.currentNetWork == kNotReachable) {
        NSDictionary *dicCached = [self getCachedDiseaseWiki];
        [self httpRequestResult:dicCached];
    } else {
        NSMutableDictionary * setting = [NSMutableDictionary dictionary];
        setting[@"currPage"] = @"1";
        setting[@"pageSize"] = @"0";
        [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeClear];
        [[HTTPRequestManager sharedInstance] queryAllDisease:setting completion:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                [SVProgressHUD dismiss];
                [self cacheAllDiseaseWiki:resultObj];
                [self httpRequestResult:resultObj];
            }
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
        }];
    }
    
}

- (NSString *)getCachedDiseaseWikiListPath
{
    NSString *homePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"Documents/diseaseWikiList.plist"]];
    return homePath;
}

- (void)cacheAllDiseaseWiki:(NSDictionary *)dicCache
{
    NSFileManager *fmManager = [NSFileManager defaultManager];
    NSString *strCacheList = [self getCachedDiseaseWikiListPath];
    if ([fmManager fileExistsAtPath:strCacheList]) {
        [fmManager removeItemAtPath:strCacheList error:nil];
    }
    [dicCache writeToFile:strCacheList atomically:YES];
}

- (NSDictionary *)getCachedDiseaseWiki
{
    NSString *strCacheList = [self getCachedDiseaseWikiListPath];
    NSDictionary *dicCache = [NSDictionary dictionaryWithContentsOfFile:strCacheList];
    return dicCache;
}

- (void)httpRequestResult:(id)resultObj
{
    self.dataSource = resultObj[@"body"][@"data"];
    for (NSDictionary * dic in self.dataSource)
    {
        NSArray *subArray = dic[@"charValue"];
        for(NSDictionary *subDict in subArray) {
            if ([[subDict objectForKey:@"usual"] isEqualToNumber:@1]) {
                [self.usualArray addObject:subDict];//常见
            }
            else{
                [self.unusualArray addObject:subDict];//不常见
            }
        }
    }
    if (self.usualArray.count > 0) {
        [self.rightIndexArray insertObject:@"常" atIndex:0];
        [self.LetterResultArr insertObject:self.usualArray atIndex:0];
    }
    for (NSDictionary *dict in self.dataSource)
    {
        NSString *charKey = dict[@"charKey"];
        [self.rightIndexArray addObject:charKey];
        [self.LetterResultArr addObject:dict[@"charValue"]];
    }
    
//    NSArray * letters = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
//    NSMutableArray * currArray = [[NSMutableArray alloc] initWithArray:self.unusualArray];
//    for (int i=0; i < letters.count; i++) {
//        NSMutableArray * arr = [NSMutableArray array];//存放当前字母所对应dic的数组
//        for (int j = 0; j < self.unusualArray.count; j++) {
//            NSDictionary * dic = self.unusualArray[j];//当前的字典
//            if ([dic[@"liter"] isEqualToString:letters[i]]) {
//                [arr addObject:dic];
//                [currArray removeObject:dic];
//            }else
//                continue;
//        }
//        //遍历完一次之后
//        if (arr.count > 0) {
//            [self.rightIndexArray addObject:letters[i]];
//            
//        }
//    }
//    if (currArray.count > 0) {
//        [self.rightIndexArray addObject:@"#"];
//        [self.LetterResultArr addObject:currArray];
//    }
    
    [myTableView reloadData];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"疾病百科";
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
}

- (void)makeTableView
{
    myTableView = [[BATableView alloc]init];
    myTableView = [[BATableView alloc]initWithFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H-35)];
    myTableView.delegate = self;
    myTableView.backgroundColor = UIColorFromRGB(0xf2f2f2);
    [self.view addSubview:myTableView];
}

#pragma mark - UITableViewDataSource
- (NSArray *) sectionIndexTitlesForABELTableView:(BATableView *)tableView {
    return self.rightIndexArray;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 28;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0f;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.rightIndexArray.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(NSArray *)self.LetterResultArr[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellName = @"UITableViewCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        
        cell.selectedBackgroundView = [[UIView alloc]init];
        cell.selectedBackgroundView.backgroundColor = UIColorFromRGB(0xdfe4e6);
    }
    if((indexPath.row + 1) != [(NSArray *)self.LetterResultArr[indexPath.section] count]){
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 45 - 0.5, 550, 0.5)];
        [separator setBackgroundColor:UIColorFromRGB(0xdbdbdb)];
        [cell.contentView addSubview:separator];
    }
    
    cell.textLabel.font = Font(16);
    cell.textLabel.textColor = UIColorFromRGB(0x333333);
    cell.textLabel.frame = CGRectMake(10, cell.textLabel.frame.origin.y, cell.textLabel.frame.size.width, cell.textLabel.frame.size.height);
    cell.textLabel.text = self.LetterResultArr[indexPath.section][indexPath.row][@"name"];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView * v = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , APP_W, 28)];
    v.backgroundColor = UIColorFromRGB(0xf2f2f2);
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 28)];
    label.font = [UIFont systemFontOfSize:12.0f];
    if (section == 0 && self.usualArray.count > 0) {
        label.text = @"常见症状";
    }else{
        label.text = self.rightIndexArray[section];
        NSLog(@"%@",self.rightIndexArray[section]);
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
//        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
//        return;
//    }
    DiseaseDetailViewController* diseaseDetailViewController = [[DiseaseDetailViewController alloc] initWithNibName:@"DiseaseDetailViewController" bundle:nil];
    diseaseDetailViewController.diseaseType = self.LetterResultArr[indexPath.section][indexPath.row][@"type"];
    diseaseDetailViewController.diseaseId = self.LetterResultArr[indexPath.section][indexPath.row][@"diseaseId"];
    diseaseDetailViewController.title = self.LetterResultArr[indexPath.section][indexPath.row][@"name"];
//    NSString *type = self.LetterResultArr[indexPath.section][indexPath.row][@"type"];
//    if(![type isEqualToString:@"B"]){
//        diseaseDetailViewController.controllerName = @"wikiViewController";
//    }
    [self.navigationController pushViewController:diseaseDetailViewController animated:YES];
}

- (void)viewDidCurrentView
{
    if (self.dataSource.count > 1) {
        return;
    }
    if (app.currentNetWork == kNotReachable) {
        NSDictionary *dicCached = [self getCachedDiseaseWiki];
        [self httpRequestResult:dicCached];
    } else {
        NSMutableDictionary * setting = [NSMutableDictionary dictionary];
        setting[@"currPage"] = @"1";
        setting[@"pageSize"] = @"0";
        [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeClear];
        [[HTTPRequestManager sharedInstance] queryAllDisease:setting completion:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                [SVProgressHUD dismiss];
                [self cacheAllDiseaseWiki:resultObj];
                [self httpRequestResult:resultObj];
            }
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            NSLog(@"请求失败");
        }];
    }
}


@end
