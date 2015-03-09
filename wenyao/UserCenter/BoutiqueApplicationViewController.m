//
//  BoutiqueApplicationViewController.m
//  quanzhi
//
//  Created by xiezhenghong on 14-9-14.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BoutiqueApplicationViewController.h"
#import "Constant.h"
#import "HTTPRequestManager.h"
#import "SVProgressHUD.h"
#import "BoutiqueApplicationTableViewCell.h"
#import "UIImageView+WebCache.h"


@interface BoutiqueApplicationViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray        *dataSource;
@end

@implementation BoutiqueApplicationViewController
@synthesize tableView;
@synthesize dataSource;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)setupTableView
{
    CGRect rect = self.view.frame;
    rect.origin.x = 9;
    //    rect.origin.y += 20;
    rect.size.height -= 64;
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 50.0f;
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"精品应用";
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
//    [self setupTableView];
    self.dataSource = [NSMutableArray arrayWithCapacity:15];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"type"] = @"1";
    setting[@"currPage"] = @"1";
    setting[@"pageSize"] = @"0";
    [[HTTPRequestManager sharedInstance] goodAppList:setting completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            NSArray *array = resultObj[@"body"][@"data"];
            if (self.dataSource.count > 0) {
                [self.dataSource removeAllObjects];
            }
            for(NSDictionary *dict in array)
            {
                NSMutableDictionary *dictCopy = [dict mutableCopy];
                dictCopy[@"isExpand"] = [NSNumber numberWithBool:NO];
                [self.dataSource addObject:dictCopy];
            }
            [self.tableView reloadData];
        }
    } failure:NULL];
    
}
#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)calculateOffsetWithContent:(NSString *)text
{
    CGSize adjustSize = [text sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:CGSizeMake(280, 999) lineBreakMode:NSLineBreakByWordWrapping];
    if(adjustSize.height > 23.0f)
    {
        return ceilf(adjustSize.height - 23.0f);
    }else{
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)atableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = self.dataSource[indexPath.section];
    CGFloat offset = 0.0;
    
    offset = [self calculateCollapseHeigtOffsetWithFontSize:[UIFont systemFontOfSize:13.0f] withTextSting:dict[@"desc"] withRowAtIndexPath:indexPath];
    
    return 102.0f + offset;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
//    [header setBackgroundColor:[UIColor clearColor]];
//    return header;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 10.0f;
//}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return [self.dataSource count];
}

- (void)layouCellSubViews:(BoutiqueApplicationTableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    CGFloat offset = 0;
    NSDictionary *dict = self.dataSource[indexPath.section];
    
    offset = [self calculateCollapseHeigtOffsetWithFontSize:[UIFont systemFontOfSize:13.0f] withTextSting:dict[@"desc"] withRowAtIndexPath:indexPath];
    CGRect rect = cell.backGroundImage.frame;
    UIImage *image = [UIImage imageNamed:@"精品应用cell背景.png"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(80, 20, 10, 20) resizingMode:UIImageResizingModeStretch];
    cell.backGroundImage.image = image;
    rect.size.height = 101 + offset;
    cell.backGroundImage.frame = rect;
    
    rect = cell.applicationDescription.frame;
    rect.size.height = 23.0 + offset;
    cell.applicationDescription.frame = rect;
    
    rect = cell.expandButton.frame;
    rect.origin.y = 88 + offset;
    cell.expandButton.frame = rect;
}

//cell的收缩高度
- (CGFloat)calculateCollapseHeigtOffsetWithFontSize:(UIFont *)fontSize withTextSting:(NSString *)text withRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat singelHeight = fontSize.lineHeight;
    CGSize adjustSize = [text sizeWithFont:fontSize constrainedToSize:CGSizeMake(300, 999) lineBreakMode:NSLineBreakByWordWrapping];
    NSUInteger linecount = ceil( adjustSize.height /singelHeight);
    CGFloat adjustHeight = 0.0;
    if(linecount > 3) {
        self.dataSource[indexPath.section][@"isShow"] = [NSNumber numberWithBool:YES];
        adjustHeight = 3 * (singelHeight + 0.5);
    }else{
        adjustHeight = adjustSize.height;
    }
    CGFloat offset = adjustHeight - 23.f;
    if(offset > 0.0)
        return offset + 5.5;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *BoutiqueIdentifier = @"BoutiqueApplicationIdentifier";
    BoutiqueApplicationTableViewCell *cell = (BoutiqueApplicationTableViewCell *)[atableView dequeueReusableCellWithIdentifier:BoutiqueIdentifier];
    if(cell == nil)
    {
        UINib *nib = [UINib nibWithNibName:@"BoutiqueApplicationTableViewCell" bundle:nil];
        [atableView registerNib:nib forCellReuseIdentifier:BoutiqueIdentifier];
        cell = (BoutiqueApplicationTableViewCell *)[atableView dequeueReusableCellWithIdentifier:BoutiqueIdentifier];
    }
    NSDictionary *dict = self.dataSource[indexPath.section];
    [cell.avatar setImageWithURL:[NSURL URLWithString:dict[@"imgUrl"]] placeholderImage:nil];
    cell.applicationDescription.text = dict[@"desc"];
    cell.applicationName.text = dict[@"name"];
    [self layouCellSubViews:cell withIndexPath:indexPath];
    cell.expandButton.hidden = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [atableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = self.dataSource[indexPath.section];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dict[@"url"]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
