//
//  ZHLCollectionButton.m
//  BAHCollectionViewSelection
//
//  Created by 朱胡亮 on 2017/4/27.
//  Copyright © 2017年 BAH. All rights reserved.
//

#import "ZHLCollectionItem.h"


@implementation ZHLCollectionItem

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.itemImageView];
        [self addSubview:self.itemTitleLable];
    }
    return self;
}

- (UIImageView *)itemImageView {
    if (!_itemImageView) {
        CGFloat h = self.frame.size.height * 0.5;
        CGFloat w = h;
        CGFloat x = (self.frame.size.width - w) * 0.5;
        CGFloat y = self.frame.size.height * 0.15;
        _itemImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        _itemImageView.userInteractionEnabled = YES;
    }
    return _itemImageView;
}

- (UILabel *)itemTitleLable {
    if (!_itemTitleLable) {
        _itemTitleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height * 0.65, self.frame.size.width, self.frame.size.height * 0.3)];
        _itemTitleLable.textColor = [UIColor blackColor];
        _itemTitleLable.font = [UIFont systemFontOfSize:13];
        _itemTitleLable.textAlignment = NSTextAlignmentCenter;
        _itemTitleLable.userInteractionEnabled = YES;
    }
    return _itemTitleLable;
}
@end
