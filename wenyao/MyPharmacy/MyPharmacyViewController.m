//
//  MyPharmacyViewController.m
//  wenyao
//
//  Created by Pan@QW on 14-9-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "MyPharmacyViewController.h"
#import "MyPharmacyTableViewCell.h"
#import "AddNewMedicineViewController.h"
#import "TagCollectionViewController.h"
#import "HTTPRequestManager.h"
#import "AppDelegate.h"
#import "Constant.h"
#import "MedicineDetailViewController.h"
#import "SVProgressHUD.h"
#import "MGSwipeButton.h"
#import "AlarmClockViewController.h"
#import "PopTagView.h"
#import "SubSearchPharmacyViewController.h"
#import "PharmacyDetailViewController.h"
#import "SearchSliderViewController.h"
#import "UIImageView+WebCache.h"

@interface MyPharmacyViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UITabBarControllerDelegate,MGSwipeTableCellDelegate,PopTagViewDelegate,UIAlertViewDelegate>
{
    NSIndexPath             *firstIndexPath;
}

@property (nonatomic, strong) UITableView   *tableView;
@property (nonatomic, strong) UISearchBar   *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchDisplay;
@property (nonatomic, strong) PopTagView                *popTagView;
@property (nonatomic, strong) NSMutableArray            *filterMedicineList;
@property (nonatomic, strong) UIImageView               *hintImageView;
@property (nonatomic, strong) UILabel                   *hintLabel;
@property (nonatomic, assign) BOOL                      showSearchResult;


@end

@implementation MyPharmacyViewController
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.myMedicineList = [NSMutableArray arrayWithCapacity:15];
        self.filterMedicineList = [NSMutableArray arrayWithCapacity:15];
    }
    return self;
}

- (void)setupTableView
{
    CGRect rect = self.view.frame;
    if (self.subType) {
        rect.size.height -= 64;
        self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    } else {
        rect.size.height -= 108;
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width,rect.size.height) style:UITableViewStylePlain];
    }
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
}

- (void)setupSearchBar
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320 , 44)];
    self.searchBar.barTintColor = UIColorFromRGB(0xecf0f1);
    
    UITextField * textField = (UITextField *)[[self.searchBar subviews] objectAtIndex:0];
    
    
    self.searchBar.placeholder = @"搜索我的用药";

   
    self.searchBar.delegate = self;
//    self.tableView.tableHeaderView = self.searchBar;
    [self.view addSubview:self.searchBar];
    self.searchDisplay = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplay.searchBar.layer.masksToBounds = YES;
    self.searchDisplay.searchBar.layer.borderWidth = 0.5;
    self.searchDisplay.searchBar.layer.borderColor = UIColorFromRGB(0xdbdbdb).CGColor;
    self.searchDisplay.searchResultsDataSource = self;
    self.searchDisplay.searchResultsDelegate = self;
    self.searchDisplay.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.showSearchResult = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.filterMedicineList removeAllObjects];
    for(NSDictionary *dict in self.myMedicineList)
    {
        NSRange range = [dict[@"productName"] rangeOfString:searchText];
        if(range.location != NSNotFound){
            [self.filterMedicineList addObject:dict];
        }
        
        
    }
    
    
    [self.searchDisplay.searchResultsTableView reloadData];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    self.showSearchResult = NO;
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    SubSearchPharmacyViewController *subSearchPharmacyViewController = [[SubSearchPharmacyViewController alloc] init];
    [self.navigationController pushViewController:subSearchPharmacyViewController animated:YES];
    return NO;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    [self.view setBackgroundColor:UICOLOR(236, 240, 241)];
    self.popTagView = [[[NSBundle mainBundle] loadNibNamed:@"PopTagView" owner:self options:nil] objectAtIndex:0];
    self.popTagView.delegate = self;
    [self setupTableView];
    if(!self.subType)
    {
        [self setupSearchBar];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加用药" style:UIBarButtonItemStylePlain target:self action:@selector(addNewMedicine:)];
        self.title = @"我的用药";
    }
    self.hintImageView = [[UIImageView alloc] initWithFrame:CGRectMake(114, 180, 91, 91)];
    self.hintImageView.image = [UIImage imageNamed:@"无用药.png"];
    self.hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(70,280, 180, 25)];
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.textColor = UIColorFromRGB(0x7f8c97);
    self.hintLabel.font = [UIFont systemFontOfSize:15.0f];
    self.hintLabel.text = @"您还没有添加用药哦";
    if(!self.subType) {
        [self.view addSubview:self.hintLabel];
        [self.view addSubview:self.hintImageView];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePharmacy) name:PHARMACY_NEED_UPDATE object:nil];
    
    
