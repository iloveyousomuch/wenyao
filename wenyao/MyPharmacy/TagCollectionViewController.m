//
//  TagCollectionViewController.m
//  wenyao
//
//  Created by xiezhenghong on 14-10-9.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "TagCollectionViewController.h"
#import "TagCollectionView.h"
#import "TagCollectionFlowLayout.h"
#import "Constant.h"
#import "HTTPRequestManager.h"


@interface TagCollectionViewController ()<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDelegate,UITableViewDataSource,TagCollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray        *resultArray;
@property (nonatomic, strong) TagCollectionView     *tagCollectionView;

@end

@implementation TagCollectionViewController

- (void)setupSearchDisplayController
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.searchBar.backgroundColor = [UIColor clearColor];
    self.searchBar.placeholder = @"输入药品名称";
    
    self.searchDisplay = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchBar.delegate = self;
    self.searchDisplay.searchResultsDataSource = self;
    self.searchDisplay.searchResultsDelegate = self;
    [self.view addSubview:self.searchBar];
}

#pragma mark -
#pragma mark UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText.length){
        [self queryBoxByKeyword:searchText];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    
}

- (void)queryBoxByKeyword:(NSString *)keyword
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = @"2cebf3a3ed6c3c7792f1e7a70106449c";
    setting[@"currPage"] = @"1";
    setting[@"pageSize"] = @"100";
    setting[@"keyword"] = keyword;
    [[HTTPRequestManager sharedInstance] queryBoxByKeyword:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]) {
            
        }
    } failure:NULL];
    
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    self.resultArray = [NSMutableArray arrayWithCapacity:15];
    [self setupCollection];
    [self setupSearchDisplayController];
    self.resultArray = [NSMutableArray arrayWithCapacity:100];
}


#pragma mark -
#pragma mark TagCollectionViewDelegate
- (NSUInteger)numberOfItemsInCollectionView
{
    return 15;
}

- (NSString *)contentForIndexPath:(NSIndexPath *)indexPath
{
    return @"效果好";
}

- (void)collectionView:(UICollectionView *)collectionView didSelectAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.0f;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableViewCellIdentifier = @"TableViewCellIdentifier";
    UITableViewCell *cell = [atableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableViewCellIdentifier];
    }

    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

@end
