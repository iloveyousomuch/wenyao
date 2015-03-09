//
//  DiseaseDetailViewController.m
//  quanzhi
//
//  Created by Meng on 14-12-10.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "DiseaseDetailViewController.h"
#import "DiseaseMedicineListViewController.h"
#import "LoginViewController.h"
#import "HTTPRequestManager.h"
#import "AppDelegate.h"
#import "Categorys.h"
#import "AFNetworking.h"
#import "ZhPMethod.h"
#import "SVProgressHUD.h"
#import "SBTextView.h"
#import "relateBgView.h"
#import "CalculateButtonViewHegiht.h"
#import "treatRuleBgView.h"
#import "DisesaeDetailInfoButton.h"
#import "CusTapGestureRecognizer.h"
#import "UIViewController+isNetwork.h"
#import "ReturnIndexView.h"

#define kCauseTitle     @"病因"
#define kTraitTitle     @"疾病特点"
#define kSimilarTitle   @"易混淆疾病"
//---------------------------------------------
//A类 B类 的名称显示(此处分开写,方便应对产品人员脑子发热)
#define kTreatTitle_A   @"治疗原则"//A类疾病
#define kTreatTitle_B   @"治疗原则"//B类疾病
#define kHabitTitle     @"合理生活习惯"

#define kTitleFontSize  14 //标题字体大小
#define kDescFontSize   12 //描述字体大小


#define kX              10//控件的x坐标
#define kY              10//控件的y坐标
#define kH              10//两个控件间距离
#define kB              10//控件底部距离
#define kSectionHeight  30//Section段头的高度


#define kBoxBackgroundColor     UICOLOR(255, 249, 222)          //背景颜色
#define kBoxBorderColor         UICOLOR(254, 229, 176).CGColor  //边框颜色
#define kBoxBorderWidth         1                               //边框宽度

#define kEBu                    10//恶补高度
#define kRelateButtonHeight     20 //易混淆疾病的button高度

#define kRelateBoxIsShow        @"YES"//易混淆疾病的box是否显示 YES显示
#define kRelateBoxTag           300 //易混淆疾病box的tag值
#define kRelateBgViewTag        301//易混淆疾病的大背景

#define kTreatRuleBoxTag            400//治疗原则红色背景tag
#define kTreatRuleTitleTag          4001//
#define kTreatRuleContentTag        4002//
#define kTreatRuleButtonBgView      403

#define kThreeButtonBgViewHeight    40
#define kThreeButtonTag             4567

#define kRelateDiseaseLabelTag      4005
@interface DiseaseDetailViewController ()<UITableViewDelegate, UITableViewDataSource,treatRuleBgViewDelegate,relateBgViewDelegate,ReturnIndexViewDelegate>
{
    
    CGFloat titleFontSize;
    CGFloat descFontSize;
    
    UIImageView * buttonImage;
    
    BOOL isUp;
}

@property (strong, nonatomic) ReturnIndexView *indexView;
@property (strong, nonatomic) NSString *collectButtonImageName;
@property (weak,   nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *DescCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *DiseasCauseeCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *DiseasFeatureCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *LifeHabitsCell;
@property (strong, nonatomic) IBOutlet UIView *headerView;

//黄色背景
@property (weak, nonatomic) IBOutlet UIView *causebgView;
@property (weak, nonatomic) IBOutlet UIView *traitbgView;
@property (weak, nonatomic) IBOutlet UIView *habitbgView;

//cell内容
//疾病
@property (weak, nonatomic) IBOutlet SBTextView *diseaseTitleTextView;
@property (weak, nonatomic) IBOutlet SBTextView *diseaseDescTextView;

//病因
@property (weak, nonatomic) IBOutlet UITextView *causeTitleTextView;
@property (weak, nonatomic) IBOutlet UITextView *causeContentTextView;

//病症
@property (weak, nonatomic) IBOutlet UITextView *traitTitleTextView;
@property (weak, nonatomic) IBOutlet UITextView *traitContentTextView;

//合理生活习惯
@property (weak, nonatomic) IBOutlet UITextView *habitTitleTextView;
@property (weak, nonatomic) IBOutlet UITextView *habitContentTextView;



@property (nonatomic, strong) NSMutableDictionary *tempDic;
@property (nonatomic ,strong) NSMutableDictionary * diseaseDict;
@property (nonatomic ,strong) NSMutableArray * formulaListArray;
@property (nonatomic ,strong) NSMutableArray * formulaDetailArray;

@end



@implementation DiseaseDetailViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        if (!HIGH_RESOLUTION) {
            [self.tableView setFrame:CGRectMake(0, 0, APP_W, APP_H - NAV_H)];
        }
    }
    return self;
}

