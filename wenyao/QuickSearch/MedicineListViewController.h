//
//  MedicineListViewController.h
//  wenyao
//
//  Created by Meng on 14-9-28.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseTableViewController.h"

@interface MedicineListViewController : BaseTableViewController

//注:classId 与 keyWord 只能设置一个 (页面根据classId显示,或则根据keyword显示)
@property (nonatomic ,copy) NSString * classId;//有id时,调用id接口
//@property (nonatomic ,copy) NSString * viewTitle;
@property (nonatomic ,copy) NSString * keyWord;//没有id时,调用keyword接口

//如果需要右上角的生产厂家  则isShow传入1  否则0
@property (nonatomic) NSInteger isShow;

@property (nonatomic) NSString * className;

@end


@protocol TopTableViewDelegate <NSObject>

- (void)tableViewCellSelectedReturnData:(NSArray *)dataArr withClassId:(NSString *)classId withIndexPath:(NSIndexPath *)indexPath keyWord:(NSString *)keyword;

@end


@interface TopTableView : UIView<UITableViewDataSource,UITableViewDelegate>
{
    int currentPage;
    NSInteger historyRow;
    NSInteger currentRow;
}
@property (nonatomic ,strong) NSString * classId;
@property (nonatomic ,strong) NSMutableArray * dataSource;
@property (nonatomic ,strong) NSArray * dataArr;
@property (nonatomic ,strong) UITableView * mTableView;
@property (nonatomic ,weak) id<TopTableViewDelegate>delegate;
@end