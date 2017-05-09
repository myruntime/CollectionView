//
//  RearrangeableCollectionViewCell.m
//  shangqizhizao
//
//  Created by 朱胡亮 on 2017/5/8.
//  Copyright © 2017年 ZHL. All rights reserved.
//

#import "RearrangeableCollectionViewCell.h"

@implementation RearrangeableCollectionViewCell

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

}



- (void)setDragging:(BOOL)dragging {
    _dragging = dragging;
}

@end