//特殊字符的替换
- (NSString *)replaceSpecialStringWith:(NSString *)string{
    if(!string)
        return @"";
    string = [string stringByReplacingOccurrencesOfString:@"    &nbsp;&nbsp;&nbsp;&nbsp;" withString:@"    "];
    string = [string stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    string = [string stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\r\n"];
    string = [string stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r\n"];
    string = [string stringByReplacingOccurrencesOfString:@"<p/>" withString:@"\r\n"];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"&lt:" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt:" withString:@">"];
    return string;
    
}

-(CGSize)getTextViewHeightWithContent:(NSString *)content FontSize:(CGFloat)fontSize width:(CGFloat)width
{
    if (content != nil && content.length > 0) {
        CGFloat tvHeight =0.0f;
        SBTextView *textViewTemp = [[SBTextView alloc] initWithFrame:CGRectMake(0, 0, width, 5000)];
        content = [self replaceSpecialStringWith:content];
        textViewTemp.text = content;
        textViewTemp.font = Font(fontSize);
        [textViewTemp sizeToFit];
        if([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f){
            tvHeight = [textViewTemp.layoutManager usedRectForTextContainer:textViewTemp.textContainer].size.height+2*fabs(textViewTemp.contentInset.top);
        }else{
            tvHeight = textViewTemp.contentSize.height;
        }
        CGSize size = CGSizeMake(textViewTemp.FW, tvHeight);
        NSLog(@"%f",tvHeight);
        return size;
    }else{
        return CGSizeMake(0, 0);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([self isNetWorking]){
        [self addNetView];
        return;
    }
    [self subViewDidLoad];

}

#pragma ---index---
- (void)setRightItems{
    
    UIView *ypDetailBarItems=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 120, 55)];
    
    CGSize size = [@"Aa" sizeWithFont:[UIFont systemFontOfSize:19.0f]];
    UIButton * zoomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [zoomButton setFrame:CGRectMake(28, 0, 55,55)];
    [zoomButton addTarget:self action:@selector(zoomButtonClick) forControlEvents:UIControlEventTouchUpInside];
    zoomButton.titleLabel.font = [UIFont systemFontOfSize:19.0f];
    zoomButton.titleLabel.textColor = [UIColor whiteColor];
    [zoomButton setTitle:@"Aa" forState:UIControlStateNormal];
    [ypDetailBarItems addSubview:zoomButton];
    
    UIButton *indexButton=[[UIButton alloc]initWithFrame:CGRectMake(65, 0, 55, 55)];
    [indexButton setImage:[UIImage imageNamed:@"icon-unfold.PNG"] forState:UIControlStateNormal];
    [indexButton addTarget:self action:@selector(returnIndex) forControlEvents:UIControlEventTouchDown];
    [ypDetailBarItems addSubview:indexButton];
    
    UIBarButtonItem *fix=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fix.width=-20;
    self.navigationItem.rightBarButtonItems=@[fix,[[UIBarButtonItem alloc]initWithCustomView:ypDetailBarItems]];
    
    
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
    
    [self setDiseaseId:self.diseaseId];
    titleFontSize = kTitleFontSize;
    descFontSize = kDescFontSize;
    isUp = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.diseaseDict = [NSMutableDictionary dictionary];
    self.formulaListArray = [NSMutableArray array];
    self.formulaDetailArray = [NSMutableArray array];
    self.tableView.backgroundColor = UIColorFromRGB(0xecf0f1);
    //[self setRightBarButton];
    [self setRightItems];
}

//- (void)setDiseaseName:(NSString *)diseaseName
//{
//
//
////    _diseaseName = diseaseName;
////    [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeNone];
////    [[HTTPRequestManager sharedInstance] queryDiseaseDetailIos:@{@"diseaseName":diseaseName} completion:^(id resultObj) {
////        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
////
////
//////            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
//////            //[dic addEntriesFromDictionary:resultObj[@"body"]];
//////            dic = resultObj[@"body"];
////
////            [self.diseaseDict addEntriesFromDictionary:resultObj[@"body"]];
////
////            NSLog(@"dic=====%@",self.diseaseDict);
////
////            if ([self.diseaseDict count] == 0)
////            {
////                [SVProgressHUD dismissWithError:@"暂无疾病详情" afterDelay:0.8f];
////
////            }else
////            {
//////                [self.diseaseDict addEntriesFromDictionary:resultObj[@"body"]];
////                [self.formulaListArray removeAllObjects];
////                [self.formulaListArray addObjectsFromArray:self.diseaseDict[@"formulaList"]];
////                if (self.diseaseDict.count > 0) {
////                    //控制展开和收缩
////                    NSString * expendYES = @"1";
////                    NSString * expendNO = @"2";
////
////                    /*
////                     #define kCauseTitle     @"病因"
////                     #define kTraitTitle     @"病症"
////                     #define kSimilarTitle   @"易混淆疾病鉴别"
////                     #define kTreatTitle     @"治疗"
////                     #define kHabitTitle     @"合理生活习惯"
////                     */
////
////                    [self.diseaseDict setObject:expendYES forKey:@"causeExpend"];
////                    [self.diseaseDict setObject:expendYES forKey:@"traitExpend"];
////                    [self.diseaseDict setObject:expendNO forKey:@"similarExpend"];
////                    [self.diseaseDict setObject:expendNO forKey:@"treatExpend"];
////                    [self.diseaseDict setObject:expendNO forKey:@"habitExpend"];
////                    [self checkIsCollectOrNot];
////                }
////                [SVProgressHUD dismiss];
////                [SVProgressHUD dismiss];
////                [self coverData];
////            }
////
////
////        }
////    } failure:^(NSError *error) {
////        [SVProgressHUD dismissWithError:@"请求数据失败！" afterDelay:0.8f];
////
////        if(self.containerViewController) {
////            [self.containerViewController.navigationController popViewControllerAnimated:YES];
////        }else{
////            [self.navigationController popViewControllerAnimated:YES];
////        }
////
////        NSLog(@"error======%@",error);
////    }];
//}
//

- (void)setDiseaseId:(NSString *)diseaseId
{
    _diseaseId = diseaseId;
    [SVProgressHUD showWithStatus:@"数据加载中..." maskType:SVProgressHUDMaskTypeNone];
    [[HTTPRequestManager sharedInstance] queryDiseaseDetailIos:@{@"diseaseId":diseaseId} completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            
            NSLog(@"疾病详情 = %@",resultObj);
            
            [self.diseaseDict addEntriesFromDictionary:resultObj[@"body"]];
            [self.formulaListArray removeAllObjects];
            [self.formulaListArray addObjectsFromArray:self.diseaseDict[@"formulaList"]];
            if (self.diseaseDict.count > 0) {
                //控制展开和收缩
                NSString * expendYES = @"1";
                NSString * expendNO = @"2";
                
                /*
                 #define kCauseTitle     @"病因"
                 #define kTraitTitle     @"病症"
                 #define kSimilarTitle   @"易混淆疾病"
                 #define kTreatTitle     @"治疗"
                 #define kHabitTitle     @"合理生活习惯"
                 */
                
                [self.diseaseDict setObject:expendYES forKey:@"causeExpend"];
                [self.diseaseDict setObject:expendYES forKey:@"traitExpend"];
                [self.diseaseDict setObject:expendNO forKey:@"similarExpend"];
                [self.diseaseDict setObject:expendNO forKey:@"treatExpend"];
                [self.diseaseDict setObject:expendNO forKey:@"habitExpend"];
                [self checkIsCollectOrNot];
            }
            [SVProgressHUD dismiss];
            [self coverData];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        [SVProgressHUD dismiss];
    }];
}

- (void)backToPreviousController:(id)sender
{
    [super backToPreviousController:sender];
    [SVProgressHUD dismiss];
}


- (void)coverData
{
    /*
     #define kCauseTitle     @"病因"
     #define kTraitTitle     @"病症"
     #define kSimilarTitle   @"易混淆疾病鉴别"
     #define kTreatTitle     @"治疗"
     #define kHabitTitle     @"合理生活习惯"
     */
    [self.diseaseDict setObject:kCauseTitle     forKey:@"causeTitle"];
    [self.diseaseDict setObject:kTraitTitle     forKey:@"traitTitle"];
    [self.diseaseDict setObject:kSimilarTitle   forKey:@"similarTitle"];
    if ([self.diseaseType isEqualToString:@"A"]) {
        [self.diseaseDict setObject:kTreatTitle_A forKey:@"treatTitle"];
    }else if ([self.diseaseType isEqualToString:@"B"]){
        [self.diseaseDict setObject:kTreatTitle_B forKey:@"treatTitle"];
    }
    [self.diseaseDict setObject:kHabitTitle     forKey:@"habitTitle"];
    
    //获取字符串
    //第0段 疾病
    NSString * name = [self replaceSpecialStringWith:self.diseaseDict[@"name"]];//疾病名字
    NSString * desc = nil;//疾病描述
    if ([self.diseaseType isEqualToString:@"A"] || [self.diseaseType isEqualToString:@"B"]) {
        desc= [self replaceSpecialStringWith:self.diseaseDict[@"desc"]];
    }else if ([self.diseaseType isEqualToString:@"C"]){
        desc = [self replaceSpecialStringWith:self.diseaseDict[@"diseaseSummarize"]];
    }
    [self.diseaseDict setObject:desc forKey:@"desc"];
    //第1段 病因
    NSString * causeTitle = [self replaceSpecialStringWith:kCauseTitle];//病因标题
    NSString * diseaseCauseTitle = [self replaceSpecialStringWith:self.diseaseDict[@"diseaseCauseTitle"]];//病因描述
    NSString * diseaseCauseContent = [self replaceSpecialStringWith:self.diseaseDict[@"diseaseCauseContent"]];//病因内容
    if (diseaseCauseTitle.length == 0 && diseaseCauseContent.length == 0) {
        [self.diseaseDict setObject:@"YES" forKey:@"diseaseCauseHidden"];
    }
//    if (diseaseCauseTitle == nil || diseaseCauseTitle.length == 0) {
//        diseaseCauseTitle = @"暂无数据";
//    }
    //第2段 病症
    NSString * traitTitle = [self replaceSpecialStringWith:kTraitTitle];
    NSString * diseaseTraitTitle = [self replaceSpecialStringWith:self.diseaseDict[@"diseaseTraitTitle"]];
    NSString * diseaseTraitContent = [self replaceSpecialStringWith:self.diseaseDict[@"diseaseTraitContent"]];
    if (diseaseTraitTitle.length == 0 && diseaseTraitContent.length == 0) {
        [self.diseaseDict setObject:@"YES" forKey:@"diseaseTraitHidden"];
    }
    //第3段 易混淆疾病
    NSString *similarTitle = [self replaceSpecialStringWith:kSimilarTitle];
    NSString *similarDiseaseTitle = [self replaceSpecialStringWith:self.diseaseDict[@"similarDiseaseTitle"]];
    NSString *similarDiseaseContent = [self replaceSpecialStringWith:self.diseaseDict[@"similarDiseaseContent"]];
    if (similarDiseaseTitle.length == 0 && similarDiseaseContent.length == 0) {
        [self.diseaseDict setObject:@"YES" forKey:@"diseaseSimilarHidden"];
    }
//    if (similarDiseaseTitle == nil || similarDiseaseTitle.length == 0) {
//        similarDiseaseTitle = @"暂无数据";
//    }
    //第4段 治疗
    NSString * treatTitle = nil;
    if ([self.diseaseType isEqualToString:@"A"]) {
        treatTitle = [self replaceSpecialStringWith:kTreatTitle_A];
    }else if ([self.diseaseType isEqualToString:@"B"]){
        treatTitle = [self replaceSpecialStringWith:kTreatTitle_B];
    }
    NSString * treatRuleTitle = [self replaceSpecialStringWith:self.diseaseDict[@"treatRuleTitle"]];
    NSString * treatRuleContent = [self replaceSpecialStringWith:self.diseaseDict[@"treatRuleContent"]];
    NSArray * formulaListArr = self.diseaseDict[@"formulaList"];
    if (treatRuleTitle.length == 0 && treatRuleContent.length == 0 && formulaListArr.count == 0) {
        [self.diseaseDict setObject:@"YES" forKey:@"treatRuleHidden"];
    }
//    if (treatRuleTitle == nil || treatRuleTitle.length == 0) {
//        treatRuleTitle = @"暂无数据";
//    }
    
    //第5段 合理生活习惯
    NSString * habitTitle = [self replaceSpecialStringWith:kHabitTitle];
    NSString * goodHabitTitle  = [self replaceSpecialStringWith:self.diseaseDict[@"goodHabitTitle"]];
    NSString * goodHabitContent = [self replaceSpecialStringWith:self.diseaseDict[@"goodHabitContent"]];
    if (goodHabitTitle.length == 0 && goodHabitContent.length == 0) {
        [self.diseaseDict setObject:@"YES" forKey:@"goodHabitHidden"];
    }
//    if (goodHabitTitle == nil || goodHabitTitle.length == 0) {
//        goodHabitTitle = @"暂无数据";
//    }
    //计算高度
    //第0段 疾病
    CGSize nameSize = [self getTextViewHeightWithContent:name FontSize:titleFontSize width:APP_W-20];
    [self.diseaseDict setObject:NSStringFromCGSize(nameSize) forKey:@"nameSize"];
    CGSize descSize = [self getTextViewHeightWithContent:desc FontSize:descFontSize width:APP_W-20];
    [self.diseaseDict setObject:NSStringFromCGSize(descSize) forKey:@"descSize"];
    
    //第1段 病因
    //1)标题size
    CGSize causeTitleSize = [self getTextViewHeightWithContent:causeTitle FontSize:titleFontSize width:APP_W-20];
    [self.diseaseDict setObject:NSStringFromCGSize(causeTitleSize) forKey:@"causeTitleSize"];
    //2)子标题size
    CGSize diseaseCauseTitleSize = CGSizeZero;
    if ([self.diseaseType isEqualToString:@"A"]) {
        diseaseCauseTitleSize = [self getTextViewHeightWithContent:diseaseCauseTitle FontSize:descFontSize width:APP_W-30];
    }else if ([self.diseaseType isEqualToString:@"B"]){
        diseaseCauseTitleSize = CGSizeMake(0, 0);
    }
    [self.diseaseDict setObject:NSStringFromCGSize(diseaseCauseTitleSize) forKey:@"diseaseCauseTitleSize"];
    //3)内容size
    CGSize diseaseCauseContentSize = [self getTextViewHeightWithContent:diseaseCauseContent FontSize:descFontSize width:APP_W-20];
    [self.diseaseDict setObject:NSStringFromCGSize(diseaseCauseContentSize) forKey:@"diseaseCauseContentSize"];
    //4)rowSize
    CGSize causeRowSize = CGSizeZero;
    if ([self.diseaseType isEqualToString:@"A"]) {
        if (diseaseCauseTitle != nil && diseaseCauseTitle.length > 0) {
            causeRowSize = CGSizeMake(0, kY + diseaseCauseTitleSize.height + kH + diseaseCauseContentSize.height);
        }else{
            causeRowSize = CGSizeMake(0, kY + diseaseCauseContentSize.height);
        }
    }else if ([self.diseaseType isEqualToString:@"B"]){//B类疾病和空  都会因此黄色背景
        causeRowSize = CGSizeMake(0, kY + diseaseCauseContentSize.height);
    }
    [self.diseaseDict setObject:NSStringFromCGSize(causeRowSize) forKey:@"causeRowSize"];
    
    //第2段 病症
    //1)标题size
    CGSize traitTitleSize = [self getTextViewHeightWithContent:traitTitle FontSize:titleFontSize width:APP_W-20];
    [self.diseaseDict setObject:NSStringFromCGSize(traitTitleSize) forKey:@"traitTitleSize"];
    //2)子标题size
    CGSize diseaseTraitTitleSize = CGSizeZero;
    if ([self.diseaseType isEqualToString:@"A"]) {
        diseaseTraitTitleSize = [self getTextViewHeightWithContent:diseaseTraitTitle FontSize:descFontSize width:APP_W-30];
    }else if ([self.diseaseType isEqualToString:@"B"]){
        diseaseTraitTitleSize = CGSizeMake(0, 0);
    }
    [self.diseaseDict setObject:NSStringFromCGSize(diseaseTraitTitleSize) forKey:@"diseaseTraitTitleSize"];
    //3)内容size
    CGSize diseaseTraitContentSize = [self getTextViewHeightWithContent:diseaseTraitContent FontSize:descFontSize width:APP_W-20];
    [self.diseaseDict setObject:NSStringFromCGSize(diseaseTraitContentSize) forKey:@"diseaseTraitContentSize"];
    //4)rowSize
    CGSize traitRowSize = CGSizeZero;
    if ([self.diseaseType isEqualToString:@"A"]) {
        if (diseaseTraitTitle != 0 && diseaseTraitTitle.length > 0) {
            traitRowSize = CGSizeMake(0, kY + diseaseTraitTitleSize.height + kH + diseaseTraitContentSize.height);
        }else{
            traitRowSize = CGSizeMake(0, kY + diseaseTraitContentSize.height);
        }
    }else if ([self.diseaseType isEqualToString:@"B"]){//B类疾病和空  都会因此黄色背景
        traitRowSize = CGSizeMake(0, kY + diseaseTraitContentSize.height);
    }
    [self.diseaseDict setObject:NSStringFromCGSize(traitRowSize) forKey:@"traitRowSize"];
    
    //-----------------------------------------------------------------------------------------------------
    //第3段 易混淆疾病 -------
    CGFloat relateDiseaseRowHeight = kY;
    NSString * symptomStr = @"相同症状:";//getTextSize(symptomStr, Font(descFontSize), APP_W-20)
    CGSize similarTitleSize = [self getTextViewHeightWithContent:similarTitle FontSize:titleFontSize width:APP_W-20];
    CGSize similarDiseaseTitleSize = CGSizeZero;
    CGSize  symptomStrSize = [self getTextViewHeightWithContent:symptomStr FontSize:descFontSize width:APP_W-20];
    
    if ([self.diseaseType isEqualToString:@"A"]) {
        similarDiseaseTitleSize = [self getTextViewHeightWithContent:similarDiseaseTitle FontSize:descFontSize width:APP_W-30];
    }else if ([self.diseaseType isEqualToString:@"B"]){
        similarDiseaseTitleSize = CGSizeMake(0, 0);
    }
    
    [self.diseaseDict setObject:NSStringFromCGSize(similarTitleSize) forKey:@"similarTitleSize"];
    [self.diseaseDict setObject:NSStringFromCGSize(similarDiseaseTitleSize) forKey:@"similarDiseaseTitleSize"];
    [self.diseaseDict setObject:NSStringFromCGSize(symptomStrSize) forKey:@"symptomStrSize"];
    
    if ([kRelateBoxIsShow isEqualToString:@"YES"]) {
        if (similarDiseaseTitle != nil && similarDiseaseTitle.length > 0) {
            relateDiseaseRowHeight += similarDiseaseTitleSize.height + kB;
        }else{
            relateDiseaseRowHeight += similarDiseaseTitleSize.height;
        }
    }
    
    
    if ([self.diseaseType isEqualToString:@"A"]) {
        NSString * relateDesc = [self replaceSpecialStringWith:self.diseaseDict[@"similarDiseaseContent"]];
        
        NSArray * differentArray = [relateDesc componentsSeparatedByString:@"@"];//用"@"符号分割
        if (differentArray.count > 0) {
            NSMutableArray * tmpList = [[NSMutableArray alloc] init];
            
            for (NSString * item in differentArray) {
                NSMutableDictionary * tmpRow = [[NSMutableDictionary alloc] init];
                
                NSArray * disInfo = [item componentsSeparatedByString:@"#"];//用"#"分割
                
                CGFloat bgViewHeght = 0;
                if (disInfo.count > 0) {
                    [tmpRow setObject:[self replaceSpecialStringWith:disInfo[0]] forKey:@"relateTitle"];
                    bgViewHeght += kY;
                    CGSize relateTitleSize = [self getTextViewHeightWithContent:disInfo[0] FontSize:descFontSize width:APP_W-20];
                    bgViewHeght += kRelateButtonHeight + kB;
                    [tmpRow setObject:NSStringFromCGSize(relateTitleSize) forKey:@"relateTitleSize"];
                }
                if (disInfo.count > 1) {
                    bgViewHeght += symptomStrSize.height + kB;
                    [tmpRow setObject:[self replaceSpecialStringWith:disInfo[1]] forKey:@"relateText1"];
                    CGSize relateText1Size = [self getTextViewHeightWithContent:disInfo[1] FontSize:descFontSize width:APP_W-20];
                    bgViewHeght +=  relateText1Size.height + kB;
                    [tmpRow setObject:NSStringFromCGSize(relateText1Size) forKey:@"relateText1Size"];
                }
                if (disInfo.count > 2) {
                    bgViewHeght += symptomStrSize.height + kB;
                    [tmpRow setObject:[self replaceSpecialStringWith:disInfo[2]] forKey:@"relateText2"];
                    CGSize relateText2Size = [self getTextViewHeightWithContent:disInfo[2] FontSize:descFontSize width:APP_W-20];
                    bgViewHeght += relateText2Size.height + kB;
                    [tmpRow setObject:NSStringFromCGSize(relateText2Size) forKey:@"relateText2Size"];
                }
                CGSize bgViewSize = CGSizeMake(APP_W-20, bgViewHeght);
                
                relateDiseaseRowHeight += bgViewHeght;
                [tmpRow setObject:Font(descFontSize) forKey:@"font"];
                [tmpRow setObject:NSStringFromCGSize(bgViewSize) forKey:@"bgViewSize"];
                [tmpList addObject:tmpRow];
            }
            [self.diseaseDict setObject:tmpList forKey:@"similarDiseaseContentDict"];
            
        }
        [self.diseaseDict setObject:NSStringFromCGSize(CGSizeMake(APP_W-20, relateDiseaseRowHeight)) forKey:@"relateDiseaseRowHeight"];
    }else if ([self.diseaseType isEqualToString:@"B"]){
        NSString * similarDiseaseContent = self.diseaseDict[@"similarDiseaseContent"];
        CGSize similarDiseaseContentSize = [self getTextViewHeightWithContent:similarDiseaseContent FontSize:descFontSize width:APP_W-20];
        [self.diseaseDict setObject:NSStringFromCGSize(similarDiseaseContentSize) forKey:@"similarDiseaseContentSize"];
        relateDiseaseRowHeight += similarDiseaseContentSize.height;
        [self.diseaseDict setObject:NSStringFromCGSize(CGSizeMake(APP_W-20, relateDiseaseRowHeight)) forKey:@"relateDiseaseRowHeight"];
    }
    
    
    //-----------------------------------------------------------------------------------------------------
    
    //第4段 治疗
    //-----------------------------------------------------------------------------------------------------
    CGSize treatTitleSize = [self getTextViewHeightWithContent:treatTitle FontSize:titleFontSize width:APP_W-20];
    CGSize treatRuleTitleSize = CGSizeZero;
    if ([self.diseaseType isEqualToString:@"A"]) {
        treatRuleTitleSize = [self getTextViewHeightWithContent:treatRuleTitle FontSize:descFontSize width:APP_W-30];
        
        NSLog(@"treatRuleRowHeight========%f",treatRuleTitleSize.height);

        
    }else if ([self.diseaseType isEqualToString:@"B"]){
        treatRuleTitleSize = CGSizeMake(0, 0);
    }
    CGSize treatRuleContentSize = [self getTextViewHeightWithContent:treatRuleContent FontSize:descFontSize width:APP_W-20];
    [self.diseaseDict setObject:NSStringFromCGSize(treatTitleSize) forKey:@"treatTitleSize"];
    [self.diseaseDict setObject:NSStringFromCGSize(treatRuleTitleSize) forKey:@"treatRuleTitleSize"];
    [self.diseaseDict setObject:NSStringFromCGSize(treatRuleContentSize) forKey:@"treatRuleContentSize"];
    
    //处理数据源⌄✓✓✓✓✓✓✓✓✓
    NSMutableArray * formulaList = [NSMutableArray arrayWithArray:self.diseaseDict[@"formulaList"]];
    for (int i = 0; i < formulaList.count; i++) {
        NSMutableDictionary * formulaListDic = [NSMutableDictionary dictionaryWithDictionary:formulaList[i]];
        [formulaListDic setObject:Font(descFontSize) forKey:@"font"];
        [formulaListDic setObject:Font(titleFontSize) forKey:@"titleFont"];
        
        NSMutableArray * formulaDetailArr = [NSMutableArray arrayWithArray:formulaListDic[@"formulaDetail"] ];
        for (int j = 0; j < formulaDetailArr.count; j++) {
            NSMutableDictionary * detailDic = [NSMutableDictionary dictionaryWithDictionary:formulaDetailArr[j]];
            [detailDic setObject:[UIFont systemFontOfSize:titleFontSize] forKey:@"titleFont"];
            [formulaDetailArr replaceObjectAtIndex:j withObject:detailDic];
        }
        [formulaListDic setObject:formulaDetailArr forKey:@"formulaDetail"];
        [formulaList replaceObjectAtIndex:i withObject:formulaListDic];
    }
    [self.diseaseDict setObject:formulaList forKey:@"formulaList"];
    //处理数据源结束↑✔︎✔︎✔︎✔︎✔︎✔︎✔︎✔︎✔︎✔︎✔︎✔︎✔︎
    
    CGFloat treatRuleRowHeight = kY;
    
    treatRuleRowHeight += treatRuleTitleSize.height + kB;
    
    treatRuleRowHeight += treatRuleContentSize.height + kB;
    
    
    for (int i = 0; i< formulaList.count; i++) {
        CGFloat ruleBlockHeight = 0;
        NSMutableDictionary * formulaDetailDic = [NSMutableDictionary dictionaryWithDictionary:formulaList[i]];
        NSDictionary * ruleDic = formulaList[i];
        CGSize ruleTitleSize = [self getTextViewHeightWithContent:ruleDic[@"ruleName"] FontSize:titleFontSize width:APP_W-20];
        CGSize ruleContentSize = [self getTextViewHeightWithContent:ruleDic[@"ruleDesc"] FontSize:descFontSize width:APP_W-30];
        CGFloat buttonHeight = [CalculateButtonViewHegiht calculateButtonsHeightWith:ruleDic[@"formulaDetail"]];
        
        ruleBlockHeight = kY + ruleTitleSize.height + kB + ruleContentSize.height + kB + ruleTitleSize.height + kB + buttonHeight;
        treatRuleRowHeight += ruleBlockHeight + kB;
        CGSize ruleBlockSize = CGSizeMake(APP_W-20, ruleBlockHeight);
        [formulaDetailDic setObject:NSStringFromCGSize(ruleBlockSize) forKey:@"ruleBlockSize"];
        [formulaList replaceObjectAtIndex:i withObject:formulaDetailDic];
    }
    [self.diseaseDict setObject:formulaList forKey:@"formulaList"];
    CGSize treatRuleRowSize = CGSizeZero;
    if ([self.diseaseType isEqualToString:@"A"]) {
        treatRuleRowSize = CGSizeMake(APP_W-20, treatRuleRowHeight + kThreeButtonBgViewHeight);
    }else if ([self.diseaseType isEqualToString:@"B"]){
        treatRuleRowSize = CGSizeMake(APP_W-20, treatRuleRowHeight);
    }
    
    [self.diseaseDict setObject:NSStringFromCGSize(treatRuleRowSize) forKey:@"treatRuleRowSize"];
    
    
    
    
    
    
    
    
    
    
    
    
    //-----------------------------------------------------------------------------------------------------
    
    //第5段 合理生活习惯
    CGSize habitTitleSize = [self getTextViewHeightWithContent:habitTitle FontSize:titleFontSize width:APP_W-20];
    [self.diseaseDict setObject:NSStringFromCGSize(habitTitleSize) forKey:@"habitTitleSize"];
    CGSize goodHabitTitleSize;
    goodHabitTitleSize = [self getTextViewHeightWithContent:goodHabitTitle FontSize:descFontSize width:APP_W-30];
    [self.diseaseDict setObject:NSStringFromCGSize(goodHabitTitleSize) forKey:@"goodHabitTitleSize"];
    CGSize goodHabitContentSize = [self getTextViewHeightWithContent:goodHabitContent FontSize:descFontSize width:APP_W-20];
    [self.diseaseDict setObject:NSStringFromCGSize(goodHabitContentSize) forKey:@"goodHabitContentSize"];
    
    
    
    CGSize habitRowSize;
    if (goodHabitTitle != nil && goodHabitTitle.length == 0) {
        habitRowSize = CGSizeMake(0, kY + goodHabitTitleSize.height + kH + goodHabitContentSize.height);
    }else{
        habitRowSize = CGSizeMake(0, kY + goodHabitContentSize.height);
    }
    [self.diseaseDict setObject:NSStringFromCGSize(habitRowSize) forKey:@"habitRowSize"];
    
    //NSLog(@"综合dataSource = %@",self.diseaseDict);
    
    
    
    [self.tableView reloadData];
}

/*
 relateTitle
 relateTitleSize
 relateText1//相同症状
 relateText1Size
 relateText2//不同症状
 relateText2Size
 */

//去掉UItableview headerview黏性(sticky)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 30;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.diseaseDict.count == 0) {
        return 0;
    }
    NSLog(@"self.diseaseType======%@",self.diseaseType);
    if ([self.diseaseType isEqualToString:@"A"]) {
        return 6;
    }else if ([self.diseaseType isEqualToString:@"B"]){
        return 5;
    }else
        return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    /*
    [self.diseaseDict setObject:@"YES" forKey:@"diseaseCauseHidden"];
    [self.diseaseDict setObject:@"YES" forKey:@"diseaseTraitHidden"];
    [self.diseaseDict setObject:@"YES" forKey:@"diseaseSimilarHidden"];
    [self.diseaseDict setObject:@"YES" forKey:@"treatRuleHidden"];
    [self.diseaseDict setObject:@"YES" forKey:@"goodHabitHidden"];
     */
    NSString * hiddenStr = nil;
    switch (section) {
        case 1:
            hiddenStr = self.diseaseDict[@"diseaseCauseHidden"];
            break;
        case 2:
            hiddenStr = self.diseaseDict[@"diseaseTraitHidden"];
            break;
        case 3:
            hiddenStr = self.diseaseDict[@"diseaseSimilarHidden"];
            break;
        case 4:
            hiddenStr = self.diseaseDict[@"treatRuleHidden"];
            break;
        case 5:
            hiddenStr = self.diseaseDict[@"goodHabitHidden"];
            break;
        default:
            break;
    }
    if ([hiddenStr isEqualToString:@"YES"]) {
        return 0;
    }
    
    return kSectionHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }else{
        /*
         #define kCauseTitle     @"病因"
         #define kTraitTitle     @"病症"
         #define kSimilarTitle   @"易混淆疾病鉴别"
         #define kTreatTitle     @"治疗"
         #define kHabitTitle     @"合理生活习惯"
         
         [self.diseaseDict setObject:kCauseTitle forKey:@"causeTitle"];
         [self.diseaseDict setObject:kTraitTitle forKey:@"traitTitle"];
         [self.diseaseDict setObject:kSimilarTitle forKey:@"similarTitle"];
         [self.diseaseDict setObject:kTreatTitle forKey:@"treatTitle"];
         [self.diseaseDict setObject:kHabitTitle forKey:@"habitTitle"];
         */
        NSString * name = nil;
        NSString * subName = nil;
        NSString * hiddenStr = nil;
        switch (section) {
            case 1:
                name = kCauseTitle;
                subName = @"causeTitleSize";
                hiddenStr = self.diseaseDict[@"diseaseCauseHidden"];
                break;
            case 2:
                name = kTraitTitle;
                subName = @"traitTitleSize";
                hiddenStr = self.diseaseDict[@"diseaseTraitHidden"];
                break;
            case 3:
                name = kSimilarTitle;
                subName = @"similarTitleSize";
                hiddenStr = self.diseaseDict[@"diseaseSimilarHidden"];
                break;
            case 4:
                if ([self.diseaseType isEqualToString:@"A"]) {
                    name = kTreatTitle_A;
                }else if ([self.diseaseType isEqualToString:@"B"]){
                    name = kTreatTitle_B;
                }
                hiddenStr = self.diseaseDict[@"treatRuleHidden"];
                subName = @"treatTitleSize";
                break;
            case 5:
                name = kHabitTitle;
                subName = @"habitTitleSize";
                hiddenStr = self.diseaseDict[@"goodHabitHidden"];
                break;
            default:
                break;
        }
        CGSize titleSize = CGSizeFromString(self.diseaseDict[subName]);
        
        UIView * sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, kSectionHeight)];
        
        if ([hiddenStr isEqualToString:@"YES"]) {
            sectionHeaderView.hidden = YES;
        }
        SBTextView * titleTextView = [[SBTextView alloc] initWithFrame:CGRectMake(kX, kSectionHeight/2 - titleSize.height/2, titleSize.width, titleSize.height)];
        titleTextView.text = name;
        titleTextView.backgroundColor = [UIColor clearColor];
        titleTextView.font = Font(titleFontSize);
        [sectionHeaderView addSubview:titleTextView];
        
        //arr_down.png" : @"arr_up.png"
        UIImage * arrDownImage = [UIImage imageNamed:@"arr_down.png"];
        UIImage * arrUpImage = [UIImage imageNamed:@"arr_up.png"];
        CGSize arrSize = arrUpImage.size;
        UIImageView * arrImageView = [[UIImageView alloc] initWithFrame:CGRectMake(APP_W-15-arrSize.width, sectionHeaderView.FH/2 - arrSize.height/2, arrSize.width, arrSize.height)];
        
        
        //控制展开和收缩
        NSString * expendYES = @"1";
        NSString * expendNO = @"2";
        
        NSString * expendStatus = nil;
        switch (section) {
            case 1:
                expendStatus = self.diseaseDict[@"causeExpend"];
                break;
            case 2:
                expendStatus = self.diseaseDict[@"traitExpend"];
                break;
            case 3:
                expendStatus = self.diseaseDict[@"similarExpend"];
                break;
            case 4:
                expendStatus = self.diseaseDict[@"treatExpend"];
                break;
            case 5:
                expendStatus = self.diseaseDict[@"habitExpend"];
                break;
            default:
                break;
        }
        
        if ([expendStatus isEqualToString:expendYES]) {
            arrImageView.image = arrUpImage;
        }else if ([expendStatus isEqualToString:expendNO]){
            arrImageView.image = arrDownImage;
        }
        [sectionHeaderView addSubview:arrImageView];
        /*
         #define kCauseTitle     @"病因"
         #define kTraitTitle     @"病症"
         #define kSimilarTitle   @"易混淆疾病"
         #define kTreatTitle     @"治疗"
         #define kHabitTitle     @"合理生活习惯"
         */
        
        
        CusTapGestureRecognizer * tap = [[CusTapGestureRecognizer alloc] init];
        tap.section = section;
        [tap addTarget:self action:@selector(sectionExpandClick:)];
        [sectionHeaderView addGestureRecognizer:tap];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(titleTextView.frame.origin.x, sectionHeaderView.frame.size.height - 0.5, APP_W, 0.5)];
        line.backgroundColor = UIColorFromRGB(0xdbdbdb);
        [sectionHeaderView addSubview:line];
        sectionHeaderView.backgroundColor = [UIColor whiteColor];
        
