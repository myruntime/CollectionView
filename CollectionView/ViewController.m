//
//  ViewController.m
//  CollectionView
//
//  Created by 朱胡亮 on 2017/5/8.
//  Copyright © 2017年 SAIC. All rights reserved.
//

#import "ViewController.h"
#import "ZHLCollectionViewCell.h"
#import "ZHLCollectionViewLayout.h"

#define kLineSpacing 0
#define kInteritemSpacing 0
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


static NSString *kCellID = @"kCellID";

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,KDRearrangeableCollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *data;
@end

@implementation ViewController
{
     ZHLCollectionViewLayout *layout;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    layout.canvas = self.collectionView.superview;
    layout.draggable = YES;
    layout.dragaxis = Dragfree;
}

- (NSArray *)data {
    if (!_data) {
        _data = [NSMutableArray array];
        for (int i = 0; i < 50; i++) {
            [_data addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    return _data;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return self.data.count;
    //一行放 4 个，一页共 8 个，算出排满的数值，算出分页个数
    NSInteger pageCounter = self.data.count+1;
    while (pageCounter % 8 != 0) {
        ++pageCounter;
    }
    return pageCounter;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item < self.data.count) {
        ZHLCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
        cell.collectionItem.itemTitleLable.text = self.data[indexPath.item];
        return cell;
    }else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
//        cell.collectionItem.itemTitleLable.text = [NSString stringWithFormat:@"%ld",indexPath.item];
        cell.backgroundColor = [UIColor greenColor];
        return cell;
    }
    
}

- (BOOL)canMoveItemAt:(NSIndexPath *)indexPath {
    if (indexPath.item < 4 || indexPath.item >= self.data.count) {
        return NO;
    }
    return YES;
}

- (void)moveDataItemFrom:(NSIndexPath *)source to:(NSIndexPath *)destination {
    NSString *str = self.data[source.item];
    [self.data removeObjectAtIndex:source.item];
    [self.data insertObject:str atIndex:destination.item];
}

#pragma mark - getters and setters
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        layout = [[ZHLCollectionViewLayout alloc] init];
        layout.minimumLineSpacing = kLineSpacing;
        layout.minimumInteritemSpacing = kInteritemSpacing;
        layout.itemSize = CGSizeMake((kScreenWidth-3*kLineSpacing)/4, (kScreenWidth-3*kLineSpacing)/4);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, (kScreenWidth-3*kLineSpacing)/2) collectionViewLayout:layout];
//        layout.sectionInset = UIEdgeInsetsMake(1, 1, 1, 1);
        
        _collectionView.bounces = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = UIColorFromRGB(0xEAEAEA);;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        [_collectionView registerClass:[ZHLCollectionViewCell class] forCellWithReuseIdentifier:kCellID];
    }
    return _collectionView;
}



@end
