//
//  SROrderScrollView.m
//  SROrderScrollViewDemo
//
//  Created by liusr on 2018/1/9.
//  Copyright © 2018年 liusr. All rights reserved.
//

#import "SROrderScrollView.h"

const CGFloat SROrderScrollViewItemDefaultWidth = 45;
const CGFloat SROrderScrollViewItemDefaultHeight = 30;

@interface SROrderScrollView ()

@property (nonatomic, strong) NSMutableDictionary *itemsFrameDict; // 所有item的frame

@property (nonatomic, strong) NSMutableDictionary *registerClassDict;

@property (nonatomic, strong) NSMutableArray *reuseViewArray;

@end

@implementation SROrderScrollView

@dynamic delegate;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.directionalLockEnabled = YES;
    self.bounces = NO;
    if (@available(iOS 11, *)) {
        [self setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.directionalLockEnabled = YES;
        self.bounces = NO;
        if (@available(iOS 11, *)) {
            [self setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        }
    }
    return self;
}

- (NSMutableDictionary *)registerClassDict {
    if (!_registerClassDict) {
        _registerClassDict = [NSMutableDictionary dictionary];
    }
    return _registerClassDict;
}

- (NSMutableArray *)reuseViewArray {
    if (!_reuseViewArray) {
        _reuseViewArray = [NSMutableArray array];
    }
    return _reuseViewArray;
}

- (NSMutableDictionary *)itemsFrameDict {
    if (!_itemsFrameDict) {
        _itemsFrameDict = [NSMutableDictionary dictionary];
    }
    return _itemsFrameDict;
}

- (void)registerClass:(Class)aClass reuseIdentifier:(NSString *)identifier {
    [self.registerClassDict setObject:aClass forKey:identifier];
}

- (UIView *)dequeueReusableItemWithReuseIdentifier:(NSString *)identifier row:(NSInteger)row column:(NSInteger)column {
    UIView *view = nil;
    if (!self.reuseViewArray.count) {
        id obj = [self.registerClassDict objectForKey:identifier];
        view = [[(Class)obj alloc] initWithFrame:CGRectZero];
    } else {
        view = self.reuseViewArray.lastObject;
        [self.reuseViewArray removeLastObject];
    }
    return view;
}

- (void)reloadData {
    _rows = [self.dataSource numberOfRowsInOrderScrollView:self];
    _columns = [self.dataSource numberOfColumnsInOrderScrollView:self];
    CGSize itemSize = CGSizeMake(SROrderScrollViewItemDefaultWidth, SROrderScrollViewItemDefaultWidth);
    if ([self.delegate respondsToSelector:@selector(sizeOfItemInOrderScrollView:)]) {
        itemSize = [self.delegate sizeOfItemInOrderScrollView:self];
    }
    _itemSize = itemSize;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.itemsFrameDict removeAllObjects];
    
    for (NSInteger i = 0; i < _rows; i++) {
        for (NSInteger j = 0; j < _columns; j++) {
            NSInteger itemKey = 10000*i + j;
            CGRect itemRect = CGRectMake((itemSize.width + self.columnSpacing)*j, (itemSize.height + self.rowSpacing)*i, itemSize.width, itemSize.height);
            [self.itemsFrameDict setObject:[NSValue valueWithCGRect:itemRect] forKey:@(itemKey)];
        }
    }
    
    self.contentSize = CGSizeMake((self.columnSpacing + itemSize.width)*_columns - self.columnSpacing , (self.rowSpacing + itemSize.height)*_rows - self.rowSpacing);
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    if (_rows == 0 || _columns == 0) {
        return;
    }
    CGRect shoulShowRect = CGRectMake(self.contentOffset.x, self.contentOffset.y, self.bounds.size.width, self.bounds.size.height);
    for (NSNumber *keyNumber in self.itemsFrameDict.allKeys) {
        NSInteger row = [keyNumber integerValue]/10000;
        NSInteger column = [keyNumber integerValue]%10000;
        CGRect itemFrame = [[self.itemsFrameDict objectForKey:keyNumber] CGRectValue];
        UIView *itemView = [self itemViewInRow:row column:column];
        if (CGRectIntersectsRect(shoulShowRect, itemFrame)) {
            if (itemView == nil) {
                itemView = [self.dataSource orderScrollView:self itemInRow:row column:column];
                itemView.frame = itemFrame;
                [self addSubview:itemView];
            }
        } else if (itemView) {
            [self.reuseViewArray addObject:itemView];
            [itemView removeFromSuperview];
        }
    }
    
}

- (UIView *)itemViewInRow:(NSInteger)row column:(NSInteger)column {
    if (!self.subviews.count) {
        return nil;
    }
    NSInteger keyNumber = 10000*row + column;
    CGRect itemFrame = [[self.itemsFrameDict objectForKey:@(keyNumber)] CGRectValue];
    for (UIView *subview in self.subviews) {
        if (CGRectEqualToRect(subview.frame, itemFrame)) {
            return subview;
        }
    }
    return nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint locatePoint = [[touches anyObject] locationInView:self];
    for (NSNumber *keyNumber in self.itemsFrameDict.allKeys) {
        NSInteger row = [keyNumber integerValue]/10000;
        NSInteger column = [keyNumber integerValue]%10000;
        CGRect itemFrame = [[self.itemsFrameDict objectForKey:keyNumber] CGRectValue];
        if (CGRectContainsPoint(itemFrame, locatePoint)) {
            UIView *itemView = [self itemViewInRow:row column:column];
            if (itemView.userInteractionEnabled == NO) {
                return;
            }
            if ([self.delegate respondsToSelector:@selector(orderScrollView:didSelectRow:column:)]) {
                [self.delegate orderScrollView:self didSelectRow:row column:column];
            }
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint locatePoint = [[touches anyObject] locationInView:self];
    for (NSNumber *keyNumber in self.itemsFrameDict.allKeys) {
        NSInteger row = [keyNumber integerValue]/10000;
        NSInteger column = [keyNumber integerValue]%10000;
        CGRect itemFrame = [[self.itemsFrameDict objectForKey:keyNumber] CGRectValue];
        if (CGRectContainsPoint(itemFrame, locatePoint)) {
            UIView *itemView = [self itemViewInRow:row column:column];
            if (itemView.userInteractionEnabled == NO) {
                return;
            }
            if ([self.delegate respondsToSelector:@selector(orderScrollView:didUnselectRow:column:)]) {
                [self.delegate orderScrollView:self didUnselectRow:row column:column];
            }
        }
    }
    
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint locatePoint = [[touches anyObject] locationInView:self];
    for (NSNumber *keyNumber in self.itemsFrameDict.allKeys) {
        NSInteger row = [keyNumber integerValue]/10000;
        NSInteger column = [keyNumber integerValue]%10000;
        CGRect itemFrame = [[self.itemsFrameDict objectForKey:keyNumber] CGRectValue];
        if (CGRectContainsPoint(itemFrame, locatePoint)) {
            UIView *itemView = [self itemViewInRow:row column:column];
            if (itemView.userInteractionEnabled == NO) {
                return;
            }
            if ([self.delegate respondsToSelector:@selector(orderScrollView:didUnselectRow:column:)]) {
                [self.delegate orderScrollView:self didUnselectRow:row column:column];
            }
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}




@end