//    UIView *viewBoutique = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60.0f, 30.0f)];
//    viewBoutique.backgroundColor = [UIColor clearColor];
//    
//    UILabel *lblBoutique = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60.0f, 30.0f)];
//    lblBoutique.textColor = [UIColor whiteColor];
//    lblBoutique.font = [UIFont systemFontOfSize:15.0f];
//    lblBoutique.text = @"添加用药";
//    
//    UIButton *btnBoutique = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnBoutique.frame = lblBoutique.frame;
//    [btnBoutique addTarget:self action:@selector(addNewMedicine:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [viewBoutique addSubview:lblBoutique];
//    [viewBoutique addSubview:btnBoutique];
//    //自定义title
//    UIBarButtonItem *btnItemBoutique = [[UIBarButtonItem alloc] initWithCustomView:viewBoutique];
//    
//    self.navigationItem.rightBarButtonItem = btnItemBoutique;
//    UIBarButtonItem *searchBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"导航栏_搜索icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pushIntoSearch:)];
//    self.navigationItem.rightBarButtonItem = searchBarButton;
//    UIBarButtonItem *searchBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"导航栏_搜索icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pushIntoSearch:)];
//    self.navigationItem.rightBarButtonItem = searchBarButton;

    
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    lblTitle.font = [UIFont systemFontOfSize:18.0f];
    lblTitle.text = @"我的用药";
    [lblTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0f]];
    lblTitle.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = lblTitle;

}
- (IBAction)pushIntoSearch:(id)sender
{
    SearchSliderViewController * searchViewController = [[SearchSliderViewController alloc] init];
    searchViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchViewController animated:NO];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PHARMACY_NEED_UPDATE object:nil];
}

- (void)updatePharmacy
{
    if (self.subType) {
        [self.tableView reloadData];
    } else {
        [self queryMyBox];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!self.subType)
    {
        if(self.myMedicineList.count > 0)
            return;
        if(app.currentNetWork != kNotReachable)
        {
            [self queryMyBox];
        }else{
            NSMutableArray *array = [app.dataBase selectAllBoxMedicine];
            if(array.count > 0)
            {
                self.hintLabel.hidden = YES;
                self.hintImageView.hidden = YES;
            }else{
                self.hintLabel.hidden = NO;
                self.hintImageView.hidden = NO;
            }
            
            for(NSDictionary *dict in array)
            {
                [self.myMedicineList addObject:[dict mutableCopy]];
            }
            if(array.count == 0) {
//                self.tableView.tableHeaderView = nil;
                self.searchBar.hidden = YES;
            }else{
                self.searchBar.hidden = NO;
//                self.tableView.tableHeaderView = self.searchBar;
            }
            [self.tableView reloadData];
            for(NSDictionary *dict in array)
            {
//                [self.myMedicineList addObject:[dict mutableCopy]];
                if(dict[@"useMethod"] && ![[NSString stringWithFormat:@"%@",dict[@"useMethod"]] isEqualToString:@""] && dict[@"perCount"] && ![[NSString stringWithFormat:@"%@",dict[@"perCount"]] isEqualToString:@""] && dict[@"unit"] && ![[NSString stringWithFormat:@"%@",dict[@"unit"]] isEqualToString:@""] && dict[@"useName"] && ![[NSString stringWithFormat:@"%@",dict[@"useName"]] isEqualToString:@""])
                {
                    
                }else{
                    if(firstIndexPath == nil) {
                        NSUInteger index = [array indexOfObject:dict];
                        firstIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    }
                }
            }
            if(_shouldScrollToUncomplete)
            {
                [self performSelector:@selector(scrollToAssignIndexPath) withObject:nil afterDelay:0.8];
            }
        }
    }else{
        [self queryMyBoxWithTagName:self.title];
    }
}

- (void)queryMyBoxWithTagName:(NSString *)tagName
{
    if(self.myMedicineList.count != 0)
        return;
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"currPage"] = @"1";
    setting[@"pageSize"] = @"100";
    setting[@"tag"] = tagName;
    [[HTTPRequestManager sharedInstance] queryBoxByTag:setting completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            NSArray *array = resultObj[@"body"][@"data"];
            NSLog(@"%@",array);
            for(NSDictionary *dict in array)
                [self.myMedicineList addObject:[dict mutableCopy]];
            
            [self.tableView reloadData];
        }
    } failure:NULL];
}

