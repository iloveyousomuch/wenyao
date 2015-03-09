//
//  MedicineDetailViewController.m
//  quanzhi
//
//  Created by xiezhenghong on 14-6-11.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "MedicineDetailViewController.h"
#import "HTTPRequestManager.h"
//#import "FactoryDetail.h"
#import "SVProgressHUD.h"
//#import "MedicineMarkViewController.h"
#import "Appdelegate.h"
#import "ZhPMethod.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "MedicineDetailCellView.h"
#import "KnowLedgeViewController.h"
#import "LogInViewController.h"


@interface MedicineDetailViewController ()
{
    BOOL        isFirstAppear;
    BOOL        hasDrugKnowLedge;
    BOOL        hasMarkLabel;
    MedicineDetailCellView *medicineDetailCellView;
    NSUInteger      selectedDrugBoxList;
    NSUInteger      countOfContent;
    UIFont          *defaultFont;
    NSUInteger      fontCount;
}

@property (nonatomic, strong) UIImageView               *vipFlag;
@property (nonatomic, strong) NSMutableDictionary       *drugInfo;
@property (nonatomic, strong) NSMutableArray            *baseInfo;
@property (nonatomic, strong) UIFont                    *adjustFont;
@property (nonatomic, strong) NSMutableDictionary       *appraiseInfo;
@property (nonatomic, strong) NSMutableArray            *drugBoxList;
@property (nonatomic, strong) UIBarButtonItem           *collectBarButton;

@end

@implementation MedicineDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"药品详情";
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    self.view.frame = CGRectMake(0, 64, APP_W, APP_H - 64.0f);
    if(self.showRightBarButton && app.logStatus) {
        UIBarButtonItem *adjustFontButton = [[UIBarButtonItem alloc] initWithTitle:@"Aa" style:UIBarButtonItemStylePlain target:self action:@selector(adjustFontAction:)];
        self.collectBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"导航栏_收藏icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(collectAction:)];
        self.navigationItem.rightBarButtonItems = @[self.collectBarButton,adjustFontButton];
        self.collectBarButton.enabled = NO;
        
    }
    [self initData];
}

- (void)adjustFontAction:(id)sender
{
    fontCount++;
    if(fontCount <= 3)
    {
        [self ZoominFont:nil];
    }else{
        fontCount = 0;
        [self resetFont:nil];
    }
}

- (void)collectAction:(id)sender
{
    [self setLike:nil];
}

- (void)initData
{
    isFirstAppear = YES;
    countOfContent = 1;
    self.drugBoxList = [NSMutableArray arrayWithCapacity:15];
    self.drugInfo = [NSMutableDictionary dictionary];
    self.baseInfo = [NSMutableArray arrayWithCapacity:15];
    defaultFont = [UIFont systemFontOfSize:12.0f];
    self.guideView.alpha = 0.0f;
}

- (void)setupTableView
{
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
}