//        if([self.controllerName isEqualToString:@"wikiViewController"]){
//            return nil;
//        }
        return sectionHeaderView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NSString * hiddenStr = nil;
    switch (section) {
        case 1:
            hiddenStr = self.diseaseDict[@"diseaseCauseHidden"];
            break;
        case 2:
            hiddenStr = self.diseaseDict[@"diseaseTraitHidden"];
            break;
        case 3:
            hiddenStr = self.diseaseDict[@"diseaseSimilarHidden"];
            break;
        case 4:
            hiddenStr = self.diseaseDict[@"treatRuleHidden"];
            break;
        case 5:
            hiddenStr = self.diseaseDict[@"goodHabitHidden"];
            break;
        default:
            break;
    }
    if ([hiddenStr isEqualToString:@"YES"]) {
        return 0;
    }
//    if([self.controllerName isEqualToString:@"wikiViewController"]){
//        return 0;
//    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
//    if([self.controllerName isEqualToString:@"wikiViewController"]){
//        return nil;
//    }
    UIView * v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 10)];
    v.backgroundColor = UIColorFromRGB(0xecf0f1);
    v.layer.masksToBounds = YES;
    v.layer.borderWidth = 0.5;
    v.layer.borderColor = UIColorFromRGB(0xdbdbdb).CGColor;
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    //控制展开和收缩
    NSString * expendYES = @"1";
    NSString * expendNO = @"2";
    
    NSString * expendStatus = nil;
    
    if (indexPath.section == 0) {
        CGSize nameSize = CGSizeFromString(self.diseaseDict[@"nameSize"]);
        CGSize descSize = CGSizeFromString(self.diseaseDict[@"descSize"]);
        
        return kY + nameSize.height + kH + descSize.height + kB;
        
    }else if (indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 5){
        /*
         @"causeRowSize"
         @"traitRowSize"
         @"habitRowSize"
         
         
         [self.diseaseDict setObject:@"YES" forKey:@"diseaseCauseHidden"];
         [self.diseaseDict setObject:@"YES" forKey:@"diseaseTraitHidden"];
         [self.diseaseDict setObject:@"YES" forKey:@"diseaseSimilarHidden"];
         [self.diseaseDict setObject:@"YES" forKey:@"treatRuleHidden"];
         [self.diseaseDict setObject:@"YES" forKey:@"goodHabitHidden"];
         
         
         */
        NSString * size = nil;
        NSString * hiddenStr = nil;
        switch (indexPath.section) {
            case 1:
                size = @"causeRowSize";
                hiddenStr = self.diseaseDict[@"diseaseCauseHidden"];
                expendStatus = self.diseaseDict[@"causeExpend"];
                break;
            case 2:
                size = @"traitRowSize";
                hiddenStr = self.diseaseDict[@"diseaseTraitHidden"];
                expendStatus = self.diseaseDict[@"traitExpend"];
                break;
            case 5:
                size = @"habitRowSize";
                hiddenStr = self.diseaseDict[@"goodHabitHidden"];
                expendStatus = self.diseaseDict[@"habitExpend"];
                break;
            default:
                break;//
        }
        CGFloat rowHeight = 0;
        if ([hiddenStr isEqualToString:@"YES"]) {
            return rowHeight;
        }
        if ([expendStatus isEqualToString:expendYES]) {
            rowHeight = CGSizeFromString(self.diseaseDict[size]).height + kEBu;
            
            if (indexPath.section == 5) {
                rowHeight += 45;
            }
            
            
        }else if ([expendStatus isEqualToString:expendNO]){
            rowHeight = 0;
        }
        return rowHeight;
        
    }else if (indexPath.section == 3){//易混淆疾病鉴别
        CGFloat rowHeght = 0;
        NSString * hiddenStr = self.diseaseDict[@"diseaseSimilarHidden"];
        if ([hiddenStr isEqualToString:@"YES"]) {
            return rowHeght;
        }
        expendStatus = self.diseaseDict[@"similarExpend"];
        if ([expendStatus isEqualToString:expendYES]) {
            rowHeght = CGSizeFromString(self.diseaseDict[@"relateDiseaseRowHeight"]).height;
            
            NSString *similarDiseaseContent = [self replaceSpecialStringWith:self.diseaseDict[@"similarDiseaseContent"]];
//            if (similarDiseaseContent && [similarDiseaseContent rangeOfString:@"#"].location == NSNotFound) {
//                
//                CGSize relateDiseaseSize = CGSizeFromString(self.diseaseDict[@"similarDiseaseContentSize"]);
//                rowHeght = relateDiseaseSize.height;
//            }
            
            if ([self.diseaseType isEqualToString:@"B"]) {
                CGSize relateDiseaseSize = CGSizeFromString(self.diseaseDict[@"similarDiseaseContentSize"]);
                rowHeght = relateDiseaseSize.height + 15;
            }
            
        }else if ([expendStatus isEqualToString:expendNO]){
            rowHeght = 0;
        }
        return rowHeght;
    }else if (indexPath.section == 4){//治疗原则
        CGFloat rowHeght = 0;
        NSString *hiddenStr = self.diseaseDict[@"treatRuleHidden"];
        if ([hiddenStr isEqualToString:@"YES"]) {
            return rowHeght;
        }
        expendStatus = self.diseaseDict[@"treatExpend"];
        if ([expendStatus isEqualToString:expendYES]) {
            rowHeght = CGSizeFromString(self.diseaseDict[@"treatRuleRowSize"]).height;
            NSString *treatRuleTitle = [self replaceSpecialStringWith:self.diseaseDict[@"treatRuleTitle"]];
            if (treatRuleTitle == nil || treatRuleTitle.length == 0 ) {
                rowHeght -= 20;
            }
            
        }else if ([expendStatus isEqualToString:expendNO]){
            rowHeght = 0;
        }
        return rowHeght;
    }
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)//疾病简介
    {
        if (self.DescCell) {
            [self.DescCell removeFromSuperview];
        }
        CGSize nameSize = CGSizeFromString(self.diseaseDict[@"nameSize"]);
        CGSize descSize = CGSizeFromString(self.diseaseDict[@"descSize"]);
        [self.diseaseTitleTextView setFrame:CGRectMake(kX, kY, nameSize.width + 10, nameSize.height + 3)];
        [self.diseaseDescTextView setFrame:CGRectMake(kX, self.diseaseTitleTextView.FY + self.diseaseTitleTextView.FH + kH, descSize.width, descSize.height)];
        self.diseaseTitleTextView.font = [UIFont boldSystemFontOfSize:titleFontSize];
        self.diseaseTitleTextView.text = [self replaceSpecialStringWith:self.diseaseDict[@"name"]];
        self.diseaseDescTextView.text = [self replaceSpecialStringWith:self.diseaseDict[@"desc"]];
        self.diseaseDescTextView.font = Font(descFontSize);
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
//        paragraphStyle.lineHeightMultiple = 20.0f;
//        paragraphStyle.maximumLineHeight = 19.0f;
//        paragraphStyle.minimumLineHeight = 19.0f;
//        paragraphStyle.alignment = NSTextAlignmentJustified;
//        
//        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:descFontSize], NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:UIColorFromRGB(0x333333)};
//        
//        self.diseaseDescTextView.userInteractionEnabled = YES;
//        if ([self.diseaseType isEqualToString:@"A"] || [self.diseaseType isEqualToString:@"B"]) {
//            
//            self.diseaseDescTextView.attributedText = [[NSAttributedString alloc] initWithString:[self replaceSpecialStringWith:self.diseaseDict[@"desc"]] attributes:attributes];
//            
//        }else if ([self.diseaseType isEqualToString:@"C"]){
//            self.diseaseDescTextView.attributedText = [[NSAttributedString alloc] initWithString:[self replaceSpecialStringWith:self.diseaseDict[@"diseaseSummarize"]] attributes:attributes];
//        }
        self.DescCell.selectionStyle = UITableViewCellSelectionStyleNone;
     
        return self.DescCell;
    }else if (indexPath.section == 1)//病因
    {
        if (self.DiseasCauseeCell) {
            [self.DiseasCauseeCell removeFromSuperview];
        }
        CGSize subTitleSize = CGSizeFromString(self.diseaseDict[@"diseaseCauseTitleSize"]);
        CGSize contentSize = CGSizeFromString(self.diseaseDict[@"diseaseCauseContentSize"]);
        NSString * diseaseCauseTitle = [self replaceSpecialStringWith:self.diseaseDict[@"diseaseCauseTitle"]];//病因描述
        CGFloat cause_y = kY;
        if ([self.diseaseType isEqualToString:@"A"]) {
            if (diseaseCauseTitle == nil || diseaseCauseTitle.length == 0) {
                [self.causebgView setFrame:CGRectMake(kX, 0, APP_W-20, 0)];
            }else{
                [self.causebgView setFrame:CGRectMake(kX, cause_y - 5, APP_W-20, subTitleSize.height + kB)];
                cause_y += subTitleSize.height + kB;
            }
        }else if ([self.diseaseType isEqualToString:@"B"]){
            [self.causebgView setFrame:CGRectMake(kX, kY - 5, APP_W-20, 0)];
        }
        [self.causebgView setBackgroundColor:kBoxBackgroundColor];
        self.causebgView.layer.borderColor = kBoxBorderColor;
        self.causebgView.layer.borderWidth = kBoxBorderWidth;
        [self.causeTitleTextView setFrame:CGRectMake(kX - 5, 5, subTitleSize.width, subTitleSize.height)];
        [self.causeContentTextView setFrame:CGRectMake(kX, cause_y, contentSize.width, contentSize.height)];
        self.causeTitleTextView.font = Font(descFontSize);
        self.causeContentTextView.font = Font(descFontSize);
//        if (diseaseCauseTitle == nil || diseaseCauseTitle.length == 0) {
//            diseaseCauseTitle = @"暂无数据";
//        }
        self.causeTitleTextView.text = diseaseCauseTitle;
        self.causeContentTextView.text = [self replaceSpecialStringWith:self.diseaseDict[@"diseaseCauseContent"]];
        
        self.DiseasCauseeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return self.DiseasCauseeCell;
    }else if (indexPath.section == 2)//症状特点
    {
        /*
         diseaseTraitTitleSize
         diseaseTraitContentSize
         
         [@"diseaseTraitTitle"]];
         [@"diseaseTraitContent"]];
         */
        if (self.DiseasFeatureCell) {
            [self.DiseasFeatureCell removeFromSuperview];
        }
        CGSize subTitleSize = CGSizeFromString(self.diseaseDict[@"diseaseTraitTitleSize"]);
        CGSize contentSize = CGSizeFromString(self.diseaseDict[@"diseaseTraitContentSize"]);
        NSString *diseaseTraitTitle = [self replaceSpecialStringWith:self.diseaseDict[@"diseaseTraitTitle"]];
        CGFloat trait_y = kY;
        if ([self.diseaseType isEqualToString:@"A"]) {
            if (diseaseTraitTitle == nil || diseaseTraitTitle.length == 0) {
                [self.traitbgView setFrame:CGRectMake(kX, 0, APP_W-20, 0)];
            }else{
                [self.traitbgView setFrame:CGRectMake(kX, trait_y - 5, APP_W-20, subTitleSize.height + kB)];
                trait_y += subTitleSize.height + kB;
            }
        }else if ([self.diseaseType isEqualToString:@"B"]){
            [self.traitbgView setFrame:CGRectMake(kX, kY - 5, APP_W-20, 0)];
        }
        
        [self.traitbgView setBackgroundColor:kBoxBackgroundColor];
        self.traitbgView.layer.borderColor = kBoxBorderColor;
        self.traitbgView.layer.borderWidth = kBoxBorderWidth;
        
        [self.traitTitleTextView setFrame:CGRectMake(kX - 5, 5, subTitleSize.width, subTitleSize.height)];
        [self.traitContentTextView setFrame:CGRectMake(kX, trait_y, contentSize.width, contentSize.height)];
        self.traitTitleTextView.font = Font(descFontSize);
        self.traitContentTextView.font = Font(descFontSize);
        
//        if (diseaseTraitTitle == nil || diseaseTraitTitle.length == 0) {
//            diseaseTraitTitle = @"暂无数据";
//        }
        self.traitTitleTextView.text = diseaseTraitTitle;
        self.traitContentTextView.text = [self replaceSpecialStringWith:self.diseaseDict[@"diseaseTraitContent"]];
        
        self.DiseasFeatureCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return self.DiseasFeatureCell;
    }else if (indexPath.section == 3)//易混淆疾病
    {
        static NSString * cellIdentifier = @"relateDiseaseCellIdentifier";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        NSArray * relateContentArray = self.diseaseDict[@"similarDiseaseContentDict"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //黄色背景盒子
            
            NSString * isShow = kRelateBoxIsShow;
            if ([self.diseaseType isEqualToString:@"A"]) {
                isShow = @"YES";
            }else if ([self.diseaseType isEqualToString:@"B"]){
                isShow = @"NO";
            }
            
            if ([isShow isEqualToString:@"YES"]) {
                UIView * relateBoxView = [[UIView alloc] init];
                relateBoxView.tag = kRelateBoxTag;
                [relateBoxView setBackgroundColor:kBoxBackgroundColor];
                relateBoxView.layer.borderColor = kBoxBorderColor;
                relateBoxView.layer.borderWidth = kBoxBorderWidth;
                [cell.contentView addSubview:relateBoxView];
                
                SBTextView * t = [[SBTextView alloc] init];
                t.tag = 3001;
                t.backgroundColor = [UIColor clearColor];
                [relateBoxView addSubview:t];
                
            }
            
            if ([self.diseaseType isEqualToString:@"A"]) {
                //按钮
                for (int i = 0; i<relateContentArray.count; i++) {
                    relateBgView * relateBgV = [[relateBgView alloc] init];
                    relateBgV.delegate = self;
                    relateBgV.tag = kRelateBgViewTag + i;
                    [cell.contentView addSubview:relateBgV];
                }
            }else if ([self.diseaseType isEqualToString:@"B"]){
                SBTextView * relateDiseaseLabel = [[SBTextView alloc] init];
                relateDiseaseLabel.tag = kRelateDiseaseLabelTag;
                [cell.contentView addSubview:relateDiseaseLabel];
            }
            
        }
        //NSArray * viewArray = cell.contentView.subviews;
        CGFloat bg_y = 0;
        
        NSString * isShow = kRelateBoxIsShow;
        if ([self.diseaseType isEqualToString:@"A"]) {
            isShow = @"YES";
        }else if ([self.diseaseType isEqualToString:@"B"]){
            isShow = @"NO";
        }
        
        
        if ([isShow isEqualToString:@"YES"]) {
            CGSize boxSize = CGSizeFromString(self.diseaseDict[@"similarDiseaseTitleSize"]);
            UIView * boxView = (UIView *)[cell.contentView viewWithTag:kRelateBoxTag];
            
            NSString *similarDiseaseTitle = [self replaceSpecialStringWith:self.diseaseDict[@"similarDiseaseTitle"]];
            if (similarDiseaseTitle != nil && similarDiseaseTitle.length > 0) {
                [boxView setFrame:CGRectMake(kX, kY - 5, APP_W-20, boxSize.height + kB)];
                bg_y += boxSize.height + kY + kB;
            }else{
                [boxView setFrame:CGRectMake(kX, 0, APP_W-20, 0)];
                bg_y += boxSize.height + kY;
            }
            
            SBTextView * t = (SBTextView *)[boxView viewWithTag:3001];
            [t setFrame:CGRectMake(kX - 5, 5, boxSize.width, boxSize.height)];
            t.text = similarDiseaseTitle;
            t.font = Font(descFontSize);
            
        }
        
        if ([self.diseaseType isEqualToString:@"A"]) {
            for (int i = 0; i < relateContentArray.count; i++) {
                CGSize size = CGSizeFromString(relateContentArray[i][@"bgViewSize"]);
                relateBgView * bgView = (relateBgView *)[cell.contentView viewWithTag:kRelateBgViewTag + i];
                [bgView setFrame:CGRectMake(kX, bg_y, APP_W-20, size.height)];
                bgView.infoDict = relateContentArray[i];
                bg_y += size.height;
                
                NSString *similarDiseaseContent = [self replaceSpecialStringWith:self.diseaseDict[@"similarDiseaseContent"]];
//                if (similarDiseaseContent && [similarDiseaseContent rangeOfString:@"#"].location == NSNotFound) {
//                    bgView.hidden = YES;
//                }
            }
        }else if ([self.diseaseType isEqualToString:@"B"]){
            SBTextView * relateDiseaseLabel = (SBTextView *)[cell.contentView viewWithTag:kRelateDiseaseLabelTag];
            
            relateDiseaseLabel.text = [self replaceSpecialStringWith:self.diseaseDict[@"similarDiseaseContent"]];
            relateDiseaseLabel.font = Font(descFontSize);
            CGSize relateDiseaseSize = CGSizeFromString(self.diseaseDict[@"similarDiseaseContentSize"]);
            [relateDiseaseLabel setFrame:CGRectMake(kX, kY, APP_W-20, relateDiseaseSize.height)];
            
//            NSString *similarDiseaseContent = [self replaceSpecialStringWith:self.diseaseDict[@"similarDiseaseContent"]];
//            if (similarDiseaseContent && ![similarDiseaseContent containsString:@"#"]) {
//                relateDiseaseLabel.hidden = YES;
//            }
            
        }
        return cell;
    }else if (indexPath.section == 4){//治疗原则
        static NSString * cellIdentifier = @"treatDiseaseCellIdentifier";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        NSArray * formulaList = self.diseaseDict[@"formulaList"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIView * relateBoxView = [[UIView alloc] init];
            relateBoxView.tag = kTreatRuleBoxTag;
            [relateBoxView setBackgroundColor:kBoxBackgroundColor];
            relateBoxView.layer.borderColor = kBoxBorderColor;
            relateBoxView.layer.borderWidth = kBoxBorderWidth;
            [cell.contentView addSubview:relateBoxView];
            
            NSString *treatRuleTitle = [self replaceSpecialStringWith:self.diseaseDict[@"treatRuleTitle"]];
            if (treatRuleTitle == nil || treatRuleTitle.length == 0 ) {
                relateBoxView.hidden = YES;
            }
            
            SBTextView * titleText = [[SBTextView alloc] init];
            titleText.tag = kTreatRuleTitleTag;
            titleText.backgroundColor = [UIColor clearColor];
            [relateBoxView addSubview:titleText];
            
            
            SBTextView * contentText = [[SBTextView alloc] init];
            contentText.tag = kTreatRuleContentTag;
            contentText.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:contentText];
            
            for (int i = 0; i < formulaList.count; i++) {
                treatRuleBgView * bgView = [[treatRuleBgView alloc] initWithArr:formulaList[i]];
                bgView.delegate = self;
                bgView.tag = kTreatRuleButtonBgView + i;
                [cell.contentView addSubview:bgView];
            }
            
            for (int i = 0; i < 3; i++) {
                DisesaeDetailInfoButton * threeButton = [DisesaeDetailInfoButton buttonWithType:UIButtonTypeCustom];
                threeButton.tag = kThreeButtonTag + i;
                threeButton.layer.borderWidth = 0.5;
                threeButton.layer.masksToBounds = YES;
                threeButton.layer.cornerRadius = 3;
                threeButton.layer.borderColor = GREENTCOLOR.CGColor;
                [threeButton addTarget:self action:@selector(threeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:threeButton];
            }
            
        }
        CGFloat rule_y = kY - 5;
        CGSize treatRuleTitleSize = CGSizeFromString(self.diseaseDict[@"treatRuleTitleSize"]);

        UIView * treatRuleBoxView = (UIView *)[cell.contentView viewWithTag:kTreatRuleBoxTag];
        if ([self.diseaseType isEqualToString:@"A"]) {
            
            [treatRuleBoxView setFrame:CGRectMake(kX, rule_y, APP_W-20, treatRuleTitleSize.height + kB)];
            NSString *treatRuleTitle = [self replaceSpecialStringWith:self.diseaseDict[@"treatRuleTitle"]];
            if (treatRuleTitle == nil || treatRuleTitle.length == 0 ) {
                rule_y += 0;
            }else
            {
                rule_y += treatRuleTitleSize.height + kB;
                rule_y += kB;
            }
            
            
        }else if ([self.diseaseType isEqualToString:@"B"]){
            [treatRuleBoxView setFrame:CGRectMake(kX, rule_y, APP_W-20, 0)];
        }
        
        SBTextView * titleText = (SBTextView *)[treatRuleBoxView viewWithTag:kTreatRuleTitleTag];
        [titleText setFrame:CGRectMake(kX - 5, 5, treatRuleTitleSize.width, treatRuleTitleSize.height)];
        NSString *treatRuleTitle = [self replaceSpecialStringWith:self.diseaseDict[@"treatRuleTitle"]];
//        if (treatRuleTitle == nil || treatRuleTitle.length == 0 ) {
//            
//        }
        titleText.text = treatRuleTitle;
        titleText.font = Font(descFontSize);
        
        CGSize treatRuleContentSize = CGSizeFromString(self.diseaseDict[@"treatRuleContentSize"]);
        SBTextView * contentText = (SBTextView *)[cell.contentView viewWithTag:kTreatRuleContentTag];
        [contentText setFrame:CGRectMake(kX, rule_y, APP_W-20, treatRuleContentSize.height)];
        contentText.text = [self replaceSpecialStringWith:self.diseaseDict[@"treatRuleContent"]];
        contentText.font = Font(descFontSize);
        
        rule_y += treatRuleContentSize.height + kB;
        
        for (int i = 0; i < formulaList.count; i++) {
            NSDictionary * dic = formulaList[i];
            CGSize ruleBlockSize = CGSizeFromString(dic[@"ruleBlockSize"]);
            treatRuleBgView * bgView = (treatRuleBgView *)[cell.contentView viewWithTag:kTreatRuleButtonBgView + i];
            [bgView setFrame:CGRectMake(0, rule_y, APP_W, ruleBlockSize.height)];
            bgView.infoDict = dic;
            rule_y += ruleBlockSize.height + kB;
        }
        if ([self.diseaseType isEqualToString:@"A"]) {
            rule_y += kY-5;
            CGFloat buttonWidth = (APP_W-20 -20)/3;
            for (int j = 0; j < 3; j++) {
                DisesaeDetailInfoButton * button = (DisesaeDetailInfoButton *)[cell.contentView viewWithTag:kThreeButtonTag + j];
                NSInteger buttonTag = button.tag;
                NSString * buttonName = nil;
                switch (buttonTag) {
                    case kThreeButtonTag:
                        [button setFrame:CGRectMake(kX, rule_y, buttonWidth, kRelateButtonHeight)];
                        buttonName = @"治疗用药";
                        break;
                    case kThreeButtonTag+1:
                        [button setFrame:CGRectMake(kX + buttonWidth + kH, rule_y, buttonWidth, kRelateButtonHeight)];
                        buttonName = @"健康食品";
                        break;
                    case kThreeButtonTag+2:
                        [button setFrame:CGRectMake(kX + (buttonWidth + kH)*2, rule_y, buttonWidth, kRelateButtonHeight)];
                        buttonName = @"医疗用品";
                        break;
                    default:
                        break;
                }
                button.buttonName = buttonName;
                button.titleLabel.font = Font(titleFontSize);
                [button setTitleColor:GREENTCOLOR forState:UIControlStateNormal];
                [button setTitle:buttonName forState:UIControlStateNormal];
            }
        }
        
        
        
        return cell;
    }else if (indexPath.section == 5){//合理生活习惯
        
        /*
         [@"goodHabitTitle"]];
         [@"goodHabitContent"]];
         @"goodHabitTitleSize"];
         @"goodHabitContentSize"];
         */
        if (self.LifeHabitsCell) {
            [self.LifeHabitsCell removeFromSuperview];
        }
        CGSize subTitleSize = CGSizeFromString(self.diseaseDict[@"goodHabitTitleSize"]);
        CGSize contentSize = CGSizeFromString(self.diseaseDict[@"goodHabitContentSize"]);
        NSString *goodHabitTitle  = [self replaceSpecialStringWith:self.diseaseDict[@"goodHabitTitle"]];
        if (goodHabitTitle == nil || goodHabitTitle.length == 0) {
            [self.habitbgView setFrame:CGRectMake(kX, 0, APP_W-20, 0)];
        }else{
            [self.habitbgView setFrame:CGRectMake(kX, kY - 5, APP_W-20, subTitleSize.height + kB)];
        }
        [self.habitbgView setBackgroundColor:kBoxBackgroundColor];
        self.habitbgView.layer.borderColor = kBoxBorderColor;
        self.habitbgView.layer.borderWidth = kBoxBorderWidth;
        
        [self.habitTitleTextView setFrame:CGRectMake(kX - 5, 5, subTitleSize.width, subTitleSize.height)];
        [self.habitContentTextView setFrame:CGRectMake(kX, self.habitbgView.FY + self.habitbgView.FH + kB, contentSize.width, contentSize.height)];
        self.habitTitleTextView.font = Font(descFontSize);
        self.habitContentTextView.font = Font(descFontSize);
        
        self.habitTitleTextView.text = goodHabitTitle;
        self.habitContentTextView.text = [self replaceSpecialStringWith:self.diseaseDict[@"goodHabitContent"]];
        
        
        self.LifeHabitsCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return self.LifeHabitsCell;
    }
    return nil;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    //控制展开和收缩
    NSString * expendYES = @"1";
    NSString * expendNO = @"2";
    
    NSString * expendStatus = nil;
    switch (section) {
        case 1:
            expendStatus = self.diseaseDict[@"causeExpend"];
            if ([expendStatus isEqualToString:expendYES]) {
                return 1;
            }else if ([expendStatus isEqualToString:expendNO]){
                return 0;
            }
            break;
        case 2:
            expendStatus = self.diseaseDict[@"traitExpend"];
            if ([expendStatus isEqualToString:expendYES]) {
                return 1;
            }else if ([expendStatus isEqualToString:expendNO]){
                return 0;
            }
            break;
        case 3:
            expendStatus = self.diseaseDict[@"similarExpend"];
            if ([expendStatus isEqualToString:expendYES]) {
                return 1;
            }else if ([expendStatus isEqualToString:expendNO]){
                return 0;
            }
            break;
        case 4:
            expendStatus = self.diseaseDict[@"treatExpend"];
            if ([expendStatus isEqualToString:expendYES]) {
                return 1;
            }else if ([expendStatus isEqualToString:expendNO]){
                return 0;
            }
            break;
        case 5:
            expendStatus = self.diseaseDict[@"habitExpend"];
            if ([expendStatus isEqualToString:expendYES]) {
                return 1;
            }else if ([expendStatus isEqualToString:expendNO]){
                return 0;
            }
            break;
        default:
            break;
    }
    
    
    return 1;
}