- (void)cacheMyBoxMedicine:(NSArray *)array
{
    for(NSDictionary *dict in array)
    {
        NSString *boxId = dict[@"boxId"];
        NSString *productName = @"";
        if(dict[@"productName"])
            productName = dict[@"productName"];
        NSString *productId = dict[@"productId"];
        NSString *source = @"";
        if(dict[@"source"])
        {
            source = dict[@"source"];
        }
        NSString *useName = @"";
        if(dict[@"useName"])
        {
            useName = dict[@"useName"];
        }
        NSString *createtime = @"";
        if(dict[@"createtime"]) {
            createtime = dict[@"createtime"];
        }
        NSString *effect = @"";
        if(dict[@"effect"]) {
            effect = dict[@"effect"];
        }
        NSString *useMethod = @"";
        if(dict[@"useMethod"]){
            useMethod = dict[@"useMethod"];
        }
        NSString *perCount = @"";
        if(dict[@"perCount"]) {
            perCount = [NSString stringWithFormat:@"%@",dict[@"perCount"]];
        }
        NSString *unit = @"";
        if(dict[@"unit"]) {
            unit = dict[@"unit"];
        }
        
        NSString *intervalDay = @"";
        if(dict[@"intervalDay"]) {
            intervalDay = [NSString stringWithFormat:@"%@",dict[@"intervalDay"]];
        }
        NSString *drugTime = @"";
        if(dict[@"drugTime"]){
            drugTime = [NSString stringWithFormat:@"%@",dict[@"drugTime"]];
        }
        NSString *drugTag = @"";
        if(dict[@"drugTag"]) {
            drugTag = dict[@"drugTag"];
        }
        NSString *productEffect = @"";
        if(dict[@"productEffect"]) {
            productEffect = dict[@"productEffect"];
        }
        [app.dataBase insertIntoMybox:boxId productName:productName productId:productId source:source useName:useName createtime:createtime effect:effect useMethod:useMethod perCount:perCount unit:unit intervalDay:intervalDay drugTime:drugTime drugTag:drugTag productEffect:productEffect];
    }
}

- (void)queryMyBox
{
//    if(self.myMedicineList.count != 0)
//        return;
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"currPage"] = @"1";
    setting[@"pageSize"] = @"0";
    [[HTTPRequestManager sharedInstance] queryMyBox:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"])
        {
            NSArray *array = resultObj[@"body"][@"data"];
            NSLog(@"%@",array);
            if(array.count > 0)
            {
                self.hintLabel.hidden = YES;
                self.hintImageView.hidden = YES;
            }else{
                self.hintLabel.hidden = NO;
                self.hintImageView.hidden = NO;
            }
            [self cacheMyBoxMedicine:array];
            [self.myMedicineList removeAllObjects];
            for(NSDictionary *dict in array)
            {
                [self.myMedicineList addObject:[dict mutableCopy]];
                if(dict[@"useMethod"] && ![[NSString stringWithFormat:@"%@",dict[@"useMethod"]] isEqualToString:@""] && dict[@"perCount"] && ![[NSString stringWithFormat:@"%@",dict[@"perCount"]] isEqualToString:@""] && dict[@"unit"] && ![[NSString stringWithFormat:@"%@",dict[@"unit"]] isEqualToString:@""] && dict[@"useName"] && ![[NSString stringWithFormat:@"%@",dict[@"useName"]] isEqualToString:@""])
                {
                    
                }else{
                    if(firstIndexPath == nil) {
                        NSUInteger index = [array indexOfObject:dict];
                        firstIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    }
                }
            }
            if(array.count == 0) {
//                self.tableView.tableHeaderView = nil;
                self.searchBar.hidden = YES;
            }else{
                self.searchBar.hidden = NO;
//                self.tableView.tableHeaderView = self.searchBar;
            }
            [self.tableView reloadData];
            if(_shouldScrollToUncomplete)
            {
                [self performSelector:@selector(scrollToAssignIndexPath) withObject:nil afterDelay:0.8];
            }
        }
    } failure:NULL];
}

