//
//  PharmacyDetailViewController.m
//  wenyao
//
//  Created by xiezhenghong on 14-10-24.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "PharmacyDetailViewController.h"
#import "MedicineDetailViewController.h"
#import "DrugDetailViewController.h"
#import "HTTPRequestManager.h"
#import "AddNewMedicineViewController.h"
#import "AppDelegate.h"
#import "Constant.h"
#import "UIButton+WebCache.h"
#import "UIViewController+isNetwork.h"


@interface PharmacyDetailViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView      *subScrollView;
@property (nonatomic, strong) UIPageControl     *pageControl;
@property (nonatomic, strong) NSMutableArray    *similarDrugList;
@property (nonatomic, assign) BOOL              editPharmacy;
@property (nonatomic, assign) BOOL              didExpand;

@end

@implementation PharmacyDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"用药详情";
    
    if([self isNetWorking]){
        [self addNetView];
        return;
    }
    [self subViewDidLoad];
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

- (void)subViewDidLoad{
    
    self.similarDrugList = [NSMutableArray arrayWithCapacity:15];
    
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editPharmacy:)];
    self.scrollView.contentSize = CGSizeMake(APP_W, 400);
    [self initCacheUI];
    [self queryPharmacyDetail];
    [self querySimilarDrug];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePharmacy) name:PHARMACY_NEED_UPDATE object:nil];
    
    
    //自定义title
    UIBarButtonItem *btnItemBoutique = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editPharmacy:)];
    
    self.navigationItem.rightBarButtonItem = btnItemBoutique;
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    lblTitle.font = [UIFont systemFontOfSize:18.0f];
    lblTitle.text = @"用药详情";
    [lblTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0f]];
    lblTitle.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = lblTitle;
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(10, 39.5, APP_W - 20, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [self.effectView addSubview:line];
    
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, self.headerView.frame.size.height - 0.5, APP_W, 0.5)];
    line1.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [self.headerView addSubview:line1];
    
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_W, 0.5)];
    line2.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [self.effectView addSubview:line2];
    
    UIView *line5 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_W, 0.5)];
    line5.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [self.footerView addSubview:line5];
    
    UIView *line4 = [[UIView alloc]initWithFrame:CGRectMake(10, 40, APP_W - 20, 0.5)];
    line4.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [self.footerView addSubview:line4];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PHARMACY_NEED_UPDATE object:nil];
}

- (void)updatePharmacy
{
    [self initCacheUI];
    [self queryPharmacyDetail];
}

