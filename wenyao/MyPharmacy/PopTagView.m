//
//  PopTagView.m
//  wenyao
//
//  Created by xiezhenghong on 14-10-24.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "PopTagView.h"
#import "Constant.h"
#import "MyPharmacyViewController.h"
#import "AppDelegate.h"
#import "Constant.h"

@implementation PopTagView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
        [self setupTableView];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
    [self setupTableView];
    self.tableView.tableFooterView = self.containerView;
}

- (void)setupTableView
{
    if (HIGH_RESOLUTION) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(20, 100, 280, 0) style:UITableViewStylePlain];
    }else{
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(20, 60, 280, 0) style:UITableViewStylePlain];
    }
    
    self.tableView.scrollEnabled = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.layer.cornerRadius = 5.0f;
    self.tableView.layer.masksToBounds = YES;
    [self.tableView setBackgroundColor:UICOLOR(242, 242, 242)];
}

- (void)setExistTagList:(NSMutableArray *)existTagList
{
    _existTagList = existTagList;
    CGRect rect = self.tableView.frame;
    rect.size.height = existTagList.count * 90 + 51;
    self.tableView.frame = rect;
    [self.tableView reloadData];
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    [aView addSubview:self];
    [self addSubview:self.tableView];
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.35;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5f, 0.5f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2f, 1.2f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95f, 0.95f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.2f, @0.4f,@0.5f, @0.7f, @0.9f,@1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.tableView.layer addAnimation:popAnimation forKey:nil];
}

- (void)dismissView
{
    CAKeyframeAnimation *hideAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    hideAnimation.duration = 0.35;
    hideAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                             [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.3f, 1.3f, 1.0f)],
                             [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0f)],
                             [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5f, 0.5f, 1.0f)],
                             [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.00f, 0.00f, 0.00f)]];
    hideAnimation.keyTimes = @[@0.2f, @0.4f,@0.6f, @0.8f, @1.0f];
    hideAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    hideAnimation.delegate = self;
    [self.tableView.layer addAnimation:hideAnimation forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.tableView removeFromSuperview];
    [self removeFromSuperview];
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0f;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    return self.existTagList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableCellIdentifier = @"DetailTableCellIdentifier";
    UITableViewCell *cell = (UITableViewCell *)[atableView dequeueReusableCellWithIdentifier:TableCellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSDictionary *dict = self.existTagList[indexPath.row];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 280, 20)];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.text = dict[@"drugTitle"];
    [cell.contentView addSubview:titleLabel];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(20, 35, 240, 1)];
    [separator setBackgroundColor:UICOLOR(220, 220, 220)];
    [cell.contentView addSubview:separator];
    
    if([dict[@"drugTitle"] isEqualToString:@"药效"]) {
        [self layoutEffectTagWithTableViewCell:cell WithTagName:dict[@"drugName"]];
    }else{
        [self layoutTableWithTableViewCell:cell WithTagName:dict[@"drugName"]];
    }
    
    return cell;
}

- (UIButton *)createTagButtonWithTitle:(NSString *)title WithIndex:(NSUInteger)index tagType:(NSUInteger)tagType withOffset:(CGFloat)offset
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13.0];
    UIImage *resizeImage = nil;
    if(tagType == 1)
    {
        //选中状态
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        resizeImage = [UIImage imageNamed:@"标签选中绿色.png"];
        resizeImage = [resizeImage resizableImageWithCapInsets:UIEdgeInsetsMake(10,10, 10,10) resizingMode:UIImageResizingModeStretch];
    }else{
        //未选中状态
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        resizeImage = [UIImage imageNamed:@"标签背景.png"];
        resizeImage = [resizeImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 5, 10, 5) resizingMode:UIImageResizingModeStretch];
    }
    CGSize size = [title sizeWithFont:button.titleLabel.font constrainedToSize:CGSizeMake(300, 20)];
    button.frame = CGRectMake(offset, 50, size.width + 2 * 10, 25);
    button.tag = index;
    [button setBackgroundImage:resizeImage forState:UIControlStateNormal];
    return button;
}

- (void)layoutEffectTagWithTableViewCell:(UITableViewCell *)cell WithTagName:(NSString *)tagName
{
    CGFloat offset = 20;
    UIButton *button = nil;
    NSUInteger index = 0;
    if([tagName isEqualToString:@"药效好"]) {
        index = 1;
    }else{
        index = 0;
    }
    button = [self createTagButtonWithTitle:@"药效好" WithIndex:1 tagType:index withOffset:offset];
    [button addTarget:self action:@selector(changeEffectTag:) forControlEvents:UIControlEventTouchDown];
    [cell.contentView addSubview:button];
    offset += button.frame.size.width + 10;
    
    if([tagName isEqualToString:@"药效差"]) {
        index = 1;
    }else{
        index = 0;
    }
    button = [self createTagButtonWithTitle:@"药效差" WithIndex:2 tagType:index withOffset:offset];
    [button addTarget:self action:@selector(changeEffectTag:) forControlEvents:UIControlEventTouchDown];
    [cell.contentView addSubview:button];
    offset += button.frame.size.width + 10;
    
    if([tagName isEqualToString:@"药效一般"]) {
        index = 1;
    }else{
        index = 0;
    }
    button = [self createTagButtonWithTitle:@"药效一般" WithIndex:3 tagType:index withOffset:offset];
    [button addTarget:self action:@selector(changeEffectTag:) forControlEvents:UIControlEventTouchDown];
    [cell.contentView addSubview:button];

}

- (void)changeEffectTag:(UIButton *)button
{
    NSString *effectTagName = nil;
    switch (button.tag) {
        case 1:
        {
            effectTagName = @"药效好";
            break;
        }
        case 2:
        {
            effectTagName = @"药效差";
            break;
        }
        case 3:
        {
            effectTagName = @"药效一般";
            break;
        }
        default:
        {
            effectTagName = nil;
            break;
        }
            
    }
    NSMutableDictionary *dict = [self.existTagList lastObject];
    dict[@"drugName"] = effectTagName;
    self.tagEffectName = effectTagName;
    [self.tableView reloadData];
}

- (void)layoutTableWithTableViewCell:(UITableViewCell *)cell WithTagName:(NSString *)tagName
{
    CGFloat offset = 20;
    UIButton *button = nil;

    button = [self createTagButtonWithTitle:tagName WithIndex:0 tagType:1 withOffset:offset];
    [cell.contentView addSubview:button];

}

#pragma mark - TouchTouchTouch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.tagEffectName = nil;
    [self dismissView];
}

- (IBAction)cancelTagView:(id)sender
{
    self.tagEffectName = nil;
    [self dismissView];
}

- (IBAction)confirmSelectTag:(id)sender
{
    [self dismissView];
    if(!self.tagEffectName)
        return;
    
    if([self.delegate respondsToSelector:@selector(popTagDidSelectedIndexPath:newTagName:)])
    {
        [self.delegate popTagDidSelectedIndexPath:[NSIndexPath indexPathForRow:self.tag inSection:0] newTagName:self.tagEffectName];
    }
    self.tagEffectName = nil;
}

@end
