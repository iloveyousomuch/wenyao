//
//  PhrmacyMoreDrugsViewController.h
//  wenyao
//
//  Created by 李坚 on 15/1/22.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"

@interface PhrmacyMoreDrugsViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) id groupId;

@end
