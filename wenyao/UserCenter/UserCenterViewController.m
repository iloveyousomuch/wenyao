//
//  LoginViewController.m
//  WenYao
//
//  Created by Meng on 14-9-2.
//  Copyright (c) 2014年 江苏苏州. All rights reserved.
//

#import "UserCenterViewController.h"
#import "Constant.h"
#import "LoginViewController.h"
#import "ChangePasswdViewController.h"
#import "MycollectViewController.h"
#import "MessageSettingViewController.h"
#import "AboutWenYaoViewController.h"
#import "SVProgressHUD.h"
#import "PersonInformationViewController.h"
#import "AppDelegate.h"
#import "JGProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "BoutiqueApplicationViewController.h"
#import "SDImageCache.h"
#import "CustomLogoutAlertView.h"


#define ISLOGIN 1
#define F_TITLE  14
#define F_DESC   12
@interface UserCenterViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSMutableArray * beforeTitle;
    NSMutableArray * afterTitle;
    
    NSMutableArray * beforeImage;
    NSMutableArray * afterImage;
    
    
    UIImageView * headImage;
    UILabel * useTitle;
    UIImageView * rightImageView;
}
@property (nonatomic ,copy) NSString * cacheBulk;
@property (nonatomic ,strong) UITableView * beforeLoginTableView;
@property (nonatomic ,strong) UITableView * afterLoginTableView;

@property (nonatomic ,strong) UIView * beforeLoginView;
@property (nonatomic ,strong) UIView * afterLoginView;
@property (nonatomic ,strong) NSMutableDictionary * dataDict;

@end

@implementation UserCenterViewController