#pragma mark -------设置RightBarButton---------
- (void)setRightBarButton{
    UIImage * collectImage = [UIImage imageNamed:@"右上角更多.png"];
    CGSize size = [@"Aa" sizeWithFont:[UIFont systemFontOfSize:19.0f]];
    UIButton * zoomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [zoomButton setFrame:CGRectMake(10, -5, size.width+20, collectImage.size.height+10)];
    [zoomButton addTarget:self action:@selector(zoomButtonClick) forControlEvents:UIControlEventTouchUpInside];
    zoomButton.titleLabel.font = [UIFont systemFontOfSize:19.0f];
    zoomButton.titleLabel.textColor = [UIColor whiteColor];
    [zoomButton setTitle:@"Aa" forState:UIControlStateNormal];
    
    UIButton * collectButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [collectButton setFrame:CGRectMake(zoomButton.frame.origin.x + zoomButton.frame.size.width-8, 0, collectImage.size.width, collectImage.size.height)];
    [collectButton addTarget:self action:@selector(returnIndex) forControlEvents:UIControlEventTouchUpInside];
    [collectButton setBackgroundImage:collectImage forState:UIControlStateNormal];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] init];
    buttonImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, -1, collectImage.size.width, collectImage.size.height)];
    [buttonImage addGestureRecognizer:tap];
    [tap addTarget:self action:@selector(returnIndex)];
    buttonImage.image = collectImage;
    buttonImage.userInteractionEnabled = YES;
    //[collectButton addSubview:buttonImage];
    
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, collectButton.frame.origin.x + collectButton.frame.size.width, collectImage.size.height)];
    bgView.userInteractionEnabled = YES;
    [bgView addSubview:zoomButton];
    [bgView addSubview:collectButton];
    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -12;
    self.navigationItem.rightBarButtonItems = @[fixed,[[UIBarButtonItem alloc] initWithCustomView:bgView]];

}

