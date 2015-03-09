//
//  PopTagView.h
//  wenyao
//
//  Created by xiezhenghong on 14-10-24.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopTagViewDelegate <NSObject>

- (void)popTagDidSelectedIndexPath:(NSIndexPath *)indexPath
                        newTagName:(NSString *)tagName;

@end



@interface PopTagView : UIView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray    *existTagList;
@property (nonatomic ,strong) UITableView       *tableView;
@property (nonatomic, strong) NSString          *tagEffectName;
@property (nonatomic ,strong) IBOutlet UIView   *containerView;
@property (nonatomic, assign) id<PopTagViewDelegate>    delegate;
- (void)showInView:(UIView *)aView animated:(BOOL)animated;
- (void)dismissView;

@end
