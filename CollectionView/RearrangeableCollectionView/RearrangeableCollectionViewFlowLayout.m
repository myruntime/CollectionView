//
//  RearrangeableCollectionViewFlowLayout.m
//  shangqizhizao
//
//  Created by 朱胡亮 on 2017/5/8.
//  Copyright © 2017年 ZHL. All rights reserved.
//

#import "RearrangeableCollectionViewFlowLayout.h"
#import "RearrangeableCollectionViewCell.h"

#pragma mark <Bundle>
@interface Bundle : NSObject
@property (nonatomic, assign) CGPoint offset;
@property (nonatomic, strong) RearrangeableCollectionViewCell *sourceCell;
@property (nonatomic, strong) UIView *representationImageView;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@end

@implementation Bundle

- (NSString *)description {
    return [NSString stringWithFormat:@"offset-%@-sourceCell-%@-representationImageView-%@-currentIndexPath-%@",NSStringFromCGPoint(_offset),_sourceCell,_representationImageView,_currentIndexPath];
}

@end



#define angelToRandian(x) ((x)/180.0*M_PI)

#pragma mark <RearrangeableCollectionViewFlowLayout>
@interface RearrangeableCollectionViewFlowLayout ()
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecogniser;
@property (nonatomic, strong) Bundle *bundle;



@end

@implementation RearrangeableCollectionViewFlowLayout
{
    //设置换页移动边距
    CGFloat rangeOffset;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
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
    [self setup];
}

- (void)setCanvas:(UIView *)canvas {
    _canvas = canvas;
    [self calculateBorders];
    if (self.collectionView) {
        [self.collectionView addGestureRecognizer:self.longPressGestureRecogniser];
    }
}

- (void)setup {
    self.animating = NO;
    self.draggable = NO;
    self.collectionViewFrameInCanvas = CGRectZero;
    self.hitTestRectagles = [NSMutableDictionary dictionary];
    self.dragaxis = Dragfree;
    rangeOffset = 20;
    
}

- (UILongPressGestureRecognizer *)longPressGestureRecogniser {
    if (!_longPressGestureRecogniser) {
        _longPressGestureRecogniser = [[UILongPressGestureRecognizer alloc] init];
        _longPressGestureRecogniser.delegate = self;
        _longPressGestureRecogniser.minimumPressDuration = 0.5f;
        [_longPressGestureRecogniser addTarget:self action:@selector(handleGesture:)];
    }
    return _longPressGestureRecogniser;
}

- (void)prepareLayout {
    [super prepareLayout];
//    [self calculateBorders];
}