- (id)init{
    if (self = [super init]) {
        
        
        self.dataDict = [NSMutableDictionary dictionary];
        
        //登录前
        self.beforeLoginView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.beforeLoginTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 203) style:UITableViewStylePlain];
        self.beforeLoginTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.beforeLoginTableView.scrollEnabled = NO;
        self.beforeLoginTableView.delegate = self;
        self.beforeLoginTableView.dataSource = self;
        UIView * headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 71)];
        headView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"我_登录注册背景.png"]];
        UIButton * loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        loginButton.backgroundColor = [UIColor orangeColor];
        loginButton.frame = CGRectMake(120, 16, 80, 35);
        loginButton.layer.masksToBounds = YES;
        //[loginButton.layer setBorderColor:[UIColor blueColor].CGColor];
        loginButton.layer.cornerRadius = 3.0f;
        [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [loginButton setTitle:@"注册/登录" forState:UIControlStateNormal];
        [loginButton addTarget:self action:@selector(loginButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [headView addSubview:loginButton];
        self.beforeLoginTableView.tableHeaderView = headView;
        [self.beforeLoginView addSubview:self.beforeLoginTableView];
        self.beforeLoginView.hidden = NO;
        
        [self.view addSubview:self.beforeLoginView];
        //登录后
        self.afterLoginView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.afterLoginTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 299) style:UITableViewStylePlain];
        self.afterLoginTableView.scrollEnabled = NO;
        self.afterLoginTableView.delegate = self;
        self.afterLoginTableView.dataSource = self;
        self.afterLoginTableView.backgroundColor = [UIColor clearColor];
        self.afterLoginTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UIButton * quitOut = [UIButton buttonWithType:UIButtonTypeCustom];
        [quitOut setFrame:CGRectMake(10, self.afterLoginTableView.frame.origin.y+self.afterLoginTableView.frame.size.height+20, 300, 40)];
        [quitOut addTarget:self action:@selector(quitOutClick) forControlEvents:UIControlEventTouchUpInside];
        [quitOut setBackgroundImage:[UIImage imageNamed:@"btnLogoutBack"] forState:UIControlStateNormal];
        [quitOut setBackgroundImage:[UIImage imageNamed:@"btnLogoutPressed"] forState:UIControlStateHighlighted];
        [quitOut setBackgroundImage:[UIImage imageNamed:@"btnLogoutPressed"] forState:UIControlStateSelected];
        [quitOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [quitOut setTitle:@"退出当前账号" forState:UIControlStateNormal];
        [self.afterLoginView addSubview:quitOut];
        [self.afterLoginView addSubview:self.afterLoginTableView];
        self.afterLoginView.hidden = YES;
        [self.view addSubview:self.afterLoginView];
        headImage  = [[UIImageView alloc]init];
        useTitle = [[UILabel alloc] init];
        rightImageView = [[UIImageView alloc] init];
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)login
{
    [self.navigationController setNavigationBarHidden:NO];
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
    lblTitle.font = [UIFont systemFontOfSize:18.0f];
    lblTitle.text = @"我的";
    lblTitle.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = lblTitle;
    if (app.logStatus) {//已登录
        self.afterLoginView.hidden = NO;
        self.beforeLoginView.hidden = YES;
        if(app.currentNetWork != kNotReachable) {
            [[HTTPRequestManager sharedInstance] queryMemberDetail:@{@"token":app.configureList[APP_USER_TOKEN]} completionSuc:^(id resultObj) {
                if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                    [self.dataDict addEntriesFromDictionary:resultObj[@"body"]];
                    app.configureList[APP_AVATAR_KEY] = self.dataDict[@"headImageUrl"];
                    NSString * mobile = [NSString stringWithFormat:@"%@",resultObj[@"body"][@"mobile"]];
                    NSString * nickName = [NSString stringWithFormat:@"%@",resultObj[@"body"][@"nickName"]];
                    
                    if (nickName.length != 0)
                    {
                        [afterTitle replaceObjectAtIndex:0 withObject:nickName];
                        app.configureList[APP_NICKNAME_KEY] = nickName;
                    }else{
                        if (mobile.length != 0) {
                            [afterTitle replaceObjectAtIndex:0 withObject:mobile];
                            app.configureList[APP_NICKNAME_KEY] = mobile;
                        }
                    }
                    [self.afterLoginTableView reloadData];
                }else if ([resultObj[@"result"] isEqualToString:@"FAIL"]){
                    if ([resultObj[@"msg"] isEqualToString:@"1"]) {
                        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:ALERT_MESSAGE delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        alertView.tag = 999;
                        alertView.delegate = self;
                        [alertView show];
                        return;
                    }else{
                        [SVProgressHUD showErrorWithStatus:resultObj[@"msg"] duration:DURATION_SHORT];
                    }
                }
                //NSLog(@"afterTitle = %@",afterTitle);
            } failure:^(id failMsg) {
                NSLog(@"%@",failMsg);
            }];
        }else{
            if(app.configureList[APP_NICKNAME_KEY])
            {
                [afterTitle replaceObjectAtIndex:0 withObject:app.configureList[APP_NICKNAME_KEY]];
                [self.afterLoginTableView reloadData];
            }
            
        }
    }else{//未登录
        self.afterLoginView.hidden = YES;
        self.beforeLoginView.hidden = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucessCall:) name:LOGIN_SUCCESS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserIconSuccesss) name:@"UpdateUserIconSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateUserNickNameSuccess) name:@"UpdateUserNickNameSuccess" object:nil];

    self.title = @"我";
    
    
    self.view.backgroundColor = BG_COLOR;
    if (iOSv7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    beforeTitle = [NSMutableArray arrayWithObjects:@"清理缓存",@"设置",@"关于问药", nil];
    beforeImage = [NSMutableArray arrayWithObjects:@"清理缓存.png",@"设置.png",@"关于问药.png",nil];
    afterTitle = [NSMutableArray arrayWithObjects:@"     ",@"我的收藏",@"修改密码",@"清理缓存",@"设置",@"关于问药", nil];
    afterImage = [NSMutableArray arrayWithObjects:@"我_登录后头像.png",@"我的收藏.png",@"修改密码.png",@"清理缓存.png",@"设置.png",@"关于问药.png", nil];
    
    
    
    
    long long cacheSize = [SDImageCache sharedImageCache].getSize;
    
    float tempSize = 0 ;
    if (cacheSize>1024*1024) {
        tempSize = cacheSize/1024/1024;
        self.cacheBulk = [NSString stringWithFormat:@"%.fMB",tempSize];
    }else
    {
        tempSize = cacheSize/1024;
        self.cacheBulk = [NSString stringWithFormat:@"%.fKB",tempSize];
    }
    
//    NSString * cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
//    self.cacheBulk = [NSString stringWithFormat:@"%@",[self folderSizeAtPath:cachePath]];
    
    UIView *viewBoutique = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60.0f, 30.0f)];
    viewBoutique.backgroundColor = [UIColor clearColor];
    
    UILabel *lblBoutique = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60.0f, 30.0f)];
    lblBoutique.textColor = [UIColor whiteColor];
    lblBoutique.font = [UIFont systemFontOfSize:15.0f];
    lblBoutique.text = @"精品应用";
    
    UIButton *btnBoutique = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBoutique.frame = lblBoutique.frame;
    [btnBoutique addTarget:self action:@selector(boutiqueBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [viewBoutique addSubview:lblBoutique];
    [viewBoutique addSubview:btnBoutique];
    
    UIBarButtonItem *btnItemBoutique = [[UIBarButtonItem alloc] initWithCustomView:viewBoutique];//[[UIBarButtonItem alloc] initWithTitle:@"精品应用" style:UIBarButtonItemStylePlain target:self action:@selector(boutiqueBtnClick)];
    
    
    //self.navigationItem.rightBarButtonItem = btnItemBoutique;
    
}

- (void)updateUserIconSuccesss
{
    [self.afterLoginTableView reloadData];
}

- (void)UpdateUserNickNameSuccess
{
    [self login];
    [self.afterLoginTableView reloadData];
}

- (void)loginSucessCall:(NSNotification *)noti
{
    [self login];
}

- (void)boutiqueBtnClick
{
    BoutiqueApplicationViewController *viewControllerBoutique = [[BoutiqueApplicationViewController alloc] initWithNibName:@"BoutiqueApplicationViewController" bundle:nil];
    viewControllerBoutique.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewControllerBoutique animated:YES];
}