- (void)fillupBaseInfo:(NSDictionary *)baseInfo
{
    NSArray *array = baseInfo[@"body"][@"baseInfo"];
    for(NSDictionary *dict in array)
    {
        NSString *title = dict[@"title"];
        NSString *content = dict[@"content"];
        NSDictionary *subDict = [NSDictionary dictionaryWithObjectsAndKeys:content,title, nil];
        [self.drugInfo addEntriesFromDictionary:subDict];
    }
    [self.drugInfo addEntriesFromDictionary:baseInfo[@"body"][@"headerInfo"]];
    if(baseInfo[@"body"][@"knowledgeContent"]){
        self.drugInfo[@"knowledgeContent"] = baseInfo[@"body"][@"knowledgeContent"];
        self.drugInfo[@"knowledgeTitle"] = baseInfo[@"body"][@"knowledgeTitle"];
    }
    if(self.drugInfo[@"shortName"]) {
        self.drugName.text = self.drugInfo[@"shortName"];
    }else {
        if(self.extendInfo && self.extendInfo[@"name"]){
            self.drugName.text = self.extendInfo[@"name"];
        }
    }
    
    self.drugType.text = @"非处方药";
    self.drugSpec.text = [NSString stringWithFormat:@"规格:  %@",self.drugInfo[@"spec"]];
    if(self.extendInfo && self.extendInfo[@"spec"])
    {
        self.drugSpec.text = [NSString stringWithFormat:@"规格:  %@",self.extendInfo[@"spec"]];
    }
    self.drugFactory.text = self.drugInfo[@"factory"];
    
    NSLog(@"self.drugInfo = %@",self.drugInfo);
    
    
    if ([self.drugInfo[@"factoryAuth"] intValue] == 1) {
        UIView* parnetView = self.drugFactory.superview;
        if ([parnetView viewWithTag:1501] == nil) {
            CGSize txtSize = getTextSize(self.drugFactory.text, self.drugFactory.font, self.drugFactory.frame.size.width);
            self.vipFlag = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"storeFlag.png"]];
            self.vipFlag.frame = RECT(self.drugFactory.frame.origin.x+txtSize.width+5,
                                 self.drugFactory.frame.origin.y+3,
                                 self.vipFlag.frame.size.width, self.vipFlag.frame.size.height);
            [parnetView addSubview:self.vipFlag];
        }
    }
    
    
    if ( self.drugInfo[@"factoryCode"]!=nil ) {
        UIView* parnetView = self.drugFactory.superview;
        if ([parnetView viewWithTag:1502] == nil) {
            UIButton* btn = [[UIButton alloc] initWithFrame:self.drugFactory.frame];
            btn.backgroundColor = [UIColor clearColor];
            [btn addTarget:self action:@selector(onFactoryBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
            [parnetView addSubview:btn];
            self.drugFactory.textColor = UIColorFromRGB(0xff7e4a);
        }
    }
}

- (void)onFactoryBtnTouched:(id)sender
{
//    if(!app.logStatus){
//        LogInViewController *loginViewController = [[LogInViewController alloc] initWithNibName:@"LogInViewController" bundle:nil];
//        loginViewController.isPresentType = YES;
//        loginViewController.parentNavgationController = self.navigationController;
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
//        [self presentViewController:nav animated:YES completion:^{
//        }];
//        return;
//    }
    
//    FactoryDetail* vc = [[FactoryDetail alloc] init];
//    vc.factoryId = self.drugInfo[@"factoryCode"];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)fillupExtInfo:(NSDictionary *)extInfo
{
    [self.drugInfo addEntriesFromDictionary:extInfo[@"body"]];
}

- (IBAction)setLike:(id)sender
{
    if(!app.logStatus) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前尚未登录,需要登录才可收藏该药品,是否现在登录?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登录", nil];
        [alert show];
        return;
    }
    
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    if(self.collectBarButton.tag == 0){
        setting[@"method"] = @"2";
    }else{
        setting[@"method"] = @"3";
    }
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"objId"] = self.drugInfo[@"sid"];
    setting[@"objType"] = [NSNumber numberWithInt:1];
    [[HTTPRequestManager sharedInstance] favoriteCollect:setting completion:^(id resultObj) {
        if([resultObj[@"body"][@"result"] intValue] == 2){
            //收藏成功
            self.collectBarButton.tag = 1;
            [self.collectBarButton setImage:[UIImage imageNamed:@"导航栏_已收藏icon.png"]];
        }else{
            //取消收藏成功
            self.collectBarButton.tag = 0;
            [self.collectBarButton setImage:[UIImage imageNamed:@"导航栏_收藏icon.png"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    if(buttonIndex == 1)
//    {
//        LogInViewController *loginViewController = [[LogInViewController alloc] initWithNibName:@"LogInViewController" bundle:nil];
//        loginViewController.isPresentType = YES;
//        loginViewController.loginSuccessBlock = ^(){
//            [self checkLikeStatus];
//        };
//        loginViewController.parentNavgationController = self.navigationController;
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
//        [self presentViewController:nav animated:YES completion:^{
//            
//        }];
//    }
    
    
}



- (IBAction)showGuide:(id)sender
{
    
    [UIView animateWithDuration:0.45f animations:^{
        if(self.guideView.alpha == 1.0f){
            self.guideView.alpha = 0.0f;
        }else{
            self.guideView.alpha = 1.0f;
        }
    }];
}

- (void)obtainDataSource
{
    //初始化队列
    ASINetworkQueue *requestQueue = [[ASINetworkQueue alloc] init];
    [requestQueue setShouldCancelAllRequestsOnFailure:YES];
    [requestQueue setDelegate:self];
    [requestQueue setQueueDidFinishSelector:@selector(queueFinished:)];
    
    //初始化摘要HTTP
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:QueryProductDetail]];
    request.tag = 0;
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestFinished:)];
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"productId"] = self.proId;
    setting = [[HTTPRequestManager sharedInstance] secretBuild:setting];
    
    [request appendPostData:[NSJSONSerialization dataWithJSONObject:setting options:0 error:nil]];
    [requestQueue addOperation:request];
    request = nil;
    //初始化扩展信息
    request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:QueryProductExtInfo]];
    request.tag = 1;
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestFinished:)];
    setting = [NSMutableDictionary dictionary];
    setting[@"productId"] = self.proId;
    setting = [[HTTPRequestManager sharedInstance] secretBuild:setting];
    
    [request appendPostData:[NSJSONSerialization dataWithJSONObject:setting options:0 error:nil]];
    [requestQueue addOperation:request];
    
    if(!self.appraiseInfo && self.boxProductId)
    {
        request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:FetchAppraiseDetail]];
        request.tag = 2;
        [request addRequestHeader:@"Content-Type" value:@"application/json; charset=utf-8"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
        [request setRequestMethod:@"POST"];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(requestFinished:)];
        setting = [NSMutableDictionary dictionary];
        setting[@"boxProductId"] = self.boxProductId;
        setting = [[HTTPRequestManager sharedInstance] secretBuild:setting];
        
        [request appendPostData:[NSJSONSerialization dataWithJSONObject:setting options:0 error:nil]];
        [requestQueue addOperation:request];
    }
    if([self.drugBoxList count] == 0 && self.showRightBarButton && app.logStatus)
    {
        setting = [NSMutableDictionary dictionary];
        request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:QueryDrugBoxList]];
        request.tag = 3;
        [request setRequestMethod:@"POST"];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(requestFinished:)];
        setting[@"passportId"] = app.configureList[APP_PASSPORTID_KEY];
        setting[@"currPage"] = @"1";
        setting[@"pageSize"] = @"0";
        setting = [[HTTPRequestManager sharedInstance] secretBuild:setting];
        [request addRequestHeader:@"Content-Type" value:@"application/json; charset=utf-8"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
        [request appendPostData:[NSJSONSerialization dataWithJSONObject:setting options:0 error:nil]];
        [requestQueue addOperation:request];
    }
    [requestQueue go];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    self.collectBarButton.enabled = YES;
    NSDictionary *dict = [[request responseString] JSONValue];
    switch (request.tag) {
        case 0:
        {
            [self fillupBaseInfo:dict];
            break;
        }
        case 1:
        {
            [self fillupExtInfo:dict];
            break;
        }
        case 2:
        {
            self.appraiseInfo = [dict[@"body"][@"DBoxAppraiseInfo"] mutableCopy];
            [self setupMarkLabel];
            break;
        }
        case 3:
        {
            NSArray *array = dict[@"body"][@"data"];
            if([array count] > 0){
                [self.drugBoxList addObjectsFromArray:array];
            }
            break;
        }
        default:
            break;
    }
    
}

