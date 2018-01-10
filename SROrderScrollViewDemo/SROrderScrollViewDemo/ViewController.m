//
//  ViewController.m
//  SROrderScrollViewDemo
//
//  Created by liusr on 2018/1/9.
//  Copyright © 2018年 liusr. All rights reserved.
//

#import "ViewController.h"
#import "SROrderScrollView.h"

static NSInteger totalRows = 10;
static NSInteger totalColumns = 10;

@interface ViewController () <SROrderScrollViewDataSource,SROrderScrollViewDelegate>

@property (weak, nonatomic) IBOutlet SROrderScrollView *orderScrollView;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self requestData];
}

- (void)initUI {
    self.orderScrollView.columnSpacing = 2.f;
    self.orderScrollView.rowSpacing = 2.f;
    self.orderScrollView.dataSource = self;
    self.orderScrollView.delegate = self;
    [self.orderScrollView registerClass:[UILabel class] reuseIdentifier:@"LABELIDENTIFIER"];
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:indicatorView];
    self.indicatorView = indicatorView;
}

- (void)requestData {
    // 模拟加载数据
    [self.indicatorView startAnimating];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.indicatorView stopAnimating];
        totalRows = 40;
        totalColumns = 50;
        [self.orderScrollView reloadData];
    });
}

- (NSInteger)numberOfRowsInOrderScrollView:(SROrderScrollView *)orderScrollView {
    return totalRows;
}

- (NSInteger)numberOfColumnsInOrderScrollView:(SROrderScrollView *)orderScrollView {
    return totalColumns;
}

- (UIView __kindof *)orderScrollView:(SROrderScrollView *)orderScrollView itemInRow:(NSInteger)row column:(NSInteger)column {
    UILabel *itemLabel = (UILabel *)[orderScrollView dequeueReusableItemWithReuseIdentifier:@"LABELIDENTIFIER" row:row column:column];
    itemLabel.backgroundColor = [UIColor orangeColor];
    itemLabel.textAlignment = NSTextAlignmentCenter;
    itemLabel.text = [NSString stringWithFormat:@"第%zd行,第%zd列",row,column];
    itemLabel.font = [UIFont systemFontOfSize:13];
    itemLabel.userInteractionEnabled = YES;
    return itemLabel;
}

- (CGSize)sizeOfItemInOrderScrollView:(SROrderScrollView *)orderScrollView {
    return CGSizeMake(100, 50);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"子视图数目: %zd",scrollView.subviews.count);
}

- (void)orderScrollView:(SROrderScrollView *)orderScrollView didSelectRow:(NSUInteger)row column:(NSUInteger)column {
    NSLog(@"点击了第%zd行,第%zd列",row,column);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
