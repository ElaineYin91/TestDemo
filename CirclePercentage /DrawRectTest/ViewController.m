//
//  ViewController.m
//  DrawRectTest
//
//  Created by yinlinlin on 15/11/8.
//  Copyright © 2015年 yinlinlin. All rights reserved.
//

#import "ViewController.h"
#import "YLCircleChart.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self createCircleChart2];
}

- (void)createCircleChart1 {
    YLCircleChart * circleChart = [[YLCircleChart alloc] initWithFrame:CGRectMake(20, 50, self.view.bounds.size.width - 40, self.view.bounds.size.width - 40) startAngle:150 endAngle:390 percentage:0.7];
    [self.view addSubview:circleChart];
}

- (void)createCircleChart2 {
    CGFloat total = 0;
    NSMutableArray * dataSource = [NSMutableArray arrayWithCapacity:5];
    NSArray * colors = @[[UIColor redColor], [UIColor grayColor], [UIColor yellowColor], [UIColor purpleColor], [UIColor blueColor], [UIColor brownColor]];
    for (NSInteger i = 0; i < colors.count; i ++ ) {
        YLPartModel * model = [[YLPartModel alloc] init];
        model.color = colors[i];
        model.number = 100 + 50 * i;
        total += model.number;
        model.title = [NSString stringWithFormat:@"Part%zd:%0.1f%%",i,model.number/total*100];
        [dataSource addObject:model];
    }
    YLCircleChart * circleChart = [[YLCircleChart alloc] initWithFrame:CGRectMake(20, 50, self.view.bounds.size.width - 40, self.view.bounds.size.width - 40)  parts:dataSource total:total];
    [self.view addSubview:circleChart];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
