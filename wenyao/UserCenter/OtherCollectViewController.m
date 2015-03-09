//
//  OtherCollectViewController.m
//  wenyao
//
//  Created by Meng on 14-10-2.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "OtherCollectViewController.h"
#import "OtherCollectViewCell.h"
#import "MsgCollectCell.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "SymptomDetailViewController.h"
#import "DiseaseDetailViewController.h"
#import "SVProgressHUD.h"
#import "LoginViewController.h"
#import "HealthIndicatorDetailViewController.h"

@interface OtherCollectViewController ()<UIAlertViewDelegate>
{
    UIView * _nodataView;
}
@property (nonatomic ,strong) NSMutableArray * dataSource;


@end

@implementation OtherCollectViewController

- (id)init{
    if (self = [super init]) {
        [self.tableView setFrame:CGRectMake(0, 0, APP_W, APP_H - NAV_H -35)];
        self.tableView.rowHeight =80;
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

- (void)setCollectType:(OtherCollectType)collectType{
    _collectType = collectType;
    [self viewDidCurrentView];
}

- (void)cacheOtherList:(NSMutableArray *)arrList
{
    if (self.collectType == symptomCollect) {
        [app.dataBase removeAllMyFavSymptonList];
        for (NSDictionary *dicSympton in arrList) {
            [app.dataBase insertMyFavSymptonListWithDesc:dicSympton[@"desc"]
                                                    name:dicSympton[@"name"]
                                              population:dicSympton[@"population"]
                                                     sex:dicSympton[@"sex"]
                                                 spmCode:dicSympton[@"spmCode"]];
        }
    } else if (self.collectType == diseaseCollect) {
        [app.dataBase removeAllMyFavDiseaseList];
        for (NSDictionary *dicDisease in arrList) {
            [app.dataBase insertMyFavDiseaseListWithDiseaseId:dicDisease[@"diseaseId"]
                                                        cname:dicDisease[@"cname"]
                                                         desc:dicDisease[@"desc"]
                                                        ename:dicDisease[@"ename"]
                                                         type:dicDisease[@"type"]];
        }
    } else if (self.collectType == messageCollect) {
        [app.dataBase removeAllMyFavMessageList];
        for (NSDictionary *dicMessage in arrList) {
            [app.dataBase insertMyFavMessageListWithAdviceId:dicMessage[@"adviceId"]
                                                     iconUrl:dicMessage[@"iconUrl"]
                                                      imgUrl:dicMessage[@"imgUrl"]
                                                introduction:dicMessage[@"introduction"]
                                                  likeNumber:dicMessage[@"likeNumber"]
                                                   pariseNum:dicMessage[@"pariseNum"]
                                                 publishTime:dicMessage[@"publishTime"]
                                                   publisher:dicMessage[@"publisher"]
                                                     readNum:dicMessage[@"readNum"]
                                                       title:dicMessage[@"title"]];
        }
    }
}

- (void)getCachedList
{
    if (self.collectType == symptomCollect) {
        self.dataSource = [[app.dataBase queryAllMyFavSymptonList] mutableCopy];
        if (self.dataSource.count == 0) {
            [self showNoDataViewWithString:@"你还没有任何收藏哦!"];
        }else{
            if (_nodataView) {
                [_nodataView removeFromSuperview];
            }
            [self.tableView reloadData];
        }
    } else if (self.collectType == diseaseCollect) {
        self.dataSource = [[app.dataBase queryAllMyFavDiseaseList] mutableCopy];
        if (self.dataSource.count == 0) {
            [self showNoDataViewWithString:@"你还没有任何收藏哦!"];
        }else{
            if (_nodataView) {
                [_nodataView removeFromSuperview];
            }
            [self.tableView reloadData];
        }
    } else if (self.collectType == messageCollect) {
        self.dataSource = [[app.dataBase queryAllMyFavMessageList] mutableCopy];
        if (self.dataSource.count == 0) {
            [self showNoDataViewWithString:@"你还没有任何收藏哦!"];
        }else{
            if (_nodataView) {
                [_nodataView removeFromSuperview];
            }
            [self.tableView reloadData];
        }
    }
}

- (void)viewDidCurrentView
{
    if (self.collectType == symptomCollect) {
        if (app.currentNetWork == kNotReachable) {
            [self getCachedList];
            return;
        }
        [[HTTPRequestManager sharedInstance] querySpmCollectList:@{@"token":app.configureList[APP_USER_TOKEN],@"pageSize":@200,@"currPage":@1} completionSuc:^(id resultObj) {
            NSLog(@"症状收藏 = %@",resultObj);
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                [self.dataSource removeAllObjects];
                [self.dataSource addObjectsFromArray:resultObj[@"body"][@"data"]];
                if (self.dataSource.count == 0) {
                    [self showNoDataViewWithString:@"你还没有任何收藏哦!"];
                }else{
                    if (_nodataView) {
                        [_nodataView removeFromSuperview];
                    }
                    [self cacheOtherList:self.dataSource];
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
        
    }else if (self.collectType == diseaseCollect){
        if (app.currentNetWork == kNotReachable) {
            [self getCachedList];
            return;
        }
        [[HTTPRequestManager sharedInstance] queryDiseaseCollectList:@{@"token":app.configureList[APP_USER_TOKEN],@"pageSize":@10,@"currPage":@1} completionSuc:^(id resultObj) {
            NSLog(@"疾病收藏 = %@",resultObj);
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                [self.dataSource removeAllObjects];
                [self.dataSource addObjectsFromArray:resultObj[@"body"][@"data"]];
                
                if (self.dataSource.count == 0) {
                    [self showNoDataViewWithString:@"你还没有任何收藏哦!"];
                }else{
                    if (_nodataView) {
                        [_nodataView removeFromSuperview];
                    }
                    [self cacheOtherList:self.dataSource];
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
    }else if (self.collectType == messageCollect){
        if (app.currentNetWork == kNotReachable) {
            [self getCachedList];
            return;
        }
        [[HTTPRequestManager sharedInstance] queryAdviceCollectList:@{@"token":app.configureList[APP_USER_TOKEN],@"pageSize":@200,@"currPage":@1} completionSuc:^(id resultObj) {
            NSLog(@"信息收藏 = %@",resultObj);
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                [self.dataSource removeAllObjects];
                [self.dataSource addObjectsFromArray:resultObj[@"body"][@"data"]];
                if (self.dataSource.count == 0) {
                    [self showNoDataViewWithString:@"你还没有任何收藏哦!"];
                }else{
                    if (_nodataView) {
                        [_nodataView removeFromSuperview];
                    }
                    [self cacheOtherList:self.dataSource];
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.collectType == symptomCollect) {
        return self.dataSource.count;
    }else if (self.collectType == diseaseCollect){
        return self.dataSource.count;
    }else if (self.collectType == messageCollect){
        return self.dataSource.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellIdentifier = @"Identifier";
    static NSString * cellMsgIdentifier = @"MsgIndentifier";
    

        if (self.collectType == messageCollect)
    {
        MsgCollectCell *cell = (MsgCollectCell *)[tableView dequeueReusableCellWithIdentifier:cellMsgIdentifier];
        if (cell == nil) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"MsgCollectCell" owner:self options:nil][0];
            cell.selectedBackgroundView = [[UIView alloc]init];
            cell.selectedBackgroundView.backgroundColor = UIColorFromRGB(0xdfe4e6);
            
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(cell.titleLabel.frame.origin.x, 79.5, APP_W - cell.titleLabel.frame.origin.x, 0.5)];
            line.backgroundColor = UIColorFromRGB(0xdbdbdb);
            [cell addSubview:line];
        }
        cell.titleLabel.text = [self replaceSpecialStringWith:self.dataSource[indexPath.row][@"title"]];
        cell.subTitleLabel.text = [self replaceSpecialStringWith:self.dataSource[indexPath.row][@"introduction"]];
        [cell.imgViewMsg setImageWithURL:[NSURL URLWithString:self.dataSource[indexPath.row][@"iconUrl"]] placeholderImage:[UIImage imageNamed:@"药品默认图片.png"]];
        return cell;
    } else {
        OtherCollectViewCell * cell = (OtherCollectViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"OtherCollectViewCell" owner:self options:nil][0];
            //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.selectedBackgroundView = [[UIView alloc]init];
            cell.selectedBackgroundView.backgroundColor = UIColorFromRGB(0xdfe4e6);
            
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(cell.titleLabel.frame.origin.x, 79.5, APP_W - cell.titleLabel.frame.origin.x, 0.5)];
            line.backgroundColor = UIColorFromRGB(0xdbdbdb);
            [cell addSubview:line];
            
        }
        
        cell.titleLabel.font = Font(16.0f);
        cell.titleLabel.textColor = UIColorFromRGB(0x333333);
        cell.subTitleLabel.font = Font(14.0f);
        cell.subTitleLabel.textColor = UIColorFromRGB(0x333333);
        if (self.collectType == symptomCollect)
        {
            cell.titleLabel.text = [self replaceSpecialStringWith:self.dataSource[indexPath.row][@"name"]];
            cell.subTitleLabel.text = [self replaceSpecialStringWith:self.dataSource[indexPath.row][@"desc"]];
        }else
            if (self.collectType == diseaseCollect)
            {
                cell.titleLabel.text = [self replaceSpecialStringWith:self.dataSource[indexPath.row][@"cname"]];
                cell.subTitleLabel.text = [self replaceSpecialStringWith:self.dataSource[indexPath.row][@"desc"]];
            }
        return cell;
    }
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
    
    NSDictionary * dic = self.dataSource[indexPath.row];
    NSMutableDictionary * setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"method"] = @"3";
    //取消收藏
    if (self.collectType == symptomCollect)//症状
    {
        setting[@"objId"] = dic[@"spmCode"];
        setting[@"objType"] = @"6";
    }else
        if (self.collectType == diseaseCollect)//疾病
    {
        setting[@"objId"] = dic[@"diseaseId"];
        setting[@"objType"] = @"3";
    }else
        if (self.collectType == messageCollect)//资讯
    {
        setting[@"objId"] = dic[@"adviceId"];
        setting[@"objType"] = @"5";
    }
    
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
    if (self.collectType == symptomCollect)
    {
        SymptomDetailViewController * symptomDetail = [[SymptomDetailViewController alloc] init];
        symptomDetail.containerViewController = self.containerViewController;
        symptomDetail.title = self.dataSource[indexPath.row][@"name"];
        symptomDetail.spmCode = self.dataSource[indexPath.row][@"spmCode"];
        [self.navigationController pushViewController:symptomDetail animated:YES];
    }else if (self.collectType == diseaseCollect)
    {
        NSDictionary * dic = self.dataSource[indexPath.row];
        DiseaseDetailViewController* diseaseDetail = [[DiseaseDetailViewController alloc] initWithNibName:@"DiseaseDetailViewController" bundle:nil];
        diseaseDetail.diseaseType = dic[@"type"];
        diseaseDetail.diseaseId = dic[@"diseaseId"];
        diseaseDetail.title = dic[@"name"];
        [self.navigationController pushViewController:diseaseDetail animated:YES];
        
    }else if (self.collectType == messageCollect)
    {
        HealthIndicatorDetailViewController *detailViewController = [[HealthIndicatorDetailViewController alloc] initWithNibName:@"HealthIndicatorDetailViewController" bundle:nil];
        detailViewController.hidesBottomBarWhenPushed = YES;
        detailViewController.infoDict = [self.dataSource[indexPath.row] mutableCopy];
        [self.navigationController pushViewController:detailViewController animated:YES];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
