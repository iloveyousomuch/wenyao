//
//  SubSearchPharmacyViewController.m
//  wenyao
//
//  Created by xiezhenghong on 14-10-24.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "SubSearchPharmacyViewController.h"
#import "MyPharmacyTableViewCell.h"
#import "Constant.h"
#import "UIImageView+WebCache.h"
#import "HTTPRequestManager.h"
#import "AppDelegate.h"
#import "Constant.h"
#import "AddNewMedicineViewController.h"
#import "PharmacyDetailViewController.h"
#import "SVProgressHUD.h"
#import "TagCollectionView.h"
#import "TagCollectionFlowLayout.h"

@interface SubSearchPharmacyViewController ()<UITableViewDataSource,
UITableViewDelegate,UISearchBarDelegate,TagCollectionViewDelegate>

@property (nonatomic, strong) UISearchBar   *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchDisplay;
@property (nonatomic, strong) TagCollectionView     *tagCollectionView;
@property (nonatomic, strong) NSMutableArray    *tagsList;

@end

@implementation SubSearchPharmacyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.myMedicineList = [NSMutableArray arrayWithCapacity:15];
    self.tagsList = [NSMutableArray arrayWithCapacity:15];
    [self setupCollection];
    [self setupSearchBar];
    self.title = @"搜索我的用药";
    [self queryTagLists];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.searchDisplay.searchResultsTableView reloadData];
}

- (void)setupSearchBar
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320 , 44)];
    self.searchBar.backgroundColor = [UIColor clearColor];
    self.searchBar.placeholder = @"搜索我的用药";
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
    self.searchDisplay = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplay.searchResultsDataSource = self;
    self.searchDisplay.searchResultsDelegate = self;
    self.searchDisplay.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)setupCollection
{
    CGRect rect = self.view.frame;
    rect.origin.y = 44;
    rect.size.height -= 64 + 44;
    self.tagCollectionView = [[TagCollectionView alloc] initWithFrame:rect collectionViewLayout:[[TagCollectionFlowLayout alloc] init]];
    self.tagCollectionView.collectionDelegate = self;
    [self.view addSubview:self.tagCollectionView];
}

- (void)queryTagLists
{
    if(self.tagsList.count > 0)
        return;

    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];

    [[HTTPRequestManager sharedInstance] queryAllTags:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]) {
            NSArray *array = resultObj[@"body"][@"tags"];
            if(array.count > 0) {
                [self.tagsList addObjectsFromArray:array];
                [self.tagCollectionView reloadData];

            }
        }
    } failure:NULL];
}

#pragma mark -
#pragma mark UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText.length == 0)
        return;
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"currPage"] = @"1";
    setting[@"pageSize"] = @"100";
    setting[@"keyword"] = searchText;
    [[HTTPRequestManager sharedInstance] queryBoxByKeyword:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]) {
            [self.myMedicineList removeAllObjects];
            NSArray *array = resultObj[@"body"][@"data"];
            for(NSDictionary *dict in array)
            {
                [self.myMedicineList addObject:[dict mutableCopy]];
            }
            [self.searchDisplay.searchResultsTableView reloadData];
        }
    } failure:NULL];
    
    [self.searchDisplay.searchResultsTableView reloadData];
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0f;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    return self.myMedicineList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *MyPharmacyIdentifier = @"MyPharmacyIdentifier";
//    cell = (MyPharmacyTableViewCell *)[atableView dequeueReusableCellWithIdentifier:MyPharmacyIdentifier];
    