- (void)adjustTableViewContent
{
    //判断显示多少个cell
    NSUInteger count = 1;
    NSString *attr = self.drugInfo[@"attr1"];
    if(attr && ![attr isEqualToString:@"-"])
    {
        attr = [[attr componentsSeparatedByString:@"<br/>"] componentsJoinedByString:@"\n"];
        self.drugInfo[[NSString stringWithFormat:@"attr%d",count++]] = attr;
        NSString *signcode = self.drugInfo[@"signCode"];
        if([signcode isEqualToString:@"1a"] || [signcode isEqualToString:@"2a"] || [signcode isEqualToString:@"3a"])
        {
            [self.baseInfo addObject:@"适应症"];
        }else if ([signcode isEqualToString:@"1b"] || [signcode isEqualToString:@"2b"] || [signcode isEqualToString:@"3b"]) {
            [self.baseInfo addObject:@"功能主治"];
        }else if([signcode isEqualToString:@"5"]) {
            [self.baseInfo addObject:@"推荐人群"];
        }else{
            [self.baseInfo addObject:@"适用范围"];
        }

        countOfContent++;
    }
    attr = self.drugInfo[@"attr2"];
    if(attr && ![attr isEqualToString:@"-"]){
        attr = [[attr componentsSeparatedByString:@"<br/>"] componentsJoinedByString:@"\n"];
        self.drugInfo[[NSString stringWithFormat:@"attr%d",count++]] = attr;
        countOfContent++;
        [self.baseInfo addObject:@"用法用量"];
    }
    attr = self.drugInfo[@"attr3"];
    if(attr && ![attr isEqualToString:@"-"])
    {
        [self.baseInfo addObject:@"不良反应"];
        attr = [[attr componentsSeparatedByString:@"<br/>"] componentsJoinedByString:@"\n"];
        self.drugInfo[[NSString stringWithFormat:@"attr%d",count++]] = attr;
        countOfContent++;
    }
    attr = self.drugInfo[@"attr4"];
    if(attr && ![attr isEqualToString:@"-"])
    {
        [self.baseInfo addObject:@"使用禁忌提示"];
        attr = [[attr componentsSeparatedByString:@"<br/>"] componentsJoinedByString:@"\n"];
        self.drugInfo[[NSString stringWithFormat:@"attr%d",count++]] = attr;
        countOfContent++;
    }
    attr = self.drugInfo[@"attr5"];
    if(attr && ![attr isEqualToString:@"-"]){
        [self.baseInfo addObject:@"使用注意"];
        attr = [[attr componentsSeparatedByString:@"<br/>"] componentsJoinedByString:@"\n"];
        self.drugInfo[[NSString stringWithFormat:@"attr%d",count++]] = attr;
        countOfContent++;
    }
    attr = self.drugInfo[@"attr6"];
    if(attr && ![attr isEqualToString:@"-"]){
        [self.baseInfo addObject:@"孕妇及哺乳妇女使用注意"];
        attr = [[attr componentsSeparatedByString:@"<br/>"] componentsJoinedByString:@"\n"];
        self.drugInfo[[NSString stringWithFormat:@"attr%d",count++]] = attr;
        countOfContent++;
    }
    attr = self.drugInfo[@"attr7"];
    if(attr && ![attr isEqualToString:@"-"]){
        [self.baseInfo addObject:@"儿童使用注意"];
        attr = [[attr componentsSeparatedByString:@"<br/>"] componentsJoinedByString:@"\n"];
        self.drugInfo[[NSString stringWithFormat:@"attr%d",count++]] = attr;
        countOfContent++;
    }
    attr = self.drugInfo[@"attr8"];
    if(attr && ![attr isEqualToString:@"-"]){
        [self.baseInfo addObject:@"老年人注意"];
        attr = [[attr componentsSeparatedByString:@"<br/>"] componentsJoinedByString:@"\n"];
        self.drugInfo[[NSString stringWithFormat:@"attr%d",count++]] = attr;
        countOfContent++;
    }
    attr = self.drugInfo[@"attr9"];
    if(attr && ![attr isEqualToString:@"-"]){
        [self.baseInfo addObject:@"药物相互作用"];
        attr = [[attr componentsSeparatedByString:@"<br/>"] componentsJoinedByString:@"\n"];
        self.drugInfo[[NSString stringWithFormat:@"attr%d",count++]] = attr;
        countOfContent++;
    }
    attr = self.drugInfo[@"attr10"];
    if(attr && ![attr isEqualToString:@"-"]){
        [self.baseInfo addObject:@"性味归经"];
        attr = [[attr componentsSeparatedByString:@"<br/>"] componentsJoinedByString:@"\n"];
        self.drugInfo[[NSString stringWithFormat:@"attr%d",count++]] = attr;
        countOfContent++;
    }
    //判断显示多少个footview
    UIView *footerView = [[UIView alloc] init];
    [footerView setBackgroundColor:[UIColor clearColor]];
    if(self.appraiseInfo && self.boxProductId)
    {
        footerView.frame = CGRectMake(0, 0, 320, 60);
        self.markView.frame = CGRectMake(0, 10, 320, 40);
        [footerView addSubview:self.markView];
    }

    if(self.drugInfo[@"knowledgeTitle"])
    {
        self.drugInfo[@"knowledgeContent"] = [[self.drugInfo[@"knowledgeContent"] componentsSeparatedByString:@"<br/>"] componentsJoinedByString:@"\n"];
        medicineDetailCellView = (MedicineDetailCellView *)[[[NSBundle mainBundle] loadNibNamed:@"MedicineDetailCellView" owner:self options:nil] objectAtIndex:0];
        medicineDetailCellView.titleLabel.text = @"用药小知识";
        medicineDetailCellView.contentLabel.text = self.drugInfo[@"knowledgeTitle"];
        [medicineDetailCellView.backImage setImage:[UIImage imageNamed:@"详情-第二张背景带箭头.png"]];
        medicineDetailCellView.frame = CGRectMake(0, footerView.frame.size.height + 10, 320, medicineDetailCellView.frame.size.height);
        footerView.frame = CGRectMake(0, 0, 320, footerView.frame.size.height + medicineDetailCellView.frame.size.height + 20);
        [footerView addSubview:medicineDetailCellView];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchKnowLedge:)];
        [gesture setNumberOfTapsRequired:1];
        [gesture setNumberOfTouchesRequired:1];
        [medicineDetailCellView addGestureRecognizer:gesture];
    }
    if(footerView.frame.size.height > 0)
    {
        self.tableView.tableFooterView = footerView;
    }
}