#pragma mark---------------------------------------------跳转到首页-----------------------------------------------

//- (void)setUpRightItem
//{
//    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    fixed.width = -12;
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"右上角更多.png"] style:UIBarButtonItemStylePlain target:self action:@selector(returnIndex)];
//    self.navigationItem.rightBarButtonItems = @[fixed,rightItem];
//}
- (void)returnIndex
{
    self.indexView = [ReturnIndexView sharedManagerWithImage:@[@"icon home.PNG",self.collectButtonImageName] title:@[@"首页",@"收藏"]];
    self.indexView.delegate = self;
    [self.indexView show];
}
- (void)RetunIndexView:(ReturnIndexView *)ReturnIndexView didSelectedIndex:(NSIndexPath *)indexPath
{
    [self.indexView hide];
    if (indexPath.row == 0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self performSelector:@selector(delayPopToHome) withObject:nil afterDelay:0.01];
    }else if (indexPath.row == 1){
        [self collectButtonClick];
    }
    
}
- (void)delayPopToHome
{
    [app.tabBarController setSelectedIndex:0];
}
#pragma mark---------------------------------------------跳转到首页-----------------------------------------------




#pragma mark -------收藏---------
- (void)collectButtonClick{
    if (!app.logStatus) {
        LoginViewController * login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        login.isPresentType = YES;
        login.parentNavgationController = self.navigationController;
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:login];
        [self presentViewController:nav animated:YES completion:nil];
        return;
    }
    NSMutableDictionary * setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"objId"] = self.diseaseDict[@"diseaseId"];
    setting[@"objType"] = @"3";
    setting[@"method"] = @"1";
    
    [[HTTPRequestManager sharedInstance] favoriteCollect:setting completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            if ([resultObj[@"body"][@"result"] isEqualToString:@"1"]) {//已收藏
                ///////////////////////////若已收藏,则取消收藏////////////////////////////
                setting[@"method"] = @"3";
                [[HTTPRequestManager sharedInstance] favoriteCollect:setting completion:^(id resultObj) {
                    if ([resultObj[@"body"][@"result"] isEqualToString:@"3"]) {
                        [SVProgressHUD showSuccessWithStatus:@"取消收藏成功" duration:DURATION_SHORT];
                        buttonImage.image = [UIImage imageNamed:@"导航栏_收藏icon.png"];
                        self.collectButtonImageName = @"导航栏_收藏icon.png";
                    }
                } failure:^(NSError *error) {
                    NSLog(@"%@",error);
                }];
            }else if([resultObj[@"body"][@"result"] isEqualToString:@"0"]){//未收藏
                //////////////////////////若为收藏,则添加收藏/////////////////////////
                setting[@"method"] = @"2";
                [[HTTPRequestManager sharedInstance] favoriteCollect:setting completion:^(id resultObj) {
                    if ([resultObj[@"body"][@"result"] isEqualToString:@"2"]) {
                        [SVProgressHUD showSuccessWithStatus:@"添加收藏成功" duration:DURATION_SHORT];
                        buttonImage.image = [UIImage imageNamed:@"导航栏_已收藏icon.png"];
                        self.collectButtonImageName = @"导航栏_已收藏icon.png";
                    }
                } failure:^(NSError *error) {
                    NSLog(@"%@",error);
                }];
                
            }
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
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
}

