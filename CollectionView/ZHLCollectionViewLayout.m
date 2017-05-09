//
//  ZHLCollectionViewLayout.m
//  BAHCollectionViewSelection
//
//  Created by 朱胡亮 on 2017/4/27.
//  Copyright © 2017年 BAH. All rights reserved.
//

#import "ZHLCollectionViewLayout.h"

@interface ZHLCollectionViewLayout()

@property (nonatomic, strong) NSMutableArray *attributes;


@end

@implementation ZHLCollectionViewLayout
{
    //总的行数
    NSInteger _row;
    //总的列数
    NSInteger _line;
    //item间距(最小值)
    CGFloat _itemSpacing;
    //行间距(最小值)
    CGFloat _lineSpacing;
    NSInteger pageNumber;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.attributes = [NSMutableArray array];
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    _row = 2;
    _line = 4;
    
    NSInteger itemNumber = 0;
    itemNumber = [self.collectionView numberOfItemsInSection:0];
    pageNumber = (itemNumber - 1)/(_row*_line) + 1;
    
}

- (CGSize)collectionViewContentSize {
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        return CGSizeMake(self.collectionView.bounds.size.width*pageNumber, self.collectionView.bounds.size.height);
    }else {
        return CGSizeMake(self.collectionView.bounds.size.width, self.collectionView.bounds.size.height*pageNumber);
    }
}




- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    @autoreleasepool {
        UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        CGRect frame;
        frame.size = self.itemSize;
        //下面计算每个cell的frame   可以自己定义
        NSInteger number = _row * _line;
        NSInteger m = 0;
        NSInteger p = 0;
        if (indexPath.item >= number) {
            p = indexPath.item/number;
            m = (indexPath.item%number)/_line;
        }else {
            m = indexPath.item/_line;
        }
        NSInteger n = indexPath.item%_line;
        
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            frame.origin = CGPointMake(n*self.itemSize.width+(n)*_itemSpacing+(p)*self.collectionView.frame.size.width, m*self.itemSize.height + (m)*_lineSpacing);
            attribute.frame = frame;
            
        }else {
            frame.origin = CGPointMake(n*self.itemSize.width + (n)*_lineSpacing, m*self.itemSize.height+(m)*_itemSpacing+(p)*self.collectionView.frame.size.height);
            attribute.frame = frame;
        }
        NSLog(@"%ld-%@",(long)indexPath.item,attribute);
        return attribute;
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray *tmpAttributes = [NSMutableArray array];
    for (int j = 0; j < self.collectionView.numberOfSections; j ++) {
        NSInteger count = [self.collectionView numberOfItemsInSection:j];
        for (NSInteger i = 0; i < count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:j];
            [tmpAttributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        }
    }
    self.attributes = tmpAttributes;
    return self.attributes;
    
    
}


/**
 重写父类的方法

 @param newBounds CGRect
 @return BOOL
 */
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    return NO;
}



@end
