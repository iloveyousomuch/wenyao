//
//  MedicineCollectViewController.m
//  wenyao
//
//  Created by Meng on 14-10-2.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "MedicineCollectViewController.h"
#import "MedicineListCell.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "DrugDetailViewController.h"
#import "SVProgressHUD.h"
#import "LoginViewController.h"

@interface MedicineCollectViewController ()<UIAlertViewDelegate>
{
    UIView * _nodataView;
}
@property (nonatomic ,strong) NSMutableArray * dataSource;

@end

@implementation MedicineCollectViewController

- (id)init{
    if (self = [super init]) {
        self.tableView.frame = CGRectMake(0, 0, APP_W, APP_H-NAV_H - 35);
        self.tableView.rowHeight = 88;
        if (iOSv7 && self.view.frame.origin.y==0) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = NO;
        }
        self.dataSource = [NSMutableArray array];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = UIColorFromRGB(0xecf0f1);
    }
    return self;
}

- (void)cacheAllMedicineList:(NSMutableArray *)arrMedicineList
{
    [app.dataBase removeAllMyFavMedicineList];
    for (NSDictionary *dicMedicine in self.dataSource) {
        [app.dataBase insertMyFavMedicineListWithFactory:dicMedicine[@"factory"]
                                                      Id:dicMedicine[@"id"]
                                                   proId:dicMedicine[@"proId"]
                                                 proName:dicMedicine[@"proName"]
                                                    spec:dicMedicine[@"spec"]];
    }
}

- (void)getCachedMedicineList
{
    self.dataSource = [[app.dataBase queryAllMyFavMedicineList] mutableCopy];
    if (self.dataSource.count == 0) {
        [self showNoDataViewWithString:@"你还没有任何收藏哦!"];
    } else {
        if (_nodataView) {
            [_nodataView removeFromSuperview];
        }
        [self.tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (app.currentNetWork == kNotReachable) {
        [self getCachedMedicineList];
    } else {
        [[HTTPRequestManager sharedInstance] favoriteProductCollectList:@{@"token":app.configureList[APP_USER_TOKEN],@"currPage":@1,@"pageSize":@200} completionSuc:^(id resultObj) {
            NSLog(@"药品收藏 = %@",resultObj);
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                [self.dataSource removeAllObjects];
                [self.dataSource addObjectsFromArray:resultObj[@"body"][@"data"]];
                [self cacheAllMedicineList:self.dataSource];
                if (self.dataSource.count == 0) {
                    [self showNoDataViewWithString:@"你还没有任何收藏哦!"];
                }else{
                    if (_nodataView) {
                        [_nodataView removeFromSuperview];
                    }
                    [self.tableView reloadData];
                }
            }else if ([resultObj[@"result"] isEqualToString:@"FAIL"]){
                if ([resultObj[@"msg"] isEqualToString:@"1"]) {
                    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:ALERT_MESSAGE delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    alertView.delegate = self;
                    [alertView show];
                    return;
                }else{
                    [SVProgressHUD showErrorWithStatus:resultObj[@"msg"] duration:DURATION_SHORT];
                }
            }
        } failure:^(id failMsg) {
            NSLog(@"%@",failMsg);
        }];
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        LoginViewController * login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        login.isPresentType = YES;
        login.parentNavgationController = self.navigationController;
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:login];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 88;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellIdentifier = @"cellIdentifier";
    MedicineListCell * cell = (MedicineListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MedicineListCell" owner:self options:nil][0];
 
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 87.5, APP_W, 0.5)];
        line.backgroundColor = UIColorFromRGB(0xdbdbdb);
        [cell addSubview:line];
        
        cell.selectedBackgroundView = [[UIView alloc]init];
        cell.selectedBackgroundView.backgroundColor = UIColorFromRGB(0xdfe4e6);
    }
    
    NSString * imageUrl = PORID_IMAGE(self.dataSource[indexPath.row][@"proId"]);
    [cell.headImageView setImageWithURL:[NSURL URLWithString:imageUrl]];
    if (cell.headImageView.image == nil) {
        cell.headImageView.image = [UIImage imageNamed:@"药品默认图片.png"];
    }
    cell.topTitle.text = self.dataSource[indexPath.row][@"proName"];
    cell.middleTitle.text = self.dataSource[indexPath.row][@"spec"];
    cell.addressLabel.text = self.dataSource[indexPath.row][@"factory"];
    
    return cell;
}