- (void)calculateBorders {
    if (self.collectionView) {
        self.collectionViewFrameInCanvas = self.collectionView.frame;
        if (self.canvas != self.collectionView.superview) {
            self.collectionViewFrameInCanvas = [self.canvas convertRect:self.collectionViewFrameInCanvas fromView:self.collectionView];
        }
        
        
        CGRect leftRect = self.collectionViewFrameInCanvas;
        leftRect.origin.x = -1*rangeOffset;
        leftRect.size.width = rangeOffset;
        [self.hitTestRectagles setValue:NSStringFromCGRect(leftRect) forKey:@"left"];
        
        CGRect topRect = self.collectionViewFrameInCanvas;
        topRect.origin.y = -1*rangeOffset;
        topRect.size.height = rangeOffset;
        [self.hitTestRectagles setValue:NSStringFromCGRect(topRect) forKey:@"top"];
        
        CGRect rightRect = self.collectionViewFrameInCanvas;
        rightRect.origin.x = rightRect.size.width + rangeOffset;
        rightRect.size.width = rangeOffset;
        [self.hitTestRectagles setValue:NSStringFromCGRect(rightRect) forKey:@"right"];
        
        CGRect bottomRect = self.collectionViewFrameInCanvas;
        bottomRect.origin.y = bottomRect.origin.y + rightRect.size.height + rangeOffset;
        bottomRect.size.height = rangeOffset;
        [self.hitTestRectagles setValue:NSStringFromCGRect(bottomRect) forKey:@"bottom"];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.draggable == NO) return NO;
    if (self.canvas == nil) return NO;
    if (self.collectionView == nil) return NO;
    CGPoint pointPressedInCanvas = [gestureRecognizer locationInView:self.canvas];
    for (RearrangeableCollectionViewCell *cell in self.collectionView.visibleCells) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        if (indexPath) {
            CGRect cellInCanvasFrame = [self.canvas convertRect:cell.frame fromView:self.collectionView];
            if (CGRectContainsPoint(cellInCanvasFrame, pointPressedInCanvas)) {

                self.kddelegate = (id)self.collectionView.delegate;
                if ([self.kddelegate respondsToSelector:@selector(canMoveItemAt:)]) {
                    if ([self.kddelegate canMoveItemAt:indexPath] == NO) return NO;
                }
                cell.dragging = YES;
                
                UIGraphicsBeginImageContextWithOptions(cell.bounds.size, cell.isOpaque, 2.0);
                [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                UIImageView *representationImage = [[UIImageView alloc] initWithImage:img];
                representationImage.frame = cellInCanvasFrame;
                CGPoint offset = CGPointMake(pointPressedInCanvas.x - cellInCanvasFrame.origin.x, pointPressedInCanvas.y - cellInCanvasFrame.origin.y);
                self.bundle = [[Bundle alloc] init];
                self.bundle.offset = offset;
                self.bundle.sourceCell = cell;
                self.bundle.representationImageView = representationImage;
                self.bundle.currentIndexPath = indexPath;
            }
        }
    }
    return (self.bundle != nil);
}
- (void)checkForDraggingAtTheEdgeAndAnimatePaging:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (self.animating) return;
    if (self.bundle) {
        CGRect nextPageRect = self.collectionView.bounds;
        //水平
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            NSString *leftvalue = [self.hitTestRectagles objectForKey:@"left"];
            NSString *rightvalue = [self.hitTestRectagles objectForKey:@"right"];
            if (CGRectIntersectsRect(self.bundle.representationImageView.frame, CGRectFromString(leftvalue))) {
                nextPageRect.origin.x -= nextPageRect.size.width;
                if (nextPageRect.origin.x < 0.0) {
                    nextPageRect.origin.x = 0.0;
                }
            }
            else if (CGRectIntersectsRect(self.bundle.representationImageView.frame, CGRectFromString(rightvalue))) {
                nextPageRect.origin.x += nextPageRect.size.width;
                if (nextPageRect.origin.x + nextPageRect.size.width > self.collectionView.contentSize.width) {
                    nextPageRect.origin.x = self.collectionView.contentSize.width - nextPageRect.size.width;
                }
            }
        }
        //竖直
        else if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            NSString *topvalue = [self.hitTestRectagles objectForKey:@"top"];
            NSString *bottomvalue = [self.hitTestRectagles objectForKey:@"bottom"];
            if (CGRectIntersectsRect(self.bundle.representationImageView.frame, CGRectFromString(topvalue))) {
                nextPageRect.origin.y -= nextPageRect.size.height;
                if (nextPageRect.origin.y < 0.0) {
                    nextPageRect.origin.y = 0.0;
                }
            }
            else if (CGRectIntersectsRect(self.bundle.representationImageView.frame, CGRectFromString(bottomvalue))) {
                nextPageRect.origin.y += nextPageRect.size.height;
                if (nextPageRect.origin.y + nextPageRect.size.height > self.collectionView.contentSize.height) {
                    nextPageRect.origin.y = self.collectionView.contentSize.height - nextPageRect.size.height;
                }
            }
        }
        if (!CGRectEqualToRect(nextPageRect, self.collectionView.bounds)) {
            __weak __typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.animating = NO;
//                [weakSelf handleGesture:gestureRecognizer];
            });
            self.animating = YES;
            [self.collectionView scrollRectToVisible:nextPageRect animated:YES];
        }
    }
    
}
- (void)handleGesture:(UILongPressGestureRecognizer *)gesture {
    if (!self.bundle) return;
    CGPoint dragPointOnCanvas = [gesture locationInView:self.canvas];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            self.bundle.sourceCell.hidden = YES;
            [self.canvas addSubview:self.bundle.representationImageView];
            CGRect imageViewFrame = self.bundle.representationImageView.frame;
            CGPoint point = CGPointZero;
            point.x = dragPointOnCanvas.x - self.bundle.offset.x;
            point.y = dragPointOnCanvas.y - self.bundle.offset.y;
            imageViewFrame.origin = point;
            self.bundle.representationImageView.frame = imageViewFrame;
            self.bundle.representationImageView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        }
            break;
        case UIGestureRecognizerStateChanged: {
            
            CGRect imageViewFrame = self.bundle.representationImageView.frame;
            CGPoint point = CGPointMake(dragPointOnCanvas.x - self.bundle.offset.x, dragPointOnCanvas.y - self.bundle.offset.y);
            // 限制y的移动范围
            if (point.y > self.collectionView.frame.size.height/2 + rangeOffset) point.y = self.collectionView.frame.size.height/2 + rangeOffset;
            if (point.y < - rangeOffset) point.y = - rangeOffset;
            imageViewFrame.origin = point;

            NSLog(@"%@-%@",NSStringFromCGRect(imageViewFrame),NSStringFromCGPoint(self.bundle.offset));
            self.bundle.representationImageView.frame = imageViewFrame;
            CGPoint dragPointOnCollectionView = [gesture locationInView:self.collectionView];
            
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:dragPointOnCollectionView];

            //个别不准移动
            if (indexPath && [self.kddelegate canMoveItemAt:indexPath]) {
                
                if (![indexPath isEqual: self.bundle.currentIndexPath]) {
                    self.kddelegate = (id)self.collectionView.delegate;
                    if ([self.kddelegate respondsToSelector:@selector(moveDataItemFrom:to:)]) {
                        [self.kddelegate moveDataItemFrom:self.bundle.currentIndexPath to:indexPath];
                    }
                    [self.collectionView moveItemAtIndexPath:self.bundle.currentIndexPath toIndexPath:indexPath];
                    self.bundle.currentIndexPath = indexPath;
                }
                //选中的cell隐藏
                RearrangeableCollectionViewCell *cell = (RearrangeableCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                self.bundle.sourceCell.hidden = NO;
                self.bundle.sourceCell.dragging = NO;
                self.bundle.sourceCell = cell;
                self.bundle.sourceCell.hidden = YES;
                [self checkForDraggingAtTheEdgeAndAnimatePaging:gesture];
            }  
        }
            break;
        case UIGestureRecognizerStateEnded: {
            [self endDraggingAction];
            NSLog(@"UIGestureRecognizerStateEnded");
        }
            break;
        case UIGestureRecognizerStateCancelled: {
            [self endDraggingAction];
            NSLog(@"UIGestureRecognizerStateCancelled");
        }
            break;
        case UIGestureRecognizerStateFailed: {
            [self endDraggingAction];
            NSLog(@"UIGestureRecognizerStateFailed");
        }
            break;
        case UIGestureRecognizerStatePossible: {
            NSLog(@"UIGestureRecognizerStatePossible");
        }
            break;
    }
}

- (void)endDraggingAction {
    __weak __typeof(self) weakSelf = self;
    weakSelf.bundle.sourceCell.hidden = NO;
    weakSelf.bundle.sourceCell.dragging = NO;
    [UIView animateWithDuration:0.15 animations:^{
        weakSelf.bundle.representationImageView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [weakSelf.bundle.representationImageView removeFromSuperview];
        weakSelf.bundle = nil;
        NSLog(@"%@",weakSelf.bundle);
    }];
    
//    [self.collectionView reloadData];
    
}

/**
 * 动画幅度
 */

- (void)gestureRecognizerStateEndedAnimation {
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.4 animations:^{
        weakSelf.bundle.representationImageView.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        [weakSelf setCellCAKeyframeAnimation:weakSelf.bundle.sourceCell];
    }];
}

- (void)setCellCAKeyframeAnimation:(UIView *)view {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"transform.rotation";
    animation.values = @[@(angelToRandian(-1)),@(angelToRandian(1)),@(angelToRandian(-1))];
    animation.repeatCount = MAXFLOAT;
    animation.duration = 0.25;
    animation.fillMode = kCAFillModeBackwards;
    view.layer.speed = 1.0;
    [view.layer addAnimation:animation forKey:@"cell"];
}


@end