- (void)scrollToAssignIndexPath
{
    [self.tableView scrollToRowAtIndexPath:firstIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    _shouldScrollToUncomplete = NO;
}

- (void)addNewMedicine:(id)sender
{
//    [MobClick event:@"aw-tjyy"];
    AddNewMedicineViewController *addNewMedicineViewController = [[AddNewMedicineViewController alloc] init];
    addNewMedicineViewController.InsertNewPharmacy = ^(NSMutableDictionary *dict)
    {
        self.hintLabel.hidden = YES;
        self.hintImageView.hidden = YES;
//        self.tableView.tableHeaderView = self.searchBar;
        self.searchBar.hidden = NO;
        [self.myMedicineList insertObject:dict atIndex:0];
        [self.tableView reloadData];
    };
    [self.navigationController pushViewController:addNewMedicineViewController animated:YES];
}

-(NSArray *) createRightButtons: (int) number
{
    NSMutableArray * result = [NSMutableArray array];
    NSString* titles[2] = {@" 删除 ", @" 闹钟 "};
    UIColor * colors[2] = {[UIColor redColor], UICOLOR(228, 232, 232)};
    for (int i = 0; i < number; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
            return YES;
        }];
        if(i == 1) {
            [button setTitleColor:UICOLOR(21, 120, 254) forState:UIControlStateNormal];
        }
        [result addObject:button];
    }
    return result;
}