// opType: 1 查询; 2 写入; 3 取消;
- (void)checkIsCollectOrNot
{
    if (app.logStatus) {
        //buttonImage.image = [UIImage imageNamed:@"导航栏_已收藏icon.png"];
        NSMutableDictionary * setting = [NSMutableDictionary dictionary];
        setting[@"token"] = app.configureList[APP_USER_TOKEN];
        setting[@"objId"] = self.diseaseDict[@"diseaseId"];
        setting[@"objType"] = @"3";
        setting[@"method"] = @"1";
        [[HTTPRequestManager sharedInstance] favoriteCollect:setting completion:^(id resultObj) {
            
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                if ([resultObj[@"body"][@"result"] isEqualToString:@"1"]) {
                    buttonImage.image = [UIImage imageNamed:@"导航栏_已收藏icon.png"];
                    self.collectButtonImageName = @"导航栏_已收藏icon.png";
                }else if([resultObj[@"body"][@"result"] isEqualToString:@"0"]){
                    buttonImage.image = [UIImage imageNamed:@"导航栏_收藏icon.png"];
                    self.collectButtonImageName = @"导航栏_收藏icon.png";
                }
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
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
        }];
    }else{
        buttonImage.image = [UIImage imageNamed:@"导航栏_收藏icon.png"];
        self.collectButtonImageName = @"导航栏_收藏icon.png";
    }
}

