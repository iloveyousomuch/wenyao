//
//  LeveyPopListView.m
//  LeveyPopListViewDemo
//
//  Created by Levey on 2/21/12.
//  Copyright (c) 2012 Levey. All rights reserved.
//

#import "LeveyPopListView.h"
#import "LeveyPopListViewCell.h"
#import "Constant.h"

#define POPLISTVIEW_SCREENINSET 0
#define POPLISTVIEW_HEADER_HEIGHT 0
#define RADIUS 0.

@interface LeveyPopListView (private)
- (void)fadeIn;
- (void)fadeOut;
@end

@implementation LeveyPopListView
@synthesize delegate;
#pragma mark - initialization & cleaning up
- (id)initWithTitle:(NSString *)aTitle options:(NSArray *)aOptions
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.size.height -= 64;
    if (self = [super initWithFrame:rect])
    {
        _selectedIndex = -1;
        self.backgroundColor = [UIColor clearColor];
        _title = [aTitle copy];
        _options = [aOptions copy];
        
        
        CGFloat tableViewHeight = 0.0f;
        
        if(aOptions.count > 5) {
            tableViewHeight = 5 * 44;
        }else{
            tableViewHeight = aOptions.count * 44;
        }
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                   rect.size.height - tableViewHeight,
                                                                   rect.size.width - 2 * POPLISTVIEW_SCREENINSET,
                                                                   tableViewHeight)];
        _tableView.separatorColor = UICOLOR(219, 219, 219);
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self addSubview:_tableView];

    }
    return self;    
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    [_tableView reloadData];
}

- (void)dealloc
{
    [_title release];
    [_options release];
    [_tableView release];
    [super dealloc];
}

#pragma mark - Private Methods
- (void)fadeIn
{
    __block CGRect rect = _tableView.frame;
    rect.origin.y += rect.size.height;
    _tableView.frame = rect;
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        rect = _tableView.frame;
        rect.origin.y -= rect.size.height;
        _tableView.frame = rect;
    }];
}

- (void)fadeOut
{
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 0.0;
        CGRect rect = _tableView.frame;
        rect.origin.y += rect.size.height;
        _tableView.frame = rect;
        
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - Instance Methods
- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    [aView addSubview:self];
    if (animated) {
        [self fadeIn];
    }
}

#pragma mark - Tableview datasource & delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_options count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"PopListViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (cell ==  nil) {
        cell = [[[LeveyPopListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity] autorelease];
    }
    NSString *title = _options[indexPath.row];
    cell.textLabel.text = title;
    
    if(indexPath.row == self.selectedIndex) {
        cell.textLabel.textColor = APP_COLOR_STYLE;
        UIImageView *accessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
        [accessoryView setImage:[UIImage imageNamed:@"选中的勾.png"]];
        cell.accessoryView = accessoryView;
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
        cell.accessoryView = nil;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // tell the delegate the selection
    if (self.delegate && [self.delegate respondsToSelector:@selector(leveyPopListView:didSelectedIndex:)]) {
        [self.delegate leveyPopListView:self didSelectedIndex:[indexPath row]];
    }
    
    // dismiss self
    [self fadeOut];
}
#pragma mark - TouchTouchTouch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // tell the delegate the cancellation
    if (self.delegate && [self.delegate respondsToSelector:@selector(leveyPopListViewDidCancel)]) {
        [self.delegate leveyPopListViewDidCancel];
    }
    
    // dismiss self
    [self fadeOut];
}

//#pragma mark - DrawDrawDraw
//- (void)drawRect:(CGRect)rect
//{
//    CGRect bgRect = CGRectInset(rect, POPLISTVIEW_SCREENINSET, POPLISTVIEW_SCREENINSET);
//    CGRect titleRect = CGRectMake(POPLISTVIEW_SCREENINSET + 10, POPLISTVIEW_SCREENINSET + 10 + 5,
//                                  rect.size.width -  2 * (POPLISTVIEW_SCREENINSET + 10), 30);
//    CGRect separatorRect = CGRectMake(POPLISTVIEW_SCREENINSET, POPLISTVIEW_SCREENINSET + POPLISTVIEW_HEADER_HEIGHT - 2,
//                                      rect.size.width - 2 * POPLISTVIEW_SCREENINSET, 2);
//    
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    
//    // Draw the background with shadow
//    CGContextSetShadowWithColor(ctx, CGSizeZero, 6., [UIColor colorWithWhite:0 alpha:.75].CGColor);
//    [[UIColor colorWithWhite:0 alpha:.75] setFill];
//    
//    
//    float x = POPLISTVIEW_SCREENINSET;
//    float y = POPLISTVIEW_SCREENINSET;
//    float width = bgRect.size.width;
//    float height = bgRect.size.height;
//    CGMutablePathRef path = CGPathCreateMutable();
//	CGPathMoveToPoint(path, NULL, x, y + RADIUS);
//	CGPathAddArcToPoint(path, NULL, x, y, x + RADIUS, y, RADIUS);
//	CGPathAddArcToPoint(path, NULL, x + width, y, x + width, y + RADIUS, RADIUS);
//	CGPathAddArcToPoint(path, NULL, x + width, y + height, x + width - RADIUS, y + height, RADIUS);
//	CGPathAddArcToPoint(path, NULL, x, y + height, x, y + height - RADIUS, RADIUS);
//	CGPathCloseSubpath(path);
//	CGContextAddPath(ctx, path);
//    CGContextFillPath(ctx);
//    CGPathRelease(path);
//    
//    // Draw the title and the separator with shadow
//    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0.5f, [UIColor blackColor].CGColor);
//    [[UIColor colorWithRed:0.020 green:0.549 blue:0.961 alpha:1.] setFill];
//    [_title drawInRect:titleRect withFont:[UIFont systemFontOfSize:16.]];
//    CGContextFillRect(ctx, separatorRect);
//}

@end