#pragma mark -
#pragma mark MGSwipeTableCellDelegate
-(NSArray*) swipeTableCell:(MGSwipeTableCell*)cell
  swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*)swipeSettings
         expansionSettings:(MGSwipeExpansionSettings*)expansionSettings;
{

    if (direction == MGSwipeDirectionRightToLeft)
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSDictionary *dict = self.myMedicineList[indexPath.row];
        BOOL showAlarm = [app.dataBase checkAlarmClock:dict[@"boxId"]];
        if(showAlarm) {
            return [self createRightButtons:1];
        }else{
            return [self createRightButtons:2];
        }
        
    }
    return nil;
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    
    NSIndexPath *indexPath = nil;
    NSMutableDictionary *dict = nil;
    if(cell.tag >= 2000)
    {
        indexPath = [self.tableView indexPathForCell:cell];
        dict = self.myMedicineList[indexPath.row];
    }else{
        indexPath = [self.searchDisplay.searchResultsTableView indexPathForCell:cell];
        dict = self.filterMedicineList[indexPath.row];
    }

    if (index == 0) {
        //删除事件
        if (app.currentNetWork == kNotReachable) {
            
            [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
            
            return NO;
        }
        
        [self.myMedicineList removeObject:dict];
        [self.filterMedicineList removeObject:dict];
        [self.tableView reloadData];
        if(cell.tag >= 2000)
        {
            NSMutableDictionary *setting = [NSMutableDictionary dictionary];
            setting[@"token"] = app.configureList[APP_USER_TOKEN];
            setting[@"boxId"] = dict[@"boxId"];
            [[HTTPRequestManager sharedInstance] deleteBoxProduct:setting completion:^(id resultObj) {
                if([resultObj[@"result"] isEqualToString:@"OK"]){
                    
                }
            } failure:NULL];
            
            [app.dataBase deleteAlarmClock:dict[@"boxId"]];
            NSArray *notificationList = [[UIApplication sharedApplication] scheduledLocalNotifications];
            [notificationList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UILocalNotification *localNotification = (UILocalNotification *)obj;
                NSDictionary *userInfo = [localNotification userInfo];
                if([userInfo[@"boxId"] isEqualToString:dict[@"boxId"]])
                {
                    [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
                }
            }];
            //[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            if(self.myMedicineList.count == 0) {
//                self.tableView.tableHeaderView = nil;
                self.searchBar.hidden = YES;
                self.hintLabel.hidden = NO;
                self.hintImageView.hidden = NO;
            }
            if (self.subType) {
                [[NSNotificationCenter defaultCenter] postNotificationName:PHARMACY_NEED_UPDATE object:nil];
            } else {
                
            }
        }else{
            
            
            [self.searchDisplay.searchResultsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView reloadData];
        }
    }else{
        //闹钟事件
        if([dict[@"intervalDay"] integerValue] == 0) {
            [SVProgressHUD showErrorWithStatus:@"即需即用,无法添加闹钟!" duration:0.8];
            return YES;
        }
        if(dict[@"useMethod"]&& dict[@"perCount"] && dict[@"unit"] && dict[@"drugTime"] && dict[@"useName"])
        {
            
        }else{
            [SVProgressHUD showErrorWithStatus:@"请先完善用药信息!" duration:0.8];
            return YES;
        }
        
        __weak typeof (self) weakSelf = self;
        AlarmClockViewController *alarmClockViewController = [[AlarmClockViewController alloc] init];
        //添加闹钟
        BOOL result = [app.dataBase checkAlarmClock:dict[@"boxId"]];
        alarmClockViewController.useType = result? 1:0;
        alarmClockViewController.editClockBlock = ^(){
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        };
        alarmClockViewController.infoDict = dict;
        [self.navigationController pushViewController:alarmClockViewController animated:YES];
    }
    return YES;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0f;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    if([atableView isEqual:self.tableView])
        return self.myMedicineList.count;
    else
        return self.filterMedicineList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyPharmacyIdentifier = @"MyPharmacyIdentifier";
    MyPharmacyTableViewCell *cell = (MyPharmacyTableViewCell *)[atableView dequeueReusableCellWithIdentifier:MyPharmacyIdentifier];
    if(cell == nil){
        UINib *nib = [UINib nibWithNibName:@"MyPharmacyTableViewCell" bundle:nil];
        [atableView registerNib:nib forCellReuseIdentifier:MyPharmacyIdentifier];
        cell = (MyPharmacyTableViewCell *)[atableView dequeueReusableCellWithIdentifier:MyPharmacyIdentifier];
        
        cell.selectedBackgroundView = [[UIView alloc]init];
        cell.selectedBackgroundView.backgroundColor = UIColorFromRGB(0xdfe4e6);
    }
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 119.5, APP_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [cell addSubview:line];
    
    NSDictionary *dict = nil;
    if([atableView isEqual:self.tableView])
    {
        dict = self.myMedicineList[indexPath.row];
        cell.tag = indexPath.row + 2000;
    }else{
        dict = self.filterMedicineList[indexPath.row];
        cell.tag = indexPath.row;
    }
    NSString *proId = @"";
    if(dict[@"productId"] && ![dict[@"productId"] isEqual:[NSNull null]])
    {
        proId = dict[@"productId"];
    }
    
    [cell.avatar setImageWithURL:[NSURL URLWithString:PORID_IMAGE(proId)] placeholderImage:[UIImage imageNamed:@"默认药品图片_V2.png"]];
    
    if(dict[@"productName"] && ![dict[@"productName"] isEqual:[NSNull null]]){
        cell.medicineName.text = dict[@"productName"];
    }else{
        cell.medicineName.text = @"";
    }
    cell.dateLabel.text = dict[@"createTime"];
  
    if(dict[@"useMethod"] && ![[NSString stringWithFormat:@"%@",dict[@"useMethod"]] isEqualToString:@""] && dict[@"perCount"] && ![[NSString stringWithFormat:@"%@",dict[@"perCount"]] isEqualToString:@""] && dict[@"unit"] && ![[NSString stringWithFormat:@"%@",dict[@"unit"]] isEqualToString:@""] && dict[@"useName"] && ![[NSString stringWithFormat:@"%@",dict[@"useName"]] isEqualToString:@""])
    {
        cell.uncompleteImage.hidden = YES;
        NSUInteger intervalDay = [dict[@"intervalDay"] integerValue];
        if(intervalDay == 0) {
            cell.medicineUsage.text = [NSString stringWithFormat:@"%@,一次%@%@,即需即用",dict[@"useMethod"],dict[@"perCount"],dict[@"unit"]];
        }else{
            cell.medicineUsage.text = [NSString stringWithFormat:@"%@,一次%@%@,%@日%@次",dict[@"useMethod"],dict[@"perCount"],dict[@"unit"],dict[@"intervalDay"],dict[@"drugTime"]];
        }
    }else{
        cell.uncompleteImage.hidden = NO;
        cell.medicineUsage.text = @"暂无用法用量";
    }
    BOOL showAlarm = [app.dataBase checkAlarmClock:dict[@"boxId"]];
    if(showAlarm) {
        cell.alarmClockImage.hidden = NO;
    }else{
        cell.alarmClockImage.hidden = YES;
    }
    cell.alarmClockImage.tag = indexPath.row;
    [self layoutTableView:atableView withTableViewCell:cell WithTag:dict];


    [cell.alarmClockImage addTarget:self action:@selector(pushIntoAlarmClock:) forControlEvents:UIControlEventTouchDown];

    cell.delegate = self;
    
    
    return cell;
}

