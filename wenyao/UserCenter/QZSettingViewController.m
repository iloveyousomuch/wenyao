//
//  QZSettingViewController.m
//  wenyao
//
//  Created by Meng on 15/1/21.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "QZSettingViewController.h"

#import "MessageSettingViewController.h"
#import "ChangePasswdViewController.h"
#import "SVProgressHUD.h"
#import "SDImageCache.h"
#import "AppDelegate.h"
#import "ReturnIndexView.h"

#define F_TITLE  14
#define F_DESC   12

#define kTableRowHeight     45

@interface QZSettingViewController()<ReturnIndexViewDelegate>

{
    NSArray *titleArray;
}
@property (nonatomic ,strong) UIButton *quitOut;//退出按钮
@property (nonatomic ,copy) NSString * cacheBulk;
@property (nonatomic, strong) ReturnIndexView *indexView;

@end


@implementation QZSettingViewController


- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"设置";
        self.tableView.rowHeight = 45;
        self.tableView.scrollEnabled = NO;
        
        
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    long long cacheSize = [SDImageCache sharedImageCache].getSize;
    
    self.quitOut = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.quitOut setFrame:CGRectMake(10, kTableRowHeight * 3 + 20, APP_W-20, 40)];
    [self.quitOut addTarget:self action:@selector(quitOutClick) forControlEvents:UIControlEventTouchUpInside];
    [self.quitOut setBackgroundImage:[UIImage imageNamed:@"btnLogoutBack"] forState:UIControlStateNormal];
    [self.quitOut setBackgroundImage:[UIImage imageNamed:@"btnLogoutPressed"] forState:UIControlStateHighlighted];
    [self.quitOut setBackgroundImage:[UIImage imageNamed:@"btnLogoutPressed"] forState:UIControlStateSelected];
    [self.quitOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.quitOut setTitle:@"退出当前账号" forState:UIControlStateNormal];
    [self.view addSubview:self.quitOut];
    
    if (app.logStatus) {
        titleArray = @[@"消息提醒",@"修改密码",@"清理缓存"];
    }else{
        titleArray = @[@"消息提醒",@"清理缓存"];
    }
    
    float tempSize = 0 ;
    if (cacheSize>1024*1024) {
        tempSize = cacheSize/1024/1024;
        self.cacheBulk = [NSString stringWithFormat:@"%.fMB",tempSize];
    }else
    {
        tempSize = cacheSize/1024;
        self.cacheBulk = [NSString stringWithFormat:@"%.fKB",tempSize];
    }
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



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (app.logStatus) {
        self.quitOut.hidden = NO;
        [self.tableView setFrame:CGRectMake(0, 0, APP_W, kTableRowHeight * 3)];
    }else{
        self.quitOut.hidden = YES;
        [self.tableView setFrame:CGRectMake(0, 0, APP_W, kTableRowHeight * 2)];
    }
}

