//
//  TagCollectionView.m
//  wenyao
//
//  Created by xiezhenghong on 14-9-18.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "TagCollectionView.h"
#import "TagCollectionViewCell.h"
#import "Constant.h"

@implementation TagCollectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    [self registerClass:[TagCollectionViewCell class] forCellWithReuseIdentifier:@"TagCollectionViewCellIdentifier"];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"HeaderCollectionViewCellIdentifier"];
    
    
    self.dataSource = self;
    self.delegate = self;
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

#define kMaxCellSpacing 9


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* currentItemAttributes =
    [super layoutAttributesForItemAtIndexPath:indexPath];
    
    UIEdgeInsets sectionInset = [(UICollectionViewFlowLayout *)self.collectionViewLayout sectionInset];
    
    if (indexPath.item == 0) { // first item of section
        CGRect frame = currentItemAttributes.frame;
        frame.origin.x = sectionInset.left; // first item of the section should always be left aligned
        currentItemAttributes.frame = frame;
        
        return currentItemAttributes;
    }
    
    NSIndexPath* previousIndexPath = [NSIndexPath indexPathForItem:indexPath.item-1 inSection:indexPath.section];
    CGRect previousFrame = [self layoutAttributesForItemAtIndexPath:previousIndexPath].frame;
    
    CGFloat previousFrameRightPoint = previousFrame.origin.x + previousFrame.size.width + kMaxCellSpacing;
    
    CGRect currentFrame = currentItemAttributes.frame;
    CGRect strecthedCurrentFrame = CGRectMake(0,
                                              currentFrame.origin.y,
                                              self.frame.size.width,
                                              currentFrame.size.height);
    
    if (!CGRectIntersectsRect(previousFrame, strecthedCurrentFrame)) { // if current item is the first item on the line
        // the approach here is to take the current frame, left align it to the edge of the view
        // then stretch it the width of the collection view, if it intersects with the previous frame then that means it
        // is on the same line, otherwise it is on it's own new line
        CGRect frame = currentItemAttributes.frame;
        frame.origin.x = sectionInset.left; // first item on the line should always be left aligned
        currentItemAttributes.frame = frame;
        return currentItemAttributes;
    }
    
    CGRect frame = currentItemAttributes.frame;
    frame.origin.x = previousFrameRightPoint;
    currentItemAttributes.frame = frame;
    return currentItemAttributes;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(section == 1) {
        if([self.collectionDelegate respondsToSelector:@selector(numberOfItemsInCollectionView)])
            return [self.collectionDelegate numberOfItemsInCollectionView];
        else
            return 0;
    }else{
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1) {
        TagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TagCollectionViewCellIdentifier" forIndexPath:indexPath];
        NSString *content = @"";
        if([self.collectionDelegate respondsToSelector:@selector(contentForIndexPath:)]){
            content = [self.collectionDelegate contentForIndexPath:indexPath];
        }
        [cell setTagName:content];
        return cell;
    }else{
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HeaderCollectionViewCellIdentifier" forIndexPath:indexPath];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
        label.textColor = UICOLOR(102, 102, 102);
        label.font = [UIFont systemFontOfSize:14.0f];
        label.text = @"通过标签筛选";
        [cell.contentView addSubview:label];
        return cell;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([self.collectionDelegate respondsToSelector:@selector(collectionView:didSelectAtIndexPath:)]){
        [self.collectionDelegate collectionView:self didSelectAtIndexPath:indexPath];
    }
    

}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1) {
        NSString *content = @"";
        if([self.collectionDelegate respondsToSelector:@selector(contentForIndexPath:)]){
            content = [self.collectionDelegate contentForIndexPath:indexPath];
        }
        CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(300, 25)];
        size.height = 25;
        size.width += 20;
        return size;
    }else{
        return CGSizeMake(0, 10);
    }
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 15, 10, 15);
}


@end
