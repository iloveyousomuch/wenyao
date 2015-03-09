//
//  TagCollectionFlowLayout.m
//  wenyao
//
//  Created by xiezhenghong on 14-9-18.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "TagCollectionFlowLayout.h"

@implementation TagCollectionFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.itemSize = CGSizeMake(10.f, 10.0f);
        self.minimumLineSpacing = 5.0f;
        self.minimumInteritemSpacing = 5.0f;
    }
    
    return self;
}

- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *answer = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    for(int i = 1; i < [answer count]; ++i) {
        UICollectionViewLayoutAttributes *currentLayoutAttributes = answer[i];
        UICollectionViewLayoutAttributes *prevLayoutAttributes = answer[i - 1];
        NSInteger maximumSpacing = 4;
        NSInteger origin = CGRectGetMaxX(prevLayoutAttributes.frame);
        if(origin + maximumSpacing + currentLayoutAttributes.frame.size.width < self.collectionViewContentSize.width) {
            CGRect frame = currentLayoutAttributes.frame;
            if(frame.origin.x != 15)
                frame.origin.x = origin + maximumSpacing;
            currentLayoutAttributes.frame = frame;
        }
    }
    return answer;
}

@end