//cell的收缩高度
- (CGFloat)calculateCollapseHeigtOffsetWithFontSize:(UIFont *)fontSize withTextSting:(NSString *)text
{
    CGSize adjustSize = [text sizeWithFont:fontSize constrainedToSize:CGSizeMake(294, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    if(adjustSize.height > 90.0f)
    {
        if (self.didExpand) {
            return adjustSize.height;
        } else {
            return 90.0f;
        }
    }else{
        return adjustSize.height;//0;
    }
}

- (BOOL)shouldAddExpandView:(NSString *)strProductEffect withFont:(UIFont *)fontSize
{
    CGSize adjustSize = [strProductEffect sizeWithFont:fontSize constrainedToSize:CGSizeMake(294, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    if (adjustSize.height > 90.0f) {
        return YES;
    } else {
        return NO;
    }
}

- (void)initCacheUI
{
    self.titleLabel.text = self.infoDict[@"productName"];
    if(self.infoDict[@"source"])
    {
        self.sourceLabel.text = self.infoDict[@"source"];
    }else{
        self.sourceTitleLabel.hidden = YES;
        self.sourceLabel.hidden = YES;
        self.headerView.frame = CGRectMake(0, 0, APP_W, 120);
    }
    if(!self.infoDict[@"productId"])
    {
        self.OTCImage.hidden = YES;
        self.OTCLabel.hidden = YES;
        self.sourceTitleLabel.hidden = YES;
        self.sourceLabel.hidden = YES;
        self.effectView.hidden = YES;
        self.headerView.frame = CGRectMake(0, 0, APP_W, 90);
    }
    NSString *useName = self.infoDict[@"useName"];
    if(!useName)
    {
        useName = @"";
    }
    self.useNameLabel.text = [NSString stringWithFormat:@"使用者:  %@",useName];
    NSUInteger intervalDay = [self.infoDict[@"intervalDay"] integerValue];
    if(intervalDay == 0) {
        self.useageLabel.text = [NSString stringWithFormat:@"%@,一次%@%@,即需即用",self.infoDict[@"useMethod"],self.infoDict[@"perCount"],self.infoDict[@"unit"]];
    }else{
        self.useageLabel.text = [NSString stringWithFormat:@"%@,一次%@%@,%@日%@次",self.infoDict[@"useMethod"],self.infoDict[@"perCount"],self.infoDict[@"unit"],self.infoDict[@"intervalDay"],self.infoDict[@"drugTime"]];
    }
    CGRect rect = self.effectView.frame;
    rect.origin.y = self.headerView.frame.origin.y + self.headerView.frame.size.height + 10;
    if (self.infoDict[@"productEffect"]) {
        
        CGFloat heightCalculate = [self calculateCollapseHeigtOffsetWithFontSize:[UIFont systemFontOfSize:14.0f] withTextSting:self.infoDict[@"productEffect"]];
        
        self.effectLabel.frame = CGRectMake(self.effectLabel.frame.origin.x, 55, self.effectLabel.frame.size.width, heightCalculate);
//        self.effectLabel.backgroundColor = [UIColor grayColor];
        self.effectView.frame = CGRectMake(self.effectView.frame.origin.x, self.effectView.frame.origin.y, self.effectView.frame.size.width, 108 + heightCalculate + 14);
        NSLog(@"高度%f",self.effectView.frame.size.height);
        
        
        NSLog(@"the label frame is %@",NSStringFromCGRect(self.effectLabel.frame));
        if ([self shouldAddExpandView:self.infoDict[@"productEffect"] withFont:[UIFont systemFontOfSize:14.0f]]) {
            rect.size.height = self.effectLabel.frame.origin.y + self.effectLabel.frame.size.height + 20.0f;
            self.expandButton.hidden = NO;
        } else {
            rect.size.height = self.effectLabel.frame.origin.y + self.effectLabel.frame.size.height + 19.0f;
            self.expandButton.hidden = YES;
        }
    } else {
        
    }
    self.effectView.frame = rect;
    rect = self.footerView.frame;
    rect.origin.y = self.effectView.frame.origin.y + self.effectView.frame.size.height + 10;
    self.footerView.frame = rect;
}

- (void)decideLogo
{
    NSString *signcode = self.infoDict[@"signCode"];
    NSString *recipeString = nil;
    if([signcode isEqualToString:@"1a"])
    {
        self.OTCImage.image = [UIImage imageNamed:@"处方药.png"];
        self.OTCImage.frame = CGRectMake(self.OTCImage.frame.origin.x + 12, self.OTCImage.frame.origin.y + 2.5, 20, 14);
        self.OTCLabel.text = @"处方药";
        recipeString = @"西药";
    }else if([signcode isEqualToString:@"1b"]){
        self.OTCImage.frame = CGRectMake(self.OTCImage.frame.origin.x + 12, self.OTCImage.frame.origin.y + 2.5, 20, 14);
        self.OTCImage.image = [UIImage imageNamed:@"处方药.png"];
        self.OTCLabel.text = @"处方药";
        recipeString = @"中成药";
    }else if([signcode isEqualToString:@"2a"]){
        self.OTCImage.frame = CGRectMake(self.OTCImage.frame.origin.x, self.OTCImage.frame.origin.y, 51, 20);
        self.OTCImage.image = [UIImage imageNamed:@"otc-甲类.png"];
        self.OTCLabel.text = @"甲类OTC非处方药";
        recipeString = @"西药";
    }else if([signcode isEqualToString:@"2b"]){
        self.OTCImage.frame = CGRectMake(self.OTCImage.frame.origin.x, self.OTCImage.frame.origin.y, 51, 20);
        self.OTCImage.image = [UIImage imageNamed:@"otc-甲类.png"];
        self.OTCLabel.text = @"甲类OTC非处方药";
        recipeString = @"中成药";
    }
    else if ([signcode isEqualToString:@"3a"]){
        self.OTCImage.frame = CGRectMake(self.OTCImage.frame.origin.x,  self.OTCImage.frame.origin.y, 51, 20);
        self.OTCImage.image = [UIImage imageNamed:@"otc-乙类.png"];
        self.OTCLabel.text = @"乙类OTC非处方药";
        recipeString = @"西药";
    }else if([signcode isEqualToString:@"3b"]) {
        self.OTCImage.frame = CGRectMake(self.OTCImage.frame.origin.x, self.OTCImage.frame.origin.y, 51, 20);
        self.OTCImage.image = [UIImage imageNamed:@"otc-乙类.png"];
        self.OTCLabel.text = @"乙类OTC非处方药";
        recipeString = @"中成药";
    }else if([signcode isEqualToString:@"4c"]) {
        self.OTCImage.hidden = YES;
        self.OTCLabel.text = @"定型包装中药饮片";
    }else if([signcode isEqualToString:@"4d"]) {
        self.OTCImage.hidden = YES;
        self.OTCLabel.text = @"散装中药饮片";
    }else if([signcode isEqualToString:@"5"]) {
        self.OTCImage.hidden = YES;
        self.OTCLabel.text = @"保健食品";
    }else if([signcode isEqualToString:@"6"]) {
        self.OTCImage.hidden = YES;
        self.OTCLabel.text = @"食品";
    }else if([signcode isEqualToString:@"7"]) {
        self.OTCImage.hidden = YES;
        self.OTCLabel.text = @"机械号一类";
    }else if([signcode isEqualToString:@"8"]) {
        self.OTCImage.hidden = YES;
        self.OTCLabel.text = @"机械号二类";
    }else if([signcode isEqualToString:@"10"]) {
        self.OTCImage.hidden = YES;
        self.OTCLabel.text = @"消字号";
    }else if([signcode isEqualToString:@"11"]) {
        self.OTCImage.hidden = YES;
        self.OTCLabel.text = @"妆字号";
    }else if([signcode isEqualToString:@"12"]) {
        self.OTCImage.hidden = YES;
        self.OTCLabel.text = @"无批准号";
    }else if([signcode isEqualToString:@"13"]) {
        self.OTCImage.hidden = YES;
        self.OTCLabel.text = @"其他";
    }else if([signcode isEqualToString:@"9"]) {
        self.OTCImage.hidden = YES;
        self.OTCLabel.text = @"械字号三类";
    }
    if(recipeString)
    {
        if([recipeString isEqualToString:@"西药"]) {
            self.recipeImage.image = [UIImage imageNamed:@"西药.png"];
        }else{
            self.recipeImage.image = [UIImage imageNamed:@"中成药-1.png"];
        }
        self.recipeLabel.text = recipeString;

    }
    if([self.infoDict[@"isContainEphedrine"] integerValue] == 1){
        //含麻黄碱
        
    }else{
        
        
    }
//    else if ([signcode isEqualToString:@"4c"]){
//        self.OTCImage.hidden = YES;
//        self.OTCLabel.text = @"定型包装中药饮片";
//    }else if([signcode isEqualToString:@"4d"]){
//        self.OTCImage.hidden = YES;
//        self.OTCLabel.text = @"散装中药饮片";
//    }else if([signcode isEqualToString:@"5"]){
//        self.OTCImage.hidden = YES;
//        self.OTCLabel.text = @"保健食品";
//    }else if([signcode isEqualToString:@"6"]){
//        self.OTCImage.hidden = YES;
//        self.OTCLabel.text = @"食品";
//    }else if([signcode isEqualToString:@"7"]){
//        self.OTCImage.hidden = YES;
//        self.OTCLabel.text = @"械字号一类";
//    }else if([signcode isEqualToString:@"8"]){
//        self.OTCImage.hidden = YES;
//        self.OTCLabel.text = @"械字号二类";
//    }else if([signcode isEqualToString:@"9"]){
//        self.OTCImage.hidden = YES;
//        self.OTCLabel.text = @"械字号三类";
//    }else if([signcode isEqualToString:@"10"]){
//        self.OTCImage.hidden = YES;
//        self.OTCLabel.text = @"消字号";
//    }else if([signcode isEqualToString:@"11"]){
//        self.OTCImage.hidden = YES;
//        self.OTCLabel.text = @"妆字号";
//    }else if([signcode isEqualToString:@"12"]){
//        self.OTCImage.hidden = YES;
//        self.OTCLabel.text = @"无批准号";
//    }else if([signcode isEqualToString:@"13"]){
//        self.OTCImage.hidden = YES;
//        self.OTCLabel.text = @"其他";
//    }else if([signcode isEqualToString:@"a"]){
//        self.OTCImage.hidden = YES;
//        self.OTCLabel.text = @"西药";
//    }else if([signcode isEqualToString:@"b"]){
//        self.OTCImage.hidden = YES;
//        self.OTCLabel.text = @"中成药";
//    }else if([signcode isEqualToString:@"c"]){
//        self.OTCImage.hidden = YES;
//        self.OTCLabel.text = @"中药饮片";
//    }
}

- (void)queryPharmacyDetail
{
    
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"boxId"] = self.infoDict[@"boxId"];
    [[HTTPRequestManager sharedInstance] getBoxProductDetail:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"])
        {
//            [self.infoDict addEntriesFromDictionary:resultObj[@"header"]];
            [self.infoDict addEntriesFromDictionary:resultObj[@"body"]];
            
            NSString *productEffect = self.infoDict[@"productEffect"];
 
            self.effectLabel.text = productEffect;
            NSLog(@"<><><><>生产厂商是：%@",self.infoDict[@"source"]);
            [self initCacheUI];
            [self decideLogo];
        }
    } failure:NULL];
}

- (void)setupFooterView
{
    NSUInteger page = (self.similarDrugList.count - 1) / 6 + 1;
    if(!self.subScrollView) {
        self.subScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, APP_W, 170)];
        [self.subScrollView setBackgroundColor:[UIColor clearColor]];
        self.subScrollView.showsHorizontalScrollIndicator = NO;
        
        self.subScrollView.pagingEnabled = YES;
        self.subScrollView.delegate = self;
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-60)/2, 225, 60, 10)];
        
        self.pageControl.currentPageIndicatorTintColor = APP_COLOR_STYLE;
        self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        self.pageControl.currentPage = 0;
        
        [self.footerView addSubview:self.subScrollView];
        [self.footerView addSubview:self.pageControl];
    }
    if(self.similarDrugList.count > 6){
        self.pageControl.hidden = NO;
    }else{
        self.pageControl.hidden = YES;
    }
    self.pageControl.numberOfPages = page;
    
    [self.subScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.subScrollView.contentSize = CGSizeMake(APP_W * page, 0);
    CGFloat offset = 0.0;
    CGFloat padding = APP_W / 3;
    for(NSUInteger index = 0; index < self.similarDrugList.count; ++index)
    {
        NSUInteger currentPage = index / 6;
        NSDictionary *dict = self.similarDrugList[index];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImageWithURL:[NSURL URLWithString:PORID_IMAGE(dict[@"productId"])] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"药品默认图片.png"]];
        NSUInteger up = ((index - 6 * currentPage) / 3 > 0) ? 1: 0;
        button.frame = CGRectMake((index % 3) * padding + 26 + currentPage * APP_W, up * 80 + 5 , 50, 50);
        button.tag = 1000 + index;
        [button addTarget:self action:@selector(pushIntoMedicineDetail:) forControlEvents:UIControlEventTouchDown];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((index % 3) * padding + 3 + currentPage * APP_W, up * 80 + 65, 100, 20)];
        label.text = dict[@"productName"];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = UICOLOR(51, 51, 51);
        label.font = [UIFont systemFontOfSize:12.0];
        [self.subScrollView addSubview:button];
        [self.subScrollView addSubview:label];
    }
    
    self.scrollView.contentSize = CGSizeMake(APP_W, self.footerView.frame.origin.y + self.footerView.frame.size.height + 10);
}