//////////滑动删除//////////

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"删除 = %@",indexPath);
    
    //取消收藏
    NSDictionary * dic = self.dataSource[indexPath.row];
    NSMutableDictionary * setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"method"] = @"3";
    setting[@"objId"] = dic[@"id"];
    setting[@"objType"] = @"1";

    [[HTTPRequestManager sharedInstance] favoriteCollect:setting completion:^(id resultObj) {
        if ([resultObj[@"body"][@"result"] isEqualToString:@"3"]) {
            [SVProgressHUD showSuccessWithStatus:@"取消收藏成功" duration:DURATION_SHORT];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
    [self.dataSource removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    if (self.dataSource.count == 0) {
        [self showNoDataViewWithString:@"你还没有任何收藏哦!"];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSIndexPath*    selection = [self.tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
//    if (app.currentNetWork == kNotReachable) {
//        [SVProgressHUD showErrorWithStatus:@"当前暂无网络,请稍后重试!" duration:0.8f];
//        return;
//    }
    DrugDetailViewController * drugDetail = [[DrugDetailViewController alloc] init];
    NSDictionary * dic = self.dataSource[indexPath.row];
    drugDetail.proId = dic[@"proId"];
    
    [self.navigationController pushViewController:drugDetail animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidCurrentView{
    if (app.currentNetWork == kNotReachable) {
        [self getCachedMedicineList];
    } else {
        NSMutableDictionary * setting = [NSMutableDictionary dictionary];
        setting[@"token"] = app.configureList[APP_USER_TOKEN];
        setting[@"currPage"] = @1;
        setting[@"pageSize"] = @200;
        
        [[HTTPRequestManager sharedInstance] favoriteProductCollectList:setting completionSuc:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"])
            {
                [self.dataSource removeAllObjects];
                [self.dataSource addObjectsFromArray:resultObj[@"body"][@"data"]];
                [self cacheAllMedicineList:self.dataSource];
                if (self.dataSource.count == 0) {
                    [self showNoDataViewWithString:@"你还没有任何收藏哦!"];
                }else{
                    if (_nodataView) {
                        [_nodataView removeFromSuperview];
                    }
                    [self.tableView reloadData];
                }
            }else if ([resultObj[@"result"] isEqualToString:@"FAIL"])
            {
                if ([resultObj[@"msg"] isEqualToString:@"1"]) {
                    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:ALERT_MESSAGE delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    alertView.delegate = self;
                    [alertView show];
                    return;
                }else{
                    [SVProgressHUD showErrorWithStatus:resultObj[@"msg"] duration:DURATION_SHORT];
                }
            }
        } failure:^(id failMsg) {
            NSLog(@"%@",failMsg);
        }];
    }
    
}

//显示没有历史搜索记录view
-(void)showNoDataViewWithString:(NSString *)nodataPrompt
{
    if (_nodataView) {
        [_nodataView removeFromSuperview];
    }
    _nodataView = [[UIView alloc]initWithFrame:self.view.bounds];
    //_nodataView.backgroundColor = COLOR(242, 242, 242);
    _nodataView.backgroundColor = BG_COLOR;
    
//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]init];
//    [tap addTarget:self action:@selector(keyboardHidenClick)];
//    [_nodataView addGestureRecognizer:tap];
    UIImage * noCollectImage = [UIImage imageNamed:@"无收藏.png"];
    
    UIImageView *dataEmpty = [[UIImageView alloc]initWithFrame:RECT(0, 0, noCollectImage.size.width, noCollectImage.size.height)];
    dataEmpty.center = CGPointMake(APP_W/2, 110);
    dataEmpty.image = noCollectImage;
    [_nodataView addSubview:dataEmpty];
    
    UILabel* lable_ = [[UILabel alloc]initWithFrame:RECT(0,dataEmpty.frame.origin.y + dataEmpty.frame.size.height + 10, nodataPrompt.length*20,30)];
    lable_.font = Font(12);
    lable_.textColor = COLOR(137, 136, 155);
    lable_.textAlignment = NSTextAlignmentCenter;
    lable_.center = CGPointMake(APP_W/2, lable_.center.y);
    lable_.text = nodataPrompt;
    
    [_nodataView addSubview:lable_];
    //[[UIApplication sharedApplication].keyWindow addSubview:_nodataView];
    [self.view insertSubview:_nodataView atIndex:self.view.subviews.count];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
