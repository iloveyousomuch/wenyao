//
//  TagCollectionView.h
//  wenyao
//
//  Created by xiezhenghong on 14-9-18.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TagCollectionViewDelegate <UICollectionViewDelegate>
@optional


- (NSUInteger)numberOfItemsInCollectionView;
- (NSString *)contentForIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView didSelectAtIndexPath:(NSIndexPath *)indexPath;


@end

@interface TagCollectionView : UICollectionView<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, assign) id<TagCollectionViewDelegate>    collectionDelegate;


@end