- (void)backToPreviousController:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    if(self.changeMedicineInformation && self.editPharmacy)
    {
        self.changeMedicineInformation(self.infoDict);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int w = 0, i = 0;
    for (i = 0; i < self.pageControl.numberOfPages; i++)
    {
        if (scrollView.contentOffset.x <= w)
            break;
        w += self.scrollView.frame.size.width;
    }
    self.pageControl.currentPage = i;
}

- (void)querySimilarDrug
{
    if(!self.infoDict[@"productId"])
        return;
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"productId"] = self.infoDict[@"productId"];
    setting[@"currPage"] = @"1";
    setting[@"pageSize"] = @"12";
    [[HTTPRequestManager sharedInstance] similarDrug:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]) {
            [self.similarDrugList removeAllObjects];
            NSArray *array = resultObj[@"body"][@"data"];
            if(array.count > 0)
            {
                self.footerView.hidden = NO;
                [self.similarDrugList addObjectsFromArray:array];
                [self setupFooterView];
            }
        }
    } failure:NULL];
}

- (void)editPharmacy:(id)sender
{
    __weak __typeof(self)weakSelf = self;
    AddNewMedicineViewController *addNewMedicineViewController = [[AddNewMedicineViewController alloc] initWithNibName:@"AddNewMedicineViewController" bundle:nil];
    addNewMedicineViewController.editMode = 1;
    addNewMedicineViewController.InsertNewPharmacy = ^(NSMutableDictionary *dict) {
        weakSelf.editPharmacy = YES;
    };
    addNewMedicineViewController.originDict = self.infoDict;
    [self.navigationController pushViewController:addNewMedicineViewController animated:YES];
}