#pragma mark -------去登陆---------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 999) {
        if (buttonIndex == 0) {
            LoginViewController * login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            login.isPresentType = YES;
            login.parentNavgationController = self.navigationController;
            UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:login];
            [self presentViewController:nav animated:YES completion:nil];
        }
    }
}


#pragma mark -------放大缩小字体---------
- (void)zoomButtonClick{
    if (descFontSize == 18) {
        isUp = NO;
    }else if(descFontSize == 12){
        isUp = YES;
    }
    
    if (isUp) {
        descFontSize+=3;
        titleFontSize+=3;
    }else{
        descFontSize = kDescFontSize;//12
        titleFontSize = kTitleFontSize;//14
    }
    [self coverData];
}

- (void)sectionExpandClick:(CusTapGestureRecognizer *)tap
{
    //控制展开和收缩
    NSString * expendYES = @"1";
    NSString * expendNO = @"2";
    
    NSString * expendStatus = nil;
    NSString * sectionName = nil;
    switch (tap.section) {
        case 1:
            expendStatus = self.diseaseDict[@"causeExpend"];
            sectionName = @"causeExpend";
            break;
        case 2:
            expendStatus = self.diseaseDict[@"traitExpend"];
            sectionName = @"traitExpend";
            break;
        case 3:
            expendStatus = self.diseaseDict[@"similarExpend"];
            sectionName = @"similarExpend";
            break;
        case 4:
            expendStatus = self.diseaseDict[@"treatExpend"];
            sectionName = @"treatExpend";
            break;
        case 5:
            expendStatus = self.diseaseDict[@"habitExpend"];
            sectionName = @"habitExpend";
            break;
        default:
            break;
    }
    
    if ([expendStatus isEqualToString:expendYES]) {
        [self.diseaseDict setObject:expendNO forKey:sectionName];
    }else if ([expendStatus isEqualToString:expendNO]){
        [self.diseaseDict setObject:expendYES forKey:sectionName];
    }
    [self.tableView reloadData];
}

