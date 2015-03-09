//
//  QZMyCenterViewController.m
//  wenyao
//
//  Created by Meng on 15/1/15.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "QZMyCenterViewController.h"
#import "MessageSettingViewController.h"
#import "AppDelegate.h"
#import "Constant.h"
#import "ZhPMethod.h"
#import "LoginViewController.h"
#import "QZStoreCollectViewController.h"
#import "QZMyOrderViewController.h"
#import "SVProgressHUD.h"
#import "AboutWenYaoViewController.h"
#import "MycollectViewController.h"
#import "MyPharmacyViewController.h"
#import "PersonInformationViewController.h"
#import "UIImageView+WebCache.h"
#import "QZSettingViewController.h"
#import "UserCenterViewCell.h"
#import "CommendPersonViewController.h"
#import "CommendSuccessViewController.h"
#import "HTTPRequestManager.h"

@interface QZMyCenterViewController ()<UITableViewDataSource,UITableViewDelegate,BeforeAndAfterLoginViewDelegate>
{
    NSString *storeCount;
    NSArray *titleArr;
    NSArray *imageArr;
}
@property (nonatomic ,strong) UITableView *tableView;


@property (nonatomic ,strong) UIButton *consultButton;
@property (nonatomic ,strong) UIButton *attentedButton;

@property (nonatomic ,strong) BeforeLoginView *beforeLoginView;
@property (nonatomic ,strong) AfterLoginView *afterLoginView;

@property (nonatomic, strong) UIImageView *imageBudgeView;

@end

@implementation QZMyCenterViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"我的";
        storeCount = @"0";
        self.view.backgroundColor = UICOLOR(242, 242, 242);
        self.tableView.backgroundColor = [UIColor clearColor];
        if (iOSv7 && self.view.frame.origin.y==0) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = NO;
        }
        
        
        titleArr = @[@[@"我关注的药房",@"我的优惠订单"],@[@"我的收藏",@"我的用药"],@[@"关于问药",@"我的推荐人"]];
        imageArr = @[@[@"我关注的药房.png",@"我的优惠订单.png"],@[@"我的收藏.png",@"我_我的用药.png"],@[@"关于问药.png",@"推荐人.PNG"]];
        
        UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"设置.png"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClick)];
        
        self.navigationItem.rightBarButtonItem = rightBarButton;
        
        
        
        self.beforeLoginView = [[BeforeLoginView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 80)];
        self.beforeLoginView.delegate = self;
        
        
        self.afterLoginView = [[AfterLoginView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 80)];
        self.afterLoginView.delegate = self;
        
//        self.tableView =[[UITableView alloc] initWithFrame:CGRectMake(0, 0 , APP_W, 360+50) style:UITableViewStylePlain];
        self.tableView =[[UITableView alloc] initWithFrame:CGRectMake(0, 0 , APP_W, self.view.frame.size.height-64-44) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.scrollEnabled = YES;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:self.tableView];
        
        
        
        
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return titleArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSArray *arr = titleArr[section];
    
    return arr.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 10)];
    bgView.backgroundColor = UICOLOR(242, 242, 242);
//    UILabel *topLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, APP_W, 0.5)];
//    topLine.backgroundColor = [UIColor grayColor];
//    topLine.alpha = 0.5;
//    [bgView addSubview:topLine];
//    

    

    UILabel *bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 9.5, APP_W, 0.5)];
    bottomLine.backgroundColor = UICOLOR(209, 209, 209);
    bottomLine.alpha = 0.5;
    [bgView addSubview:bottomLine];
    
    return bgView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    UserCenterViewCell *cell = (UserCenterViewCell *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"UserCenterViewCell" owner:self options:nil][0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.titleLabel.font = Font(15);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSString *str = titleArr[indexPath.section][indexPath.row];
    NSString *imageName = imageArr[indexPath.section][indexPath.row];
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (![storeCount isEqualToString:@"0"]) {
//            str = [NSString stringWithFormat:@"%@(%@)",str,storeCount];
            cell.countLabel.text = [NSString stringWithFormat:@"(%@)",storeCount];
        }
    }
    
    if (indexPath.section == 2 && indexPath.row == 0) {
        self.imageBudgeView = [[UIImageView alloc] initWithFrame:CGRectMake(112, 21, 8, 8)];
        self.imageBudgeView.layer.cornerRadius = 4.0f;
        self.imageBudgeView.layer.masksToBounds = YES;
        self.imageBudgeView.backgroundColor = [UIColor redColor];
        [cell.contentView addSubview:self.imageBudgeView];
        self.imageBudgeView.hidden = YES;
        
        NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"BeRead"];
        if ([str isEqualToString:@"1"]) {
            self.imageBudgeView.hidden = YES;
        }else
        {
            self.imageBudgeView.hidden = NO;
        }
    }
    
    cell.titleLabel.text = str;
    cell.titleImageView.image = [UIImage imageNamed:imageName];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, cell.frame.size.height-0.5, cell.frame.size.width, 0.5)];
    line.backgroundColor = UICOLOR(209, 209, 209);
    [cell.contentView addSubview:line];
    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestPersonInfo) name:LOGIN_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestPersonInfo) name:NETWORK_RESTART object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.afterLoginView.headImageView.image = [UIImage imageNamed:@"我_个人默认头像.png"];
    storeCount = @"0";
    
    [self requestPersonInfo];
    
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"BeRead"];
    if ([str isEqualToString:@"1"]) {
        app.myCenterBudge.hidden = YES;
    }else
    {
        app.myCenterBudge.hidden = NO;
    }
    
    [self.tableView reloadData];
}

