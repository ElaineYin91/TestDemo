//
//  YLCircleChart.h
//  DrawRectTest
//
//  Created by yinlinlin on 2016/12/7.
//  Copyright © 2016年 yinlinlin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLPartModel.h"

@interface YLCircleChart : UIView


- (instancetype) initWithFrame:(CGRect)frame startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle percentage:(CGFloat)percentage;

- (instancetype) initWithFrame:(CGRect)frame parts:(NSArray<YLPartModel *> *)parts total:(CGFloat)total;

@end
