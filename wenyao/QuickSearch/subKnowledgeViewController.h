//
//  subKnowledgeViewController.h
//  wenyao
//
//  Created by 李坚 on 15/1/20.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"
#import "UIFolderTableView.h"

@interface subKnowledgeViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic ,strong) UINavigationController * navigationController;

@property (nonatomic, strong) NSDictionary *infoDict;
@property (nonatomic, strong) NSMutableArray *regularList;
@property (nonatomic, strong) UITableView *tableView;

@end