//    [atableView registerNib:nib forCellReuseIdentifier:MyPharmacyIdentifier];
    MyPharmacyTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"MyPharmacyTableViewCell" owner:self options:nil] objectAtIndex:0];
    cell.selectedBackgroundView = [[UIView alloc]init];
    cell.selectedBackgroundView.backgroundColor = UIColorFromRGB(0xdfe4e6);

    NSDictionary *dict = nil;
    dict = self.myMedicineList[indexPath.row];
    cell.tag = indexPath.row + 2000;
    NSString *proId = @"";
    if(dict[@"productId"])
    {
        proId = dict[@"productId"];
    }
    [cell.avatar setImageWithURL:[NSURL URLWithString:PORID_IMAGE(proId)] placeholderImage:[UIImage imageNamed:@"默认药品图片_V2.png"]];
    
    BOOL showAlarm = [app.dataBase checkAlarmClock:dict[@"boxId"]];
    if(showAlarm) {
        cell.alarmClockImage.hidden = NO;
    }else{
        cell.alarmClockImage.hidden = YES;
    }
    
    NSString *strMedicine = dict[@"productName"];
    
    NSMutableAttributedString *strAttributeMedicine = [[NSMutableAttributedString alloc] initWithString:strMedicine];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.searchBar.text options:kNilOptions error:nil];
    
    NSRange range = NSMakeRange(0,strMedicine.length);
    
    [regex enumerateMatchesInString:strMedicine options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange subStringRange = [result rangeAtIndex:0];
        [strAttributeMedicine addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0/255.0f green:183/255.0f blue:45/255.0f alpha:1] range:subStringRange];
    }];

    cell.medicineName.attributedText = strAttributeMedicine;
    cell.dateLabel.text = dict[@"createTime"];
    
    if(dict[@"useMethod"] && ![[NSString stringWithFormat:@"%@",dict[@"useMethod"]] isEqualToString:@""] && dict[@"perCount"] && ![[NSString stringWithFormat:@"%@",dict[@"perCount"]] isEqualToString:@""] && dict[@"unit"] && ![[NSString stringWithFormat:@"%@",dict[@"unit"]] isEqualToString:@""] && dict[@"drugTime"] && dict[@"useName"] && ![[NSString stringWithFormat:@"%@",dict[@"useName"]] isEqualToString:@""] && dict[@"drugTime"] && ![[NSString stringWithFormat:@"%@",dict[@"drugTime"]] isEqualToString:@""])
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
    cell.delegate = self;
    [self layoutTableView:atableView withTableViewCell:cell WithTag:dict];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 119.5, APP_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [cell addSubview:line];
    
    return cell;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *selection = [atableView indexPathForSelectedRow];
    if (selection) {
        [atableView deselectRowAtIndexPath:selection animated:YES];
    }
    [atableView deselectRowAtIndexPath:indexPath animated:YES];
    if(app.currentNetWork == kNotReachable)
    {
        [SVProgressHUD showErrorWithStatus:@"当前暂无网络,请稍后重试!" duration:0.8f];
        return;
    }
    NSMutableDictionary *dict = self.myMedicineList[indexPath.row];
    if(dict[@"useMethod"] && ![[NSString stringWithFormat:@"%@",dict[@"useMethod"]] isEqualToString:@""] && dict[@"perCount"] && ![[NSString stringWithFormat:@"%@",dict[@"perCount"]] isEqualToString:@""] && dict[@"unit"] && ![[NSString stringWithFormat:@"%@",dict[@"unit"]] isEqualToString:@""] && dict[@"drugTime"] && dict[@"useName"] && ![[NSString stringWithFormat:@"%@",dict[@"useName"]] isEqualToString:@""] && dict[@"drugTime"] && ![[NSString stringWithFormat:@"%@",dict[@"drugTime"]] isEqualToString:@""])
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
            NSUInteger row = [weakSelf.myMedicineList indexOfObject:dict];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [weakSelf.searchDisplay.searchResultsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        };
        addNewMedicineViewController.originDict = dict;
        [self.navigationController pushViewController:addNewMedicineViewController animated:YES];
        return;
    }
}



- (void)layoutTableView:(UITableView *)atableView withTableViewCell:(UITableViewCell *)cell WithTag:(NSDictionary *)tagsDict
{
    CGFloat offset = 10;
    UIButton *button = nil;
    NSUInteger index = 0;
    index = [self.myMedicineList indexOfObject:tagsDict];
    NSInteger tagBtnDrug = index * 1000 + DrugTag;
    UIButton *btnExistDrug = (UIButton *)[cell.contentView viewWithTag:tagBtnDrug];
    if (btnExistDrug) {
        [btnExistDrug removeFromSuperview];
    }
    NSInteger tagBtnUsrName = index * 1000 + UseNameTag;
    UIButton *btnExistUsrName = (UIButton *)[cell.contentView viewWithTag:tagBtnUsrName];
    if (btnExistUsrName) {
        [btnExistUsrName removeFromSuperview];
    }
    NSInteger tagBtnEffect = index * 1000 + EffectTag;
    UIButton *btnExistEffect = (UIButton *)[cell.contentView viewWithTag:tagBtnEffect];
    if (btnExistEffect) {
        [btnExistEffect removeFromSuperview];
    }
    if(tagsDict[@"drugTag"])
    {
        button = [self createTagButtonWithTitle:tagsDict[@"drugTag"] WithIndex:index tagType:DrugTag withOffset:offset];
        [cell.contentView addSubview:button];
        offset += button.frame.size.width + 10;
    }
    if(tagsDict[@"useName"])
    {
        button = [self createTagButtonWithTitle:tagsDict[@"useName"] WithIndex:index tagType:UseNameTag withOffset:offset];
        [cell.contentView addSubview:button];
        offset += button.frame.size.width + 10;
    }
    if(tagsDict[@"effect"])
    {
        button = [self createTagButtonWithTitle:tagsDict[@"effect"] WithIndex:index tagType:EffectTag withOffset:offset];
        [cell.contentView addSubview:button];
        offset += button.frame.size.width + 10;
    }
}

- (UIButton *)createTagButtonWithTitle:(NSString *)title WithIndex:(NSUInteger)index tagType:(TagType)tagType withOffset:(CGFloat)offset
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13.0];
    UIImage *resizeImage = nil;
    if(tagType == AddTag) {
        resizeImage = [UIImage imageNamed:@"添加标签背景.png"];
        resizeImage = [resizeImage resizableImageWithCapInsets:UIEdgeInsetsMake(10,10, 10,10) resizingMode:UIImageResizingModeStretch];
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

#pragma mark -
#pragma mark TagCollectionViewDelegate
- (NSUInteger)numberOfItemsInCollectionView
{
    return self.tagsList.count;
}

- (NSString *)contentForIndexPath:(NSIndexPath *)indexPath
{
    return self.tagsList[indexPath.row];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tagName = self.tagsList[indexPath.row];
    
    MyPharmacyViewController *myPharmacyViewController = [[MyPharmacyViewController alloc] init];
    myPharmacyViewController.subType = YES;
    [self.navigationController pushViewController:myPharmacyViewController animated:YES];
    myPharmacyViewController.title = tagName;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