- (void)queueFinished:(ASINetworkQueue *)queue
{
    isFirstAppear = NO;
    [self decideLogo];
    [self setupTableView];
    [self adjustTableViewContent];
    [self checkLikeStatus];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    @try {
        if(isFirstAppear)
            [self obtainDataSource];
        else
            [self setupMarkLabel];
        [self checkLikeStatus];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    
}

- (void)checkLikeStatus
{
    if(!self.drugInfo[@"sid"] || !app.logStatus)
        return;
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"objId"] = self.drugInfo[@"sid"];
    setting[@"method"] = @"1";
    setting[@"objType"] = [NSNumber numberWithInt:1];;
    [[HTTPRequestManager sharedInstance] favoriteCollect:setting completion:^(id resultObj) {
        if([resultObj[@"body"][@"result"] intValue] == 1)
        {
            self.collectBarButton.tag = 1;
            [self.collectBarButton setImage:[UIImage imageNamed:@"导航栏_已收藏icon.png"]];
        }else
        {
            self.collectBarButton.tag = 0;
            [self.collectBarButton setImage:[UIImage imageNamed:@"导航栏_收藏icon.png"]];
        }
    } failure:^(NSError *error) {
        
    }];
    
}

- (void)setupMarkLabel
{
    if (!self.boxProductId || self.boxProductId.length==0){
        return;
    }
    NSUInteger useEffect = [self.appraiseInfo[@"effect"] intValue];
    switch (useEffect) {
        case 1:
        {
            self.drugEffect.image = [UIImage imageNamed:@"效果好.png"];
            break;
        }
        case 2:
        {
            self.drugEffect.image = [UIImage imageNamed:@"效果一般.png"];
            break;
        }
        case 3:
        {
            self.drugEffect.image = [UIImage imageNamed:@"效果差.png"];
            break;
        }
        default:
        {
            self.drugEffect.image = nil;
            break;
        }
    }
    if(self.appraiseInfo[@"remark"] && ![self.appraiseInfo[@"remark"] isEqualToString:APP_EMPTY_STRING]) {
        self.drugMark.text = self.appraiseInfo[@"remark"];
    }else{
        self.drugMark.text = @"您还未对此药品评价";
    }
}