- (void)pushIntoAlarmClock:(UIButton *)sender
{
    __weak typeof (self) weakSelf = self;
    AlarmClockViewController *alarmClockViewController = [[AlarmClockViewController alloc] init];
    //添加闹钟
    NSMutableDictionary *dict = self.myMedicineList[sender.tag];
    alarmClockViewController.useType = 1;
    __block NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    alarmClockViewController.editClockBlock = ^(){
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    };
    alarmClockViewController.infoDict = dict;
    [self.navigationController pushViewController:alarmClockViewController animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSDictionary *dict = self.myMedicineList[alertView.tag];
    if (buttonIndex == 0) {
        //删除闹钟
        NSString *boxId = dict[@"boxId"];
        [app.dataBase deleteAlarmClock:boxId];
        NSArray *notificationList = [[UIApplication sharedApplication] scheduledLocalNotifications];
        [notificationList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UILocalNotification *localNotification = (UILocalNotification *)obj;
            NSDictionary *userInfo = [localNotification userInfo];
            if([userInfo[@"boxId"] isEqualToString:boxId])
            {
                [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
            }
        }];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:alertView.tag inSection:0];
        [[NSNotificationCenter defaultCenter] postNotificationName:PHARMACY_NEED_UPDATE object:nil];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        //修改闹钟
        __weak typeof (self) weakSelf = self;
        AlarmClockViewController *alarmClockViewController = [[AlarmClockViewController alloc] init];
        //添加闹钟
        BOOL result = [app.dataBase checkAlarmClock:dict[@"boxId"]];
        alarmClockViewController.useType = result? 1:0;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:alertView.tag inSection:0];
        alarmClockViewController.editClockBlock = ^(){
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        };
        alarmClockViewController.mustSave = YES;
        alarmClockViewController.infoDict = dict;
        [self.navigationController pushViewController:alarmClockViewController animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
    [atableView deselectRowAtIndexPath:indexPath animated:YES];
    if(app.currentNetWork == kNotReachable)
    {
//        [SVProgressHUD showErrorWithStatus:@"当前暂无网络,请稍后重试!" duration:0.8f];
//        return;
    }
    NSMutableDictionary *dict = nil;
    if([atableView isEqual:self.tableView]) {
        dict = self.myMedicineList[indexPath.row];
    }else{
        dict = self.filterMedicineList[indexPath.row];
    }
    if(dict[@"useMethod"] && ![[NSString stringWithFormat:@"%@",dict[@"useMethod"]] isEqualToString:@""] && dict[@"perCount"] && ![[NSString stringWithFormat:@"%@",dict[@"perCount"]] isEqualToString:@""] && dict[@"unit"] && ![[NSString stringWithFormat:@"%@",dict[@"unit"]] isEqualToString:@""] && dict[@"useName"] && ![[NSString stringWithFormat:@"%@",dict[@"useName"]] isEqualToString:@""])
    {
        PharmacyDetailViewController *pharmacyDetailViewController = nil;
        if(HIGH_RESOLUTION) {
            pharmacyDetailViewController = [[PharmacyDetailViewController alloc] initWithNibName:@"PharmacyDetailViewController" bundle:nil];
        }else{
            pharmacyDetailViewController = [[PharmacyDetailViewController alloc] initWithNibName:@"PharmacyDetailViewController-480" bundle:nil];
        }
        pharmacyDetailViewController.infoDict = dict;
        pharmacyDetailViewController.changeMedicineInformation = ^(NSDictionary *dict)
        {
            if([dict[@"intervalDay"] integerValue] == 0)
            {
                [app.dataBase deleteAlarmClock:dict[@"boxId"]];
                return;
            }
            BOOL showAlarm = [app.dataBase checkAlarmClock:dict[@"boxId"]];
            if(showAlarm) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"您的用药%@已更新,该用药闹钟已失效,是否手动修改?",dict[@"productName"]] delegate:self cancelButtonTitle:@"删除" otherButtonTitles:@"修改", nil];
                alertView.tag = indexPath.row;
                [alertView show];
            }
        };
        [self.navigationController pushViewController:pharmacyDetailViewController animated:YES];

    }else{
        __weak __typeof(self) weakSelf = self;
        AddNewMedicineViewController *addNewMedicineViewController = [[AddNewMedicineViewController alloc] initWithNibName:@"AddNewMedicineViewController" bundle:nil];
        addNewMedicineViewController.editMode = 1;
        addNewMedicineViewController.InsertNewPharmacy = ^(NSMutableDictionary *dict) {

            [weakSelf.tableView reloadData];
        };
        addNewMedicineViewController.originDict = dict;
        [self.navigationController pushViewController:addNewMedicineViewController animated:YES];
        return;
    }
    
    
    
    
