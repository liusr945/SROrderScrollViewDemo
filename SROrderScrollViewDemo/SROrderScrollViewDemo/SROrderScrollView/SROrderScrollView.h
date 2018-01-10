//
//  SROrderScrollView.h
//  SROrderScrollViewDemo
//
//  Created by liusr on 2018/1/9.
//  Copyright © 2018年 liusr. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SROrderScrollView;

@protocol SROrderScrollViewDataSource <NSObject>

@required

/**
 需要显示的总列数
 */
- (NSInteger)numberOfColumnsInOrderScrollView:(SROrderScrollView *)orderScrollView;
/**
 需要显示的总行数
 */
- (NSInteger)numberOfRowsInOrderScrollView:(SROrderScrollView *)orderScrollView;

/**
 第x行x列所显示的view
 */
- (__kindof UIView *)orderScrollView:(SROrderScrollView *)orderScrollView itemInRow:(NSInteger)row column:(NSInteger)column;

@end

@protocol SROrderScrollViewDelegate <UIScrollViewDelegate>

@optional
/**
 列表单元格的尺寸(目前只支持单元格统一大小)
 */
- (CGSize)sizeOfItemInOrderScrollView:(SROrderScrollView *)orderScrollView;

- (void)orderScrollView:(SROrderScrollView *)orderScrollView didSelectRow:(NSUInteger)row column:(NSUInteger)column;

- (void)orderScrollView:(SROrderScrollView *)orderScrollView didUnselectRow:(NSUInteger)row column:(NSUInteger)column;

@end

@interface SROrderScrollView : UIScrollView

@property (nonatomic, weak) id<SROrderScrollViewDataSource>dataSource; // 必须实现

@property (nonatomic, weak) id<SROrderScrollViewDelegate>delegate;

- (void)reloadData; // 刷新视图

- (void)registerClass:(Class)aClass reuseIdentifier:(NSString *)identifier;

- (UIView *)dequeueReusableItemWithReuseIdentifier:(NSString *)identifier row:(NSInteger)row column:(NSInteger)column;


/**
 第x行x列的单元view,如果不在屏幕上，可能返回nil
 */
- (UIView *)itemViewInRow:(NSInteger)row column:(NSInteger)column;

@property (nonatomic, assign) CGFloat columnSpacing; // 列间距
@property (nonatomic, assign) CGFloat rowSpacing; // 行间距

@property (nonatomic, assign, readonly) NSInteger rows; // 总行数
@property (nonatomic, assign, readonly) NSInteger columns; // 总列数
@property (nonatomic, assign, readonly) CGSize itemSize; // 单元格大小

@end