- (void)decideLogo
{
    NSString *signcode = self.drugInfo[@"signCode"];
    if([signcode isEqualToString:@"1a"])
    {
        self.drugOtcLogo.frame = CGRectMake(15, 30, 20, 14);
        self.drugOtcLogo.image = [UIImage imageNamed:@"处方药.png"];
        self.drugType.text = @"处方药西药";
    }else if([signcode isEqualToString:@"1b"]){
        self.drugOtcLogo.frame = CGRectMake(15, 30, 20, 14);
        self.drugOtcLogo.image = [UIImage imageNamed:@"处方药.png"];
        self.drugType.text = @"处方药中成药";

    }else if([signcode isEqualToString:@"2a"]){
        self.drugOtcLogo.image = [UIImage imageNamed:@"otc-甲类.png"];
        self.drugType.text = @"甲类OTC西药";
    }else if([signcode isEqualToString:@"2b"]){
        self.drugOtcLogo.image = [UIImage imageNamed:@"otc-甲类.png"];
      
        self.drugType.text = @"甲类OTC中成药";
    }
    else if ([signcode isEqualToString:@"3a"]){
        self.drugOtcLogo.image = [UIImage imageNamed:@"otc-乙类.png"];
        self.drugType.text = @"乙类OTC西药";
    }else if([signcode isEqualToString:@"3b"]) {
        self.drugOtcLogo.image = [UIImage imageNamed:@"otc-乙类.png"];
        self.drugType.text = @"乙类OTC中成药";
    }
    if([self.drugInfo[@"isContainEphedrine"] integerValue] == 1){
        //含麻黄碱
        self.ephedrineLabel.hidden = NO;
        self.ephedrineImage.hidden = NO;
    }else{
        self.ephedrineLabel.hidden = YES;
        self.ephedrineImage.hidden = YES;
    }
    //    else if ([signcode isEqualToString:@"4c"]){
//        self.drugOtcLogo.hidden = YES;
//        self.drugType.text = @"定型包装中药饮片";
//    }else if([signcode isEqualToString:@"4d"]){
//        self.drugOtcLogo.hidden = YES;
//        self.drugType.text = @"散装中药饮片";
//    }else if([signcode isEqualToString:@"5"]){
//        self.drugOtcLogo.hidden = YES;
//        self.drugType.text = @"保健食品";
//    }else if([signcode isEqualToString:@"6"]){
//        self.drugOtcLogo.hidden = YES;
//        self.drugType.text = @"食品";
//    }else if([signcode isEqualToString:@"7"]){
//        self.drugOtcLogo.hidden = YES;
//        self.drugType.text = @"械字号一类";
//    }else if([signcode isEqualToString:@"8"]){
//        self.drugOtcLogo.hidden = YES;
//        self.drugType.text = @"械字号二类";
//    }else if([signcode isEqualToString:@"9"]){
//        self.drugOtcLogo.hidden = YES;
//        self.drugType.text = @"械字号三类";
//    }else if([signcode isEqualToString:@"10"]){
//        self.drugOtcLogo.hidden = YES;
//        self.drugType.text = @"消字号";
//    }else if([signcode isEqualToString:@"11"]){
//        self.drugOtcLogo.hidden = YES;
//        self.drugType.text = @"妆字号";
//    }else if([signcode isEqualToString:@"12"]){
//        self.drugOtcLogo.hidden = YES;
//        self.drugType.text = @"无批准号";
//    }else if([signcode isEqualToString:@"13"]){
//        self.drugOtcLogo.hidden = YES;
//        self.drugType.text = @"其他";
//    }else if([signcode isEqualToString:@"a"]){
//        self.drugOtcLogo.hidden = YES;
//        self.drugType.text = @"西药";
//    }else if([signcode isEqualToString:@"b"]){
//        self.drugOtcLogo.hidden = YES;
//        self.drugType.text = @"中成药";
//    }else if([signcode isEqualToString:@"c"]){
//        self.drugOtcLogo.hidden = YES;
//        self.drugType.text = @"中药饮片";
//    }
}