//退出当前账号
- (void)quitOutClick
{
//    [MobClick event:@"as-tcdqzh"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:APP_LOGIN_STATUS];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:APP_PASSWORD_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [app clearAccountInformation];
    self.quitOut.hidden = YES;
    titleArray = @[@"消息提醒",@"清理缓存"];
    [self.tableView reloadData];
    /**
     *  防止以后UI会变，先留着，别删. add by perry
     
     UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"不了" otherButtonTitles:@"好的", nil];
     
     NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"CustomLogoutAlertView" owner:self options:nil];
     CustomLogoutAlertView *viewLogout = [nibViews objectAtIndex:0];
     if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
     [alertV setValue:viewLogout forKey:@"accessoryView"];
     }else{
     [alertV addSubview:viewLogout];
     }
     alertV.tag = 998;
     [alertV show];
     */
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (app.logStatus) {
        count = 3;
    }else{
        count = 2;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = titleArray[indexPath.row];
    if (app.logStatus) {
        if (indexPath.row == 2) {
            [self makeRightAccessoryViewWithCell:cell];
        }else{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }else{
        if (indexPath.row == 1) {
            [self makeRightAccessoryViewWithCell:cell];
        }else{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

//定义cell右侧AccessoryView,显示缓存大小
- (void)makeRightAccessoryViewWithCell:(UITableViewCell *)cell{
    CGSize feelSize = [self.cacheBulk sizeWithFont:[UIFont systemFontOfSize:F_DESC]];
    //    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, feelSize.width, feelSize.height)];
    //    label.textColor = UIColorFromRGB(0x999999);
    //    label.textAlignment = NSTextAlignmentLeft;
    //    label.text = self.cacheBulk;
    //    label.font = [UIFont systemFontOfSize:F_DESC];
    //    cell.accessoryView = label;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(APP_W - 105.0f, 15.0f, 90.0f, feelSize.height)];
    label.textColor = UIColorFromRGB(0x999999);
    label.textAlignment = NSTextAlignmentRight;
    if ([self.cacheBulk isEqualToString:@"Zero KB"]) {
        self.cacheBulk = @"0KB";
    }
    label.text = self.cacheBulk;
    label.font = [UIFont systemFontOfSize:F_DESC];
    [cell.contentView addSubview:label];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (app.logStatus) {
        if (indexPath.row == 0) {
//            [MobClick event:@"as-xxtx"];
            MessageSettingViewController *setting = [[MessageSettingViewController alloc] init];
            [self.navigationController pushViewController:setting animated:YES];
        }else if (indexPath.row == 1){
//            [MobClick event:@"as-xgmm"];
            ChangePasswdViewController *changePasswd = [[ChangePasswdViewController alloc] initWithNibName:@"ChangePasswdViewController" bundle:nil];
            [self.navigationController pushViewController:changePasswd animated:YES];
        }else if (indexPath.row){
//            [MobClick event:@"as-qlhc"];
            [self clearMemoryWithIndexPath:indexPath];
        }
    }else{
        if (indexPath.row == 0) {
//            [MobClick event:@"as-xxtx"];
            MessageSettingViewController *setting = [[MessageSettingViewController alloc] init];
            [self.navigationController pushViewController:setting animated:YES];
        }else if (indexPath.row){
            [self clearMemoryWithIndexPath:indexPath];
        }
    }
    
}

#pragma mark    ------ 清理缓存 ------

- (void)clearMemoryWithIndexPath:(NSIndexPath *)indexPath{
    if (([self.cacheBulk isEqualToString:@"0kb"])||([self.cacheBulk isEqualToString:@"0KB"])) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"已经没有缓存啦!"];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //        NSString * cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        //        NSArray * files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
        //        for (NSString * p in files) {
        //            NSError * error;
        //            NSString * path = [cachPath stringByAppendingPathComponent:p];
        //            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        //                [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        //            }
        //        }
        
        [[SDImageCache sharedImageCache] clearDisk];
        [[SDImageCache sharedImageCache] clearMemory];
        
        [self performSelectorOnMainThread:@selector(clearCachesSuccess:) withObject:indexPath waitUntilDone:YES];
    });
}

- (void)clearCachesSuccess:(NSIndexPath *)indexPath{
    [SVProgressHUD dismiss];
    [SVProgressHUD showSuccessWithStatus:@"缓存清理完成"];
    self.cacheBulk = @"0KB";
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}

- (NSString *)folderSizeAtPath:(NSString *)folderPath{
    NSFileManager * manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator * childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString * fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil) {
        NSString * fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    NSLog(@"folder path is %@,folder is %lld", folderPath,folderSize);
    return [NSByteCountFormatter stringFromByteCount:folderSize countStyle:NSByteCountFormatterCountStyleDecimal];
}



- (long long)fileSizeAtPath:(NSString *)folderPath{
    NSFileManager * manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:folderPath]) {
        return [[manager attributesOfItemAtPath:folderPath error:nil] fileSize];
    }
    return 0;
}

@end
