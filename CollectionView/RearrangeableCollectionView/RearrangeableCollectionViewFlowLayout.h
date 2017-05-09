//
//  RearrangeableCollectionViewFlowLayout.h
//  shangqizhizao
//
//  Created by 朱胡亮 on 2017/5/8.
//  Copyright © 2017年 ZHL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDRearrangeableCollectionViewDelegate <UICollectionViewDelegate>
- (BOOL)canMoveItemAt:(NSIndexPath *)indexPath;
- (void)moveDataItemFrom:(NSIndexPath *)source to:(NSIndexPath *)destination;


@end


typedef NS_ENUM(NSInteger, KDDraggingAxis) {
    Dragfree = 0,
    Dragx,
    Dragy,
    Dragxy
};

@interface RearrangeableCollectionViewFlowLayout : UICollectionViewFlowLayout <UIGestureRecognizerDelegate>

@property (nonatomic) BOOL animating;
@property (nonatomic) BOOL draggable;
@property (nonatomic) CGRect collectionViewFrameInCanvas;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *hitTestRectagles;
@property (nonatomic, strong) UIView *canvas;
@property (nonatomic, weak) id<KDRearrangeableCollectionViewDelegate> kddelegate;
@property (nonatomic, assign) KDDraggingAxis dragaxis;


- (instancetype)init;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (void)awakeFromNib;
- (void)setup;
- (void)prepareLayout;
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;
- (void)checkForDraggingAtTheEdgeAndAnimatePaging:(UILongPressGestureRecognizer *)gestureRecognizer;
- (void)handleGesture:(UILongPressGestureRecognizer *)gesture;

@end