//    MedicineDetailViewController *medicineDetailViewControler = [[MedicineDetailViewController alloc] initWithNibName:@"MedicineDetailViewController" bundle:nil];
//    medicineDetailViewControler.proId = dict[@"productId"];
//    medicineDetailViewControler.showRightBarButton = YES;
//    [self.navigationController pushViewController:medicineDetailViewControler animated:YES];
}

- (UIButton *)createTagButtonWithTitle:(NSString *)title WithIndex:(NSUInteger)index tagType:(TagType)tagType withOffset:(CGFloat)offset
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13.0];
    UIImage *resizeImage = nil;
    if([title isEqualToString:self.title]) {
        resizeImage = [UIImage imageNamed:@"标签背景-绿.png"];
        [button setTitleColor:APP_COLOR_STYLE forState:UIControlStateNormal];
        resizeImage = [resizeImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 5, 10, 5) resizingMode:UIImageResizingModeStretch];
    }else{
        resizeImage = [UIImage imageNamed:@"标签背景.png"];
        resizeImage = [resizeImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 5, 10, 5) resizingMode:UIImageResizingModeStretch];
    }
    CGSize size = [title sizeWithFont:button.titleLabel.font constrainedToSize:CGSizeMake(300, 20)];
    button.frame = CGRectMake(offset, 86, size.width + 2 * 10, 25);
    button.tag = index * 1000 + tagType;
    [button setBackgroundImage:resizeImage forState:UIControlStateNormal];
    return button;
}

- (void)layoutTableView:(UITableView *)atableView withTableViewCell:(UITableViewCell *)cell WithTag:(NSDictionary *)tagsDict
{
    for(UIView *button in cell.contentView.subviews) {
        if(button.frame.origin.y == 86.0)
            [button removeFromSuperview];
    }
    CGFloat offset = 10;
    UIButton *button = nil;
    NSUInteger index = 0;
    if([tableView isEqual:self.tableView]) {
        index = [self.myMedicineList indexOfObject:tagsDict];
    }else{
        index = [self.filterMedicineList indexOfObject:tagsDict];
    }
#ifdef DEBUG
    NSLog(@"the drug tag is %@",tagsDict[@"drugTag"]);
#endif
    if(tagsDict && tagsDict[@"drugTag"] && ![tagsDict[@"drugTag"] isEqualToString:@""])
    {
        NSString *strDrugTag = tagsDict[@"drugTag"];
        NSLog(@"the drug tag is %@",strDrugTag);
        if (strDrugTag.length > 6) {
            strDrugTag = [strDrugTag substringToIndex:6];
        }

        button = [self createTagButtonWithTitle:strDrugTag WithIndex:index tagType:DrugTag withOffset:offset];
        [cell.contentView addSubview:button];
        //[button addTarget:self action:@selector(pushIntoFilterViewController:) forControlEvents:UIControlEventTouchDown];
        offset += button.frame.size.width + 5;
        if(![atableView isEqual:self.tableView]) {
            button.tag *= -1;
        }
    }
    if(tagsDict && tagsDict[@"useName"] && ![tagsDict[@"useName"] isEqualToString:@""])
    {
        NSString *strUseName = tagsDict[@"useName"];
        if (strUseName.length > 3) {
            strUseName = [strUseName substringToIndex:3];
        }
#ifdef DEBUG
        NSLog(@"the use name is %@",strUseName);
#endif
        button = [self createTagButtonWithTitle:strUseName WithIndex:index tagType:UseNameTag withOffset:offset];
        //[button addTarget:self action:@selector(pushIntoFilterViewController:) forControlEvents:UIControlEventTouchDown];
        [cell.contentView addSubview:button];
        if(![atableView isEqual:self.tableView]) {
            button.tag *= -1;
        }
        offset += button.frame.size.width + 5;
    }
    if(tagsDict && tagsDict[@"effect"] && ![tagsDict[@"effect"] isEqualToString:@""])
    {
        NSString *strEffect = tagsDict[@"effect"];
        if (strEffect.length > 4) {
            strEffect = [strEffect substringToIndex:4];
        }
#ifdef DEBUG
        NSLog(@"the effect is %@",strEffect);
#endif
        button = [self createTagButtonWithTitle:strEffect WithIndex:index tagType:EffectTag withOffset:offset];
        //[button addTarget:self action:@selector(pushIntoFilterViewController:) forControlEvents:UIControlEventTouchDown];
        [cell.contentView addSubview:button];
        if(![atableView isEqual:self.tableView]) {
            button.tag *= -1;
        }
        offset += button.frame.size.width + 5;
    }

    if(self.subType)
        return;
    button = [self createTagButtonWithTitle:@"添加标签" WithIndex:index tagType:AddTag withOffset:offset];
    if(![atableView isEqual:self.tableView])
    {
        button.tag *= -1;
    }
    [button addTarget:self action:@selector(showTagDetail:) forControlEvents:UIControlEventTouchDown];
    [cell.contentView addSubview:button];
}