- (void)requestPersonInfo
{
    if (app.logStatus) {//已登录
        self.tableView.tableHeaderView = self.afterLoginView;
//        [MobClick event:@"wode"];
        if(app.currentNetWork != kNotReachable) {
            [[HTTPRequestManager sharedInstance] queryMemberDetail:@{@"token":app.configureList[APP_USER_TOKEN]} completionSuc:^(id resultObj) {
                if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                    [app.configureList addEntriesFromDictionary:resultObj[@"body"]];
                    [app saveAppConfigure];
                    NSString *mobile = [NSString stringWithFormat:@"%@",resultObj[@"body"][@"mobile"]];
                    NSString *nickName = [NSString stringWithFormat:@"%@",resultObj[@"body"][@"nickName"]];
                    NSString *imageUrl = [NSString stringWithFormat:@"%@",resultObj[@"body"][@"headImageUrl"]];
                    NSString *name = nil;
                    if (nickName.length != 0)
                    {
                        app.configureList[APP_NICKNAME_KEY] = nickName;
                        name = nickName;
                    }else{
                        if (mobile.length != 0) {
                            app.configureList[APP_NICKNAME_KEY] = mobile;
                            name = mobile;
                        }
                    }
                    self.afterLoginView.nameLabel.text = name;
                    if (imageUrl.length > 0) {
                        [self.afterLoginView.headImageView setImageWithURL:[NSURL URLWithString:imageUrl]];
                        
                        [[SDImageCache sharedImageCache] storeImage:self.afterLoginView.headImageView.image forKey:app.configureList[@"headImageUrl"] toDisk:YES];
                     
                        
                    }
                    
                    [self requestStoreCollectList];
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
//                [afterTitle replaceObjectAtIndex:0 withObject:app.configureList[APP_NICKNAME_KEY]];
//                [self.afterLoginTableView reloadData];
                NSString *imgPath = app.configureList[@"headImageUrl"];
                
                if (imgPath.length > 0){
                    UIImage *img = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imgPath];
                  [self.afterLoginView.headImageView setImage:img];
                }
                
                
                
            }
            
        }
    }else{
        self.tableView.tableHeaderView = self.beforeLoginView;
        [self.tableView reloadData];
    }
}

- (void)requestStoreCollectList
{
    
    [[HTTPRequestManager sharedInstance] queryStoreCollectList:@{@"token":app.configureList[APP_USER_TOKEN],@"currPage":@1,@"pageSize":@1} completionSuc:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            NSString *str = [NSString stringWithFormat:@"%@",resultObj[@"body"][@"totalRecords"]];
            if (str.length > 0 && ![str isEqualToString:@"(null)"]) {
                storeCount = [NSString stringWithFormat:@"%@",resultObj[@"body"][@"totalRecords"]];
            }
            
            [self.tableView reloadData];
        }
    } failure:^(id failMsg) {
        
    }];
}
//登陆跳转
- (void)loginButtonClick
{
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    loginViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:loginViewController animated:YES];
}
//设置跳转
- (void)rightBarButtonClick
{
//    [MobClick event:@"a-shezhi"];
    QZSettingViewController *setting =[[QZSettingViewController alloc] init];
    setting.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:setting animated:YES];
}