- (IBAction)showAdjustFont:(id)sender
{
    self.tableView.scrollEnabled = NO;
    [self.view bringSubviewToFront:self.backCover];
    self.backCover.hidden = !self.backCover.hidden;
}

- (IBAction)dismissAdjustFontView:(id)sender
{
    self.backCover.hidden = YES;
    self.tableView.scrollEnabled = YES;
}

- (void)resetFont:(id)sender
{
    CGFloat size = defaultFont.pointSize;
    defaultFont = [UIFont systemFontOfSize:size - 3];
    [self adjustFontWithContent];
}

- (IBAction)ZoominFont:(id)sender
{
    CGFloat size = defaultFont.pointSize;
    if(size >= 17.0)
        return;
    defaultFont = [UIFont systemFontOfSize:++size];
    [self adjustFontWithContent];
}

- (IBAction)ZoomoutFont:(id)sender
{
    CGFloat size = defaultFont.pointSize;
    if(size <= 7.0)
        return;
    defaultFont = [UIFont systemFontOfSize:--size];
    [self adjustFontWithContent];
}

- (void)adjustFontWithContent
{
    [self.tableView reloadData];
    //self.drugName.font = defaultFont;
    self.drugType.font = defaultFont;
    self.drugSpec.font = defaultFont;
    self.drugFactory.font = defaultFont;
    self.drugMark.font = defaultFont;
    if(medicineDetailCellView){
        medicineDetailCellView.contentLabel.font = defaultFont;
    }
    CGSize txtSize = getTextSize(self.drugFactory.text, self.drugFactory.font, self.drugFactory.frame.size.width);
    self.vipFlag.frame = RECT(self.drugFactory.frame.origin.x + txtSize.width+5,
                              self.drugFactory.frame.origin.y+3 ,
                              self.vipFlag.frame.size.width, self.vipFlag.frame.size.height);
}