//- (void)pushIntoFilterViewController:(UIButton *)sender
//{
//    TagType tagType = sender.tag % 1000;
//    NSUInteger index = sender.tag  / 1000;
//    NSDictionary *dict = self.myMedicineList[index];
//    NSString *tagName = nil;
//    NSString *keyName = nil;
//    switch (tagType) {
//        case DrugTag:{
//            tagName = dict[@"drugTag"];
//            keyName = @"drugTag";
//            break;
//        }
//        case UseNameTag:{
//            tagName = dict[@"drugTag"];
//            keyName = @"drugTag";
//            break;
//        }
//        case EffectTag:{
//            tagName = dict[@"useName"];
//            keyName = @"useName";
//            break;
//        }
//        default:
//            break;
//    }
//    NSMutableArray *convertArray = nil;
//    if(sender.tag > 0){
//        //表视图搜索
//        convertArray = self.myMedicineList;
//    }else{
//        //结果视图搜索
//        convertArray = self.filterMedicineList;
//    }
//    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:10];
//    for(NSDictionary *dict in convertArray)
//    {
//        NSString *tagValue = dict[keyName];
//        if(tagValue && [tagValue isEqualToString:tagName]) {
//            [resultArray addObject:dict];
//        }
//    }
//    MyPharmacyViewController *myPharmacyViewController = [[MyPharmacyViewController alloc] init];
//    myPharmacyViewController.myMedicineList = resultArray;
//    myPharmacyViewController.subType = YES;
//    [self.navigationController pushViewController:myPharmacyViewController animated:YES];
//    myPharmacyViewController.title = tagName;
//}

- (void)showTagDetail:(UIButton *)sender
{
    if(app.currentNetWork == kNotReachable)
    {
        [SVProgressHUD showErrorWithStatus:@"当前暂无网络,请稍后重试!" duration:0.8f];
        return;
    }
    NSUInteger index = sender.tag  / 1000;
    NSDictionary *dict = self.myMedicineList[index];
    NSMutableArray *tagsArray = [NSMutableArray arrayWithCapacity:15];
    if(dict[@"drugTag"])
    {
        NSMutableDictionary *subDict = [@{@"drugTitle":@"主治",
                                  @"drugName":dict[@"drugTag"]} mutableCopy];
        [tagsArray addObject:subDict];
    }
    if(dict[@"useName"])
    {
        NSMutableDictionary *subDict = [@{@"drugTitle":@"使用者",
                                  @"drugName":dict[@"useName"]} mutableCopy];
        [tagsArray addObject:subDict];
    }
    if(dict[@"effect"])
    {
        NSMutableDictionary *subDict = [@{@"drugTitle":@"药效",
                                  @"drugName":dict[@"effect"]} mutableCopy];
        [tagsArray addObject:subDict];
    }else{
        NSMutableDictionary *subDict = [@{@"drugTitle":@"药效",
                                  @"drugName":@""} mutableCopy];
        [tagsArray addObject:subDict];
    }
    [self.popTagView setExistTagList:tagsArray];
    self.popTagView.tag = index;
    [self.popTagView showInView:self.view animated:YES];
}

#pragma mark -
#pragma mark PopTagViewDelegate
- (void)popTagDidSelectedIndexPath:(NSIndexPath *)indexPath
                        newTagName:(NSString *)tagName
{
    __block NSMutableDictionary *dict = self.myMedicineList[indexPath.row];
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"boxId"] = dict[@"boxId"];
    setting[@"tag"] = tagName;
    dict[@"effect"] = tagName;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [[HTTPRequestManager sharedInstance] updateBoxProductTag:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]) {
            
        }
    } failure:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}


@end