- (void)personHeadImageClick
{
//    [MobClick event:@"a-grzl"];
    PersonInformationViewController *personInfoViewController =[[PersonInformationViewController alloc] init];
    personInfoViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:personInfoViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    switch (section) {
        case 0:
        {
            switch (row) {
                case 0://我关注的药房
                {
                    if (app.logStatus) {
//                        [MobClick event:@"a-wgzdyf"];
                        QZStoreCollectViewController *myLikeViewController = [[QZStoreCollectViewController alloc] init];
                        myLikeViewController.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:myLikeViewController animated:YES];
                    }else{
                        [self loginButtonClick];
                    }
                }
                    break;
                case 1://我的优惠订单
                {
                    if (app.logStatus) {
//                        [MobClick event:@"a-wdyhdd"];
                        QZMyOrderViewController *myOrderViewController = [[QZMyOrderViewController alloc] init];
                        myOrderViewController.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:myOrderViewController animated:YES];
                    }else{
                        [self loginButtonClick];
                    }
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            switch (row) {
                case 0://我的收藏
                {
                    if (app.logStatus) {
//                        [MobClick event:@"a-wdsc"];
                        MycollectViewController *myConllectViewController = [[MycollectViewController alloc] init];
                        myConllectViewController.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:myConllectViewController animated:YES];
                    }else{
                        [self loginButtonClick];
                    }
                }
                    break;
                case 1://我的问药
                {
                    if (app.logStatus) {
//                        [MobClick event:@"a-wdyy"];
                        MyPharmacyViewController *myPharmacyViewController = [[MyPharmacyViewController alloc] init];
                        myPharmacyViewController.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:myPharmacyViewController animated:YES];
                    }else{
                        [self loginButtonClick];
                    }
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            switch (row) {
                case 0://关于问药
                {
//                    [MobClick event:@"a-gywy"];
                    AboutWenYaoViewController *aboutWenyaoViewController = [[AboutWenYaoViewController alloc] init];
                    aboutWenyaoViewController.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:aboutWenyaoViewController animated:YES];
                }
                    break;
                case 1://我的推荐人
                {
                    
                    if (app.currentNetWork == kNotReachable) {
                        [SVProgressHUD showErrorWithStatus:@"网络异常，请重试" duration:0.8];
                        return;
                    }else
                    {
                        
                        if (app.logStatus) {
                            
                            NSMutableDictionary *setting = [NSMutableDictionary dictionary];
                            setting[@"token"] = app.configureList[APP_USER_TOKEN];
                            [[HTTPRequestManager sharedInstance] QueryCommendPersonPhoneNumber:setting completion:^(id resultObj) {
                                
                                if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                                    if (![resultObj[@"body"] isEqualToString:@""]) {
                                        
                                        CommendSuccessViewController *successVC = [[UIStoryboard storyboardWithName:@"CommendPerson" bundle:nil] instantiateViewControllerWithIdentifier:@"CommendSuccessViewController"];
                                        successVC.phoneStr = resultObj[@"body"];
                                        successVC.hidesBottomBarWhenPushed = YES;
                                        [self.navigationController pushViewController:successVC animated:YES];
                                        
                                    }else
                                    {
                                        CommendPersonViewController *commenVC = [[UIStoryboard storyboardWithName:@"CommendPerson" bundle:nil] instantiateViewControllerWithIdentifier:@"CommendPersonViewController"];
                                        commenVC.hidesBottomBarWhenPushed = YES;
                                        [self.navigationController pushViewController:commenVC animated:YES];
                                    }
                                }
                                
                            } failure:^(NSError *error) {
                                
                            }];
                            
                        }else{
                            [self loginButtonClick];
                        }
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end


@implementation BeforeLoginView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //登录前
        self.frame = frame;
        
        UIButton * loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        loginButton.backgroundColor = [UIColor clearColor];
        loginButton.frame = CGRectMake((APP_W-100)/2, 20, 100, 40);
        loginButton.layer.masksToBounds = YES;
        [loginButton.layer setBorderColor:GREENTCOLOR.CGColor];
        [loginButton.layer setBorderWidth:1];
        loginButton.layer.cornerRadius = 5.0f;
        [loginButton setTitleColor:GREENTCOLOR forState:UIControlStateNormal];
        [loginButton setTitle:@"注册/登录" forState:UIControlStateNormal];
        [loginButton addTarget:self action:@selector(loginButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:loginButton];
        
        UILabel *topLine = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 0.5, APP_W, 0.5)];
        topLine.backgroundColor = [UIColor grayColor];
        topLine.alpha = 0.5;
        [self addSubview:topLine];
        
    }
    return self;
}

- (void)loginButtonClick
{
    if ([self.delegate respondsToSelector:@selector(loginButtonClick)]) {
        [self.delegate loginButtonClick];
    }
}

@end


@implementation AfterLoginView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        //登录后
        
        self.frame = frame;
        
        UIImage *headImage = [UIImage imageNamed:@"我_个人默认头像.png"];
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImageClick)];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] init];
        [tap2 addTarget:self action:@selector(headImageClick)];
        self.headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 50, 50)];
        self.headImageView.image = [UIImage imageNamed:@"我_个人默认头像.png"];
        self.headImageView.userInteractionEnabled = YES;
        [self.headImageView convertIntoCircular];
        [self.headImageView addGestureRecognizer:tap2];
        self.headImageView.image = headImage;
        [self addSubview:self.headImageView];
        
        
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, (80-15)/2, APP_W-90, 15)];
        self.nameLabel.userInteractionEnabled = YES;
        [self.nameLabel addGestureRecognizer:tap1];
        self.nameLabel.font = Font(16);
        [self addSubview:self.nameLabel];
        
        UIImage *imageArr = [UIImage imageNamed:@"向右箭头.png"];
        UIImageView *imageArrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.nameLabel.frame.origin.x + self.nameLabel.frame.size.width-2, (80-imageArr.size.height)/2, imageArr.size.width, imageArr.size.height)];
        imageArrow.image = imageArr;
        [self addSubview:imageArrow];
        
        [self addGestureRecognizer:tap1];
        
        UILabel *topLine = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 0.5, APP_W, 0.5)];
        topLine.backgroundColor = [UIColor grayColor];
        topLine.alpha = 0.5;
        [self addSubview:topLine];

        
    }
    return self;
}

- (void)headImageClick
{
    if ([self.delegate respondsToSelector:@selector(personHeadImageClick)]) {
        [self.delegate personHeadImageClick];
    }
}

@end
