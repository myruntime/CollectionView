//
//  ZHLCollectionViewCell.m
//  BAHCollectionViewSelection
//
//  Created by 朱胡亮 on 2017/4/27.
//  Copyright © 2017年 BAH. All rights reserved.
//

#import "ZHLCollectionViewCell.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation ZHLCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.collectionItem];
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = UIColorFromRGB(0xEAEAEA).CGColor;
//        self.layer.masksToBounds = YES;

    }
    return self;
}


- (ZHLCollectionItem *)collectionItem {
    if (!_collectionItem) {
        _collectionItem = [[ZHLCollectionItem alloc] initWithFrame:self.bounds];
        _collectionItem.userInteractionEnabled = YES;
    }
    return _collectionItem;
}

- (void)setDragging:(BOOL)dragging {
    [super setDragging:dragging];
    if (dragging) {
        self.collectionItem.backgroundColor = [UIColor grayColor];
//        self.collectionItem.transform = CGAffineTransformMakeScale(1.1, 1.1);
    }else {
        self.collectionItem.backgroundColor = [UIColor whiteColor];
//        self.collectionItem.transform = CGAffineTransformIdentity;
    }
}

@end