- (IBAction)pushIntoMark:(id)sender
{
//    MedicineMarkViewController *markViewController = nil;
//    if(HIGH_RESOLUTION) {
//        markViewController = [[MedicineMarkViewController alloc] initWithNibName:@"MedicineMarkViewController" bundle:nil];
//    }else{
//        markViewController = [[MedicineMarkViewController alloc] initWithNibName:@"MedicineMarkViewController-480" bundle:nil];
//    }
//    markViewController.boxProductId = self.boxProductId;
//    self.appraiseInfo[@"drugName"] = self.drugName.text;
//    markViewController.appraiseInfo = self.appraiseInfo;
//    
//    [self.navigationController pushViewController:markViewController animated:YES];
//    markViewController.title = @"评价";
}

#pragma mark -
#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)atableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            return 97.0;
        }
        default:{
            CGFloat retHeight = 67;
            NSString *attString = self.drugInfo[[NSString stringWithFormat:@"attr%d",indexPath.section]];
            attString = [[attString componentsSeparatedByString:@"<br/>"] componentsJoinedByString:@"\n"];
            CGSize size = [attString sizeWithFont:defaultFont constrainedToSize:CGSizeMake(295, 1000) lineBreakMode:NSLineBreakByWordWrapping];
            size.height += 5;
            CGFloat different = size.height - 21;
            if(different > 0){
                return retHeight + different;
            }else{
                return retHeight;
            }
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 10)];
    [view setBackgroundColor:[UIColor clearColor]];
    return view;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    NSLog(@"一共有%d条数据",countOfContent);
    return countOfContent;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *searchTableViewIdentifier = @"searchTableViewIdentifier";
    UITableViewCell *cell = (UITableViewCell *)[atableView dequeueReusableCellWithIdentifier:searchTableViewIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchTableViewIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    switch (indexPath.section)
    {
        case 0:
        {
            //摘要信息
            [cell addSubview:self.digestView];
            break;
        }
        default:
        {
            NSString *attString = self.drugInfo[[NSString stringWithFormat:@"attr%d",indexPath.section]];
            CGSize size = [attString sizeWithFont:defaultFont constrainedToSize:CGSizeMake(295, 1000) lineBreakMode:NSLineBreakByWordWrapping];
            size.height += 5;
            CGFloat different = size.height - 21;
            MedicineDetailCellView *cellView = (MedicineDetailCellView *)[[[NSBundle mainBundle] loadNibNamed:@"MedicineDetailCellView" owner:self options:nil] objectAtIndex:0];
            if(different > 0)
            {
                CGRect rect = cellView.frame;
                rect.size.height += different;
                cellView.frame = rect;
                rect = cellView.contentLabel.frame;
                rect.size.height += different;
                cellView.contentLabel.frame = rect;
            }
            UIImage *image = [UIImage imageNamed:@"详情-第二张背景.png"];
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(40, 10, 5, 5) resizingMode:UIImageResizingModeStretch];
            cellView.backImage.frame = cellView.frame;
            [cellView.backImage setImage:image];
            cellView.titleLabel.text = self.baseInfo[indexPath.section - 1];
//            cellView.titleLabel.backgroundColor = [UIColor grayColor];
            cellView.contentLabel.font = defaultFont;
            cellView.contentLabel.text = attString;
            [cell.contentView addSubview:cellView];
            break;
        }
        
    }
    
    return cell;
}

- (void)touchKnowLedge:(UITapGestureRecognizer *)gesture
{
    if(gesture.state == UIGestureRecognizerStateEnded){
        KnowLedgeViewController *knowLedgeViewController = [[KnowLedgeViewController alloc] init];
        knowLedgeViewController.source = @{@"title":self.drugInfo[@"knowledgeTitle"],
                                           @"content":self.drugInfo[@"knowledgeContent"]};
        knowLedgeViewController.knowledgeTitle = self.drugInfo[@"knowledgeTitle"];
        knowLedgeViewController.knowledgeContent = self.drugInfo[@"knowledgeContent"];
        [self.navigationController pushViewController:knowLedgeViewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
