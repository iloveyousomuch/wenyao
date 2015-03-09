//
//  EvaluationViewController.m
//  wenyao
//
//  Created by xiezhenghong on 14-10-6.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "EvaluationViewController.h"
#import "HTTPRequestManager.h"
#import "PharmacyCommentDetailTableViewCell.h"
#import "MarkPharmacyViewController.h"
#import "ReturnIndexView.h"
#import "AppDelegate.h"

@interface EvaluationViewController ()<UITableViewDataSource,UITableViewDelegate,ReturnIndexViewDelegate>

@property (nonatomic, strong) UITableView           *tableView;

@property (nonatomic, strong) NSMutableArray *arrExpand;
@property (nonatomic, strong) ReturnIndexView *indexView;

@end

@implementation EvaluationViewController

- (void)setupTableView
{
    CGRect rect = self.view.frame;
    rect.size.height -= 64;
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    self.tableView.separatorColor = UIColorFromRGB(0xdbdbdb);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [self.tableView setSeparatorInset:(UIEdgeInsetsMake(0, 0, 0, 0))];
    }

    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
}

- (void)evaluateAction:(id)sender
{
    MarkPharmacyViewController *markPharmacyViewController = [[MarkPharmacyViewController alloc] init];
    [self.navigationController pushViewController:markPharmacyViewController animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"药房评价";
    self.arrExpand = [[NSMutableArray alloc] init];
    for (int i = 0; i<self.infoList.count; i++) {
        NSMutableDictionary *dicExpand = [@{@"expand":@NO} mutableCopy];
        [self.arrExpand addObject:dicExpand];
    }
//    UIBarButtonItem *evaluateBarButton = [[UIBarButtonItem alloc] initWithTitle:@"评价" style:UIBarButtonItemStylePlain target:self action:@selector(evaluateAction:)];
//    self.navigationItem.rightBarButtonItem = evaluateBarButton;
    
    [self setupTableView];
    
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



//cell的收缩高度
- (CGFloat)calculateCollapseHeigtOffsetWithFontSize:(UIFont *)fontSize withTextSting:(NSString *)text withRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize adjustSize = [text sizeWithFont:fontSize constrainedToSize:CGSizeMake(294, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    if(adjustSize.height > 50.0f)
    {
        NSMutableDictionary *dicExpand = self.arrExpand[indexPath.row];
        if ([dicExpand[@"expand"] boolValue]) {
            return adjustSize.height;
        } else {
            return 50.0f;
        }
    }else{
        return adjustSize.height;//0;
    }
}

- (BOOL)shouldAddExpandView:(NSIndexPath *)indexPath withFont:(UIFont *)fontSize
{
    NSDictionary *dicInfo = self.infoList[indexPath.row];
    CGSize adjustSize = [dicInfo[@"remark"] sizeWithFont:fontSize constrainedToSize:CGSizeMake(294, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    if (adjustSize.height > 50.0f) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = self.infoList[indexPath.row];
    CGFloat offset = [self calculateCollapseHeigtOffsetWithFontSize:[UIFont systemFontOfSize:13.0] withTextSting:dict[@"remark"] withRowAtIndexPath:indexPath];
    CGFloat rowHeight = 0.0f;
    if ([self shouldAddExpandView:indexPath withFont:[UIFont systemFontOfSize:13.0]]) {
        rowHeight = 80+offset;
    } else {
        rowHeight = 55+offset;
    }
    self.tableView.rowHeight = rowHeight;
    return rowHeight;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    return self.infoList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 1;
}

- (void)btnPressedExpandClick:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSMutableDictionary *dicExpand = self.arrExpand[btn.tag];
    if ([dicExpand[@"expand"] boolValue]) {
        [dicExpand setValue:@NO forKey:@"expand"];
    } else {
        [dicExpand setValue:@YES forKey:@"expand"];
    }
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:btn.tag inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *PharmacyCommentIdentifier = @"ConsultPharmacyDetailIdentifier";
    PharmacyCommentDetailTableViewCell *cell = (PharmacyCommentDetailTableViewCell *)[atableView dequeueReusableCellWithIdentifier:PharmacyCommentIdentifier];
    if(cell == nil){
//        UINib *nib = [UINib nibWithNibName:@"PharmacyCommentDetailTableViewCell" bundle:nil];
//        [atableView registerNib:nib forCellReuseIdentifier:PharmacyCommentIdentifier];
//        cell = (PharmacyCommentDetailTableViewCell *)[atableView dequeueReusableCellWithIdentifier:PharmacyCommentIdentifier];
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PharmacyCommentDetailTableViewCell" owner:self options:nil] objectAtIndex:0];
    } else {
        
    }

    
    NSDictionary *dict = self.infoList[indexPath.row];
    NSMutableDictionary *dicExpand = self.arrExpand[indexPath.row];
    NSString *strUserName = @"";
    if ([dict[@"sysNickname"] length] > 0) {
        strUserName = dict[@"sysNickname"];
    } else if ([dict[@"nickname"] length] > 0) {
        strUserName = dict[@"nickname"];
    } else {
        strUserName = dict[@"mobile"];
    }
    cell.userName.text = strUserName;
    
//    cell.userName.text = dict[@"mobile"];
    cell.commentContent.text = dict[@"remark"];
    CGFloat offset = [self calculateCollapseHeigtOffsetWithFontSize:[UIFont systemFontOfSize:13.0] withTextSting:dict[@"remark"] withRowAtIndexPath:indexPath];
    CGRect rect = cell.commentContent.frame;
    rect.size.height = offset;//37 + offset;
    cell.commentContent.frame = rect;
    float star = [dict[@"star"] floatValue] / 2;
    [cell.ratingView displayRating:star];
    
    if ([self shouldAddExpandView:indexPath withFont:[UIFont systemFontOfSize:13.0]]) {
        cell.viewExpand.hidden = NO;
        if ([dicExpand[@"expand"] boolValue]) {
            cell.imgViewExpand.image = [UIImage imageNamed:@"UpAccessory"];
            [cell.btnExpand setTitle:@"收起" forState:UIControlStateNormal];
        } else {
            cell.imgViewExpand.image = [UIImage imageNamed:@"DownAccessory"];
            [cell.btnExpand setTitle:@"更多" forState:UIControlStateNormal];
        }
        cell.btnExpand.tag = indexPath.row;
        [cell.btnExpand addTarget:self action:@selector(btnPressedExpandClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.viewExpand.frame = CGRectMake(cell.viewExpand.frame.origin.x,
                                           cell.commentContent.frame.origin.y + cell.commentContent.frame.size.height+5.0f,
                                           cell.viewExpand.frame.size.width,
                                           cell.viewExpand.frame.size.height);
        cell.viewSeperator.frame = CGRectMake(cell.viewSeperator.frame.origin.x,
                                              cell.viewExpand.frame.origin.y + cell.viewExpand.frame.size.height + 5.0f,
                                              cell.viewSeperator.frame.size.width,
                                              1.0f);
    } else {
        cell.viewExpand.hidden = YES;
        cell.viewSeperator.frame = CGRectMake(cell.viewSeperator.frame.origin.x,
                                              cell.commentContent.frame.origin.y + cell.commentContent.frame.size.height+5.0f,
                                              cell.viewSeperator.frame.size.width,
                                              1.0f);
    }
    

    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