#pragma mark ------ 设置登陆前后UI界面 ------

- (void)loginButtonClick{
    LoginViewController * loginViewController =[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    loginViewController.hidesBottomBarWhenPushed = YES;
    loginViewController.isPresentType = NO;
    [self.navigationController pushViewController:loginViewController animated:YES];
}

- (void)quitOutClick
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:APP_LOGIN_STATUS];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:APP_PASSWORD_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [app clearAccountInformation];
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

#pragma mark ------ tableViewDelegate ------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.beforeLoginTableView) {
        return 44;
    }else if (tableView == self.afterLoginTableView){
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                return 71;
            }
        }
    }
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.afterLoginTableView) {
        if (section == 1) {
            UIView *viewPlaceHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 8.0f)];
            viewPlaceHolder.backgroundColor = [UIColor clearColor];
            return viewPlaceHolder;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.afterLoginTableView) {
        if (section == 1) {
            return 8.0f;
        }
    }
    return 0.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.beforeLoginTableView) {
        return beforeTitle.count;
    }else if (tableView == self.afterLoginTableView){
        if (section == 0) {
            return 3;
        } else {
            return 3;
        }
//        return afterTitle.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.beforeLoginTableView) {
        return 1;
    } else if (tableView == self.afterLoginTableView) {
        return 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * cellIdenfitifer = @"cellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdenfitifer];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdenfitifer];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:F_TITLE];
    } else {
//        cell.textLabel.text = @"";
//        cell.imageView.image = nil;
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        for (UIView *subView in cell.contentView.subviews) {
//            [subView removeFromSuperview];
//        }
    }
    if (tableView == self.beforeLoginTableView) {
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIImage * image = [UIImage imageNamed:afterImage[indexPath.row]];
        if (!app.logStatus) {
            if (indexPath.row == 0) {
                [self makeRightAccessoryViewWithCell:cell];
            }
            if(indexPath.row != 0){
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            cell.textLabel.text = beforeTitle[indexPath.row];
            cell.imageView.image = [UIImage imageNamed:beforeImage[indexPath.row]];
            
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, cell.frame.size.height - 0.5, APP_W, 0.5)];
            line.backgroundColor = UIColorFromRGB(0xdbdbdb);
            [cell addSubview:line];
            
        }
    }else if (tableView == self.afterLoginTableView){
        if (app.logStatus) {
            if (indexPath.section == 0) {
                UIImage * image = [UIImage imageNamed:afterImage[indexPath.row]];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                if (indexPath.row == 0) {
                    
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"我_登录注册背景.png"]];
                    
                    [headImage setFrame:CGRectMake(10, 10, image.size.width, image.size.height)];
                    headImage.layer.masksToBounds = YES;
                    headImage.layer.cornerRadius = 8;
                    headImage.image = [UIImage imageNamed:afterImage[0]];
                    
                    NSString * headImageUrl = [NSString stringWithFormat:@"%@",app.configureList[APP_AVATAR_KEY]];
                    if (headImageUrl.length > 0) {
                        NSLog(@"图片网址 = %@",headImageUrl);
                        UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:app.configureList[APP_AVATAR_KEY]];
                        if(image) {
                            headImage.image = image;
                        }else{
                            [headImage setImageWithURL:[NSURL URLWithString:app.configureList[APP_AVATAR_KEY]]];
                        }
                    }
                    
                    [cell.contentView addSubview:headImage];
                    
                    UIImage * rightImage = [UIImage imageNamed:@"向右箭头.png"];
                    //cell.frame.size.height/2-rightImage.size.height/2
                    [rightImageView setFrame:CGRectMake(APP_W-25, 28, rightImage.size.width+1, rightImage.size.height+1)];
                    rightImageView.image = rightImage;
                    [cell.contentView addSubview:rightImageView];
                    
                    CGSize feelSize = [afterTitle[indexPath.row] sizeWithFont:[UIFont systemFontOfSize:F_TITLE]];
                    [useTitle setFrame:CGRectMake(80, (70-feelSize.height)/2, 190, feelSize.height)];
                    useTitle.text = afterTitle[indexPath.row];
                    useTitle.font = [UIFont systemFontOfSize:F_TITLE];
                    [cell.contentView addSubview:useTitle];
                    
                }else{
                    cell.textLabel.text = afterTitle[indexPath.row];
                    cell.imageView.image = image;
                    
                    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, cell.frame.size.height - 0.5, APP_W, 0.5)];
                    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
                    [cell addSubview:line];
                    
                }
            } else if (indexPath.section == 1) {
                UIImage * image = [UIImage imageNamed:afterImage[indexPath.row+3]];
                if (indexPath.row == 0) {
                    [self makeRightAccessoryViewWithCell:cell];
                }
                if(indexPath.row != 0){
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                cell.textLabel.text = afterTitle[indexPath.row+3];

                cell.imageView.image = image;
                
                
                UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, cell.frame.size.height - 0.5, APP_W, 0.5)];
                line.backgroundColor = UIColorFromRGB(0xdbdbdb);
                [cell addSubview:line];
            }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.afterLoginTableView) {//已登录
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {//个人信息
                PersonInformationViewController * personInformation = [[PersonInformationViewController alloc] init];
                personInformation.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:personInformation animated:YES];
                
            }else if (indexPath.row == 1) {//我的收藏
                MycollectViewController * myCollectViewController = [[MycollectViewController alloc] init];
                myCollectViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:myCollectViewController animated:YES];
            }else if (indexPath.row == 2) {//修改密码
                ChangePasswdViewController * forgetPassword = [[ChangePasswdViewController alloc]initWithNibName:@"ForgetPasswordViewController" bundle:nil];
                forgetPassword.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:forgetPassword animated:YES];
            }
        } else {
            if (indexPath.row == 0){//清理缓存
                [SVProgressHUD showWithStatus:@"缓存清理中..."];
                [self clearMemoryWithIndexPath:indexPath];
            }else if (indexPath.row == 1){//设置
                MessageSettingViewController * settingViewController = [[MessageSettingViewController alloc]init];
                settingViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:settingViewController animated:YES];
            }else if (indexPath.row == 2){//关于问药
                AboutWenYaoViewController * aboutWenYao = [[AboutWenYaoViewController alloc]init];
                aboutWenYao.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:aboutWenYao animated:YES];
            }
        }
    }else if (tableView == self.beforeLoginTableView){//未登录
        if (indexPath.row == 0) {//清理缓存
            [SVProgressHUD showWithStatus:@"缓存清理中..."];
            [self clearMemoryWithIndexPath:indexPath];
        }else if (indexPath.row == 1){//设置
            MessageSettingViewController * settingViewController = [[MessageSettingViewController alloc]init];
            settingViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:settingViewController animated:YES];
        }else if (indexPath.row == 2){//关于问药
            AboutWenYaoViewController * aboutWenYao = [[AboutWenYaoViewController alloc]init];
            aboutWenYao.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:aboutWenYao animated:YES];
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
    if (app.logStatus) {
        [self.afterLoginTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        
        [self.beforeLoginTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 999) {
        if (buttonIndex == 0) {
            LoginViewController * login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            login.isPresentType = YES;
            login.parentNavgationController = self.navigationController;
            UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:login];
            [self presentViewController:nav animated:YES completion:nil];
        }
    } else if (alertView.tag == 998) {
        if (buttonIndex == 0) {
            // 退出
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:APP_LOGIN_STATUS];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:APP_PASSWORD_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [app clearAccountInformation];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end