- (void)threeButtonClick:(DisesaeDetailInfoButton *)btn
{
    NSInteger buttonTag = btn.tag;
    NSNumber * typeNumber = [[NSNumber alloc] init];
    switch (buttonTag) {
        case kThreeButtonTag:
            typeNumber = @1;
            break;
            
        case kThreeButtonTag+1:
            typeNumber = @2;
            break;
        case kThreeButtonTag+2:
            typeNumber = @3;
            break;
        default:
            break;
    }
    DiseaseMedicineListViewController* vc = [[DiseaseMedicineListViewController alloc] init];
    vc.title = btn.buttonName;
    vc.params = @{@"diseaseId":self.diseaseDict[@"diseaseId"], @"type":typeNumber};
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)treatRuleBgViewButtonClick:(NSDictionary *)buttonDict
{
    DiseaseMedicineListViewController* vc = [[DiseaseMedicineListViewController alloc] init];
    vc.title = buttonDict[@"formulaName"];
    vc.params = @{@"diseaseId":self.diseaseDict[@"diseaseId"], @"formulaId":buttonDict[@"formulaId"]};
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)relateBgViewDiseaseButtonClick:(NSString *)buttonName button:(DisesaeDetailInfoButton *)button
{
    
    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络异常，请稍候重试！" duration:DURATION_SHORT];
        
        button.enabled = YES;
        return;
    }
    
    [[HTTPRequestManager sharedInstance] queryDiseaseDetailIos:@{@"diseaseName":buttonName} completion:^(id resultObj) {
        
        
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
            
            [dic addEntriesFromDictionary:resultObj[@"body"]];
            
            if ([dic count] == 0) {
                [SVProgressHUD showErrorWithStatus:@"暂无疾病详情" duration:DURATION_SHORT];
                return ;
            }
            DiseaseDetailViewController* diseaseDetail = [[DiseaseDetailViewController alloc] initWithNibName:@"DiseaseDetailViewController" bundle:nil];
            diseaseDetail.title = buttonName;
            diseaseDetail.diseaseName = buttonName;
            diseaseDetail.diseaseType = resultObj[@"body"][@"type"];
            diseaseDetail.diseaseId = resultObj[@"body"][@"diseaseId"];
            diseaseDetail.containerViewController = self.containerViewController;
            diseaseDetail.tempDic = dic;
            if (self.containerViewController) {
                [self.containerViewController.navigationController pushViewController:diseaseDetail animated:YES];
            }else
            {
                [self.navigationController pushViewController:diseaseDetail animated:YES];
            }
         
            button.enabled = YES;
            
        }
    } failure:^(NSError *error) {
        
        [SVProgressHUD showErrorWithStatus:@"暂无疾病详情" duration:DURATION_SHORT];
        button.enabled = YES;
    }];
    
}

@end