- (IBAction)pushIntoMedicineDetail:(UIButton *)sender
{
    DrugDetailViewController *medicineDetailViewController = [[DrugDetailViewController alloc] init];
    if(sender.tag > 1000) {
        medicineDetailViewController.proId = self.similarDrugList[sender.tag - 1000][@"productId"];
    }else{
        medicineDetailViewController.proId = self.infoDict[@"productId"];
    }
    [self.navigationController pushViewController:medicineDetailViewController animated:YES];
}

- (IBAction)expandEffect:(UIButton *)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        if(sender.tag){
            //收缩
            self.didExpand = NO;
            self.expandButton.transform = CGAffineTransformMakeRotation(0);
            CGRect rect = self.effectView.frame;
            CGFloat heightCalculate = [self calculateCollapseHeigtOffsetWithFontSize:[UIFont systemFontOfSize:14.0f] withTextSting:self.infoDict[@"productEffect"]];
            self.effectLabel.frame = CGRectMake(self.effectLabel.frame.origin.x, self.effectLabel.frame.origin.y, self.effectLabel.frame.size.width, heightCalculate);
            if ([self shouldAddExpandView:self.infoDict[@"productEffect"] withFont:[UIFont systemFontOfSize:14.0f]]) {
                rect.size.height = self.effectLabel.frame.origin.y + self.effectLabel.frame.size.height + 20.0f;
//                self.expandButton.hidden = NO;
            } else {
//                rect.size.height = self.effectLabel.frame.origin.y + self.effectLabel.frame.size.height + 5.0f;
//                self.expandButton.hidden = YES;
            }
            
//            rect.size.height = 18;
//            self.effectLabel.frame = rect;
            
            self.effectView.frame = rect;
            
            rect = self.footerView.frame;
            rect.origin.y = self.effectView.frame.origin.y + self.effectView.frame.size.height + 10;
            self.footerView.frame = rect;
            
            self.scrollView.contentSize = CGSizeMake(APP_W, rect.origin.y + rect.size.height + 10);
            
            sender.tag = 0;
        }else{
            //展开
            sender.tag = 1;
            self.didExpand = YES;
            self.expandButton.transform = CGAffineTransformMakeRotation(M_PI);
            NSString *productEffect = self.infoDict[@"productEffect"];
            CGSize size = [productEffect sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(302, 1000)];
            
            CGRect rect = self.effectView.frame;
            CGFloat heightCalculate = [self calculateCollapseHeigtOffsetWithFontSize:[UIFont systemFontOfSize:14.0f] withTextSting:self.infoDict[@"productEffect"]];
            self.effectLabel.frame = CGRectMake(self.effectLabel.frame.origin.x, self.effectLabel.frame.origin.y, self.effectLabel.frame.size.width, heightCalculate);
            if ([self shouldAddExpandView:self.infoDict[@"productEffect"] withFont:[UIFont systemFontOfSize:14.0f]]) {
                rect.size.height = self.effectLabel.frame.origin.y + self.effectLabel.frame.size.height + 20.0f;
                //                self.expandButton.hidden = NO;
            } else {
                //                rect.size.height = self.effectLabel.frame.origin.y + self.effectLabel.frame.size.height + 5.0f;
                //                self.expandButton.hidden = YES;
            }
            
            //            rect.size.height = 18;
            //            self.effectLabel.frame = rect;
//            rect = self.effectView.frame;
            self.effectView.frame = rect;
            
            rect = self.footerView.frame;
            rect.origin.y = self.effectView.frame.origin.y + self.effectView.frame.size.height + 10;
            self.footerView.frame = rect;
            
            self.scrollView.contentSize = CGSizeMake(APP_W, rect.origin.y + rect.size.height + 10);

//            CGFloat offset = size.height - 18;
//            if(offset > 0){
//                CGRect rect = self.effectLabel.frame;
//                rect.size.height = size.height;
//                self.effectLabel.frame = rect;
//                
//                rect = self.effectView.frame;
//                rect.size.height += offset;
//                self.effectView.frame = rect;
//                
//                rect = self.footerView.frame;
//                rect.origin.y += offset;
//                self.footerView.frame = rect;
//                
//                self.scrollView.contentSize = CGSizeMake(APP_W, rect.origin.y + rect.size.height + 10);
//            }
            
        }
    }];
    
    
    
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
