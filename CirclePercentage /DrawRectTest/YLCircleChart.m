//
//  YLCircleChart.m
//  DrawRectTest
//
//  Created by yinlinlin on 2016/12/7.
//  Copyright © 2016年 yinlinlin. All rights reserved.
//

#import "YLCircleChart.h"

@interface YLCircleChart ()
{
    //圆环，单个百分比
    CGFloat _startAngle;
    CGFloat _endAngle;
    CGFloat _percentage;
    
    
    
    CGFloat _radius;//半径
    CGPoint _centerPoint;//中心
    
    //饼图
    NSArray<YLPartModel *> * _parts;
    CGFloat _total;
    //记录路径，CGPathContainsPoint判断点击的扇形区域，处理点击事件
    NSMutableArray *_pathArr;
}

//基准圆环颜色
@property(nonatomic,strong)UIColor *unfillColor;
//显示圆环颜色
@property(nonatomic,strong)UIColor *fillColor;

@end

@implementation YLCircleChart

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//parts
- (instancetype) initWithFrame:(CGRect)frame parts:(NSArray<YLPartModel *> *)parts total:(CGFloat)total {
    if (self = [super initWithFrame:frame]) {
        _unfillColor = [UIColor lightGrayColor];
        _fillColor = [UIColor orangeColor];
        _radius = MIN(self.bounds.size.height/2, self.bounds.size.width/2) - 20;
        CGFloat center = MIN(self.bounds.size.height/2, self.bounds.size.width/2);
        _centerPoint = CGPointMake(center, center);
        self.backgroundColor = [UIColor clearColor];
        _parts = parts;
        _total = total;
        _pathArr = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}
//startAngle:起点角度, endAngle:终点角度, percentage：百分比
- (instancetype) initWithFrame:(CGRect)frame startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle percentage:(CGFloat)percentage {
    if (self = [super initWithFrame:frame]) {
        _startAngle = startAngle;
        _endAngle = endAngle;
        _percentage = percentage;
        _unfillColor = [UIColor lightGrayColor];
        _fillColor = [UIColor orangeColor];
        _radius = MIN(self.bounds.size.height/2, self.bounds.size.width/2) - 20;
        CGFloat center = MIN(self.bounds.size.height/2, self.bounds.size.width/2);
        _centerPoint = CGPointMake(center, center);
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self drawCircle2];
//    [self drawCircle3];
}


#pragma mark - 圆环
- (void)drawCircle1 {
    //计算弧度
    CGFloat start = M_PI / 180.0 * _startAngle;
    CGFloat end = M_PI / 180.0 * _endAngle;
    CGFloat chart = M_PI / 180.0 * (_endAngle - _startAngle) * _percentage + start;
    //画基准圆环，clockwise	顺时针方向
    UIBezierPath * cPath = [UIBezierPath bezierPathWithArcCenter:_centerPoint radius:_radius startAngle:start endAngle:end clockwise:YES];
    cPath.lineWidth = 20;
    cPath.lineCapStyle = kCGLineCapRound;
    cPath.lineJoinStyle = kCGLineJoinRound;
    [_unfillColor setStroke];
    [cPath stroke];
    
    //百分比
    UIBezierPath *bPath = [UIBezierPath bezierPathWithArcCenter:_centerPoint radius:_radius startAngle:start endAngle:chart clockwise:YES];
    bPath.lineWidth = 20;
    bPath.lineCapStyle = kCGLineCapRound;
    bPath.lineJoinStyle = kCGLineJoinRound;
    [_fillColor setStroke];
    [bPath stroke];

}


#pragma mark - 饼图
- (void)drawCircle2 {
    //计算弧度
    CGFloat start = 0;
    CGFloat end = M_PI * 2 + start;
    CGFloat chart;
    //画基准圆环，clockwise	顺时针方向
    UIBezierPath * cPath = [UIBezierPath bezierPathWithArcCenter:_centerPoint radius:_radius startAngle:start endAngle:end clockwise:YES];
    [[UIColor lightGrayColor] setFill];
    [cPath fill];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (NSInteger i = 0; i < _parts.count; i ++) {
        
        YLPartModel *part = _parts[i];
        NSString * title = part.title;
        CGFloat percentage = part.number/_total;
        UIColor * color = part.color;
        chart = M_PI * 2 * percentage + start;
        CGContextBeginPath(context);
        //以10为半径围绕圆心画指定角度扇形
        CGContextMoveToPoint(context, _centerPoint.x, _centerPoint.y);
        //0:顺时针，1逆时针
        CGContextAddArc(context, _centerPoint.x, _centerPoint.y, _radius, start, chart, 0);
        CGContextClosePath(context);
        CGContextSetFillColorWithColor(context, color.CGColor);//填充颜色
        CGContextDrawPath(context, kCGPathFillStroke); //绘制路径
        
        //添加文字
        //计算文字中心点，扇形中心
        //中心点弧度
        CGFloat centerChart = M_PI * percentage + start;
        //三角函数计算相对圆心的偏移量
        CGFloat transX = fabs(cos(centerChart) * _radius*0.7);
        CGFloat transY = fabs(sin(centerChart) * _radius*0.7);
        
        //计算坐标(顺时针方向)
        CGFloat centerX,centerY;
        if (centerChart > M_PI/2.0 && centerChart < M_PI + M_PI/2.0) {
            centerX = _centerPoint.x - transX;
        } else {
            centerX = _centerPoint.x + transX;
        }
        
        if (centerChart < M_PI) {
            centerY = _centerPoint.y + transY;
        } else {
            centerY = _centerPoint.y - transY;
        }
        CGPoint wordPoint = CGPointMake(centerX, centerY);
        CGRect rect = CGRectMake(wordPoint.x - 30, wordPoint.y - 10, 60, 20);
        UIFont * font = [UIFont boldSystemFontOfSize:10.0];
        NSMutableParagraphStyle* paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        NSDictionary * attribute = @{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle};
        [title drawInRect:rect withAttributes:attribute];
        start = chart;
    }
}

//饼图+点击事件
- (void)drawCircle3 {
    //计算弧度
    CGFloat start = 0;
    CGFloat end = M_PI * 2 + start;
    CGFloat chart;
    //画基准圆环，clockwise	顺时针方向
    UIBezierPath * cPath = [UIBezierPath bezierPathWithArcCenter:_centerPoint radius:_radius startAngle:start endAngle:end clockwise:YES];
    [[UIColor lightGrayColor] setFill];
    [cPath fill];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (NSInteger i = 0; i < _parts.count; i ++) {
        
        YLPartModel *part = _parts[i];
        NSString * title = part.title;
        CGFloat percentage = part.number/_total;
        UIColor * color = part.color;
        chart = M_PI * 2 * percentage + start;
        CGContextBeginPath(context);
        //以10为半径围绕圆心画指定角度扇形
        CGContextMoveToPoint(context, _centerPoint.x, _centerPoint.y);
        //0:顺时针，1逆时针
        CGContextAddArc(context, _centerPoint.x, _centerPoint.y, _radius, start, chart, 0);
        //获取当前路径中的矩形区域，用来显示文字
        CGContextClosePath(context);
        
        
        CAShapeLayer * layer = [CAShapeLayer layer];
        layer.path = CGContextCopyPath(context);
        [layer setFillColor:color.CGColor];
        [self.layer addSublayer:layer];
        [_pathArr addObject:layer];
        //添加文字
        //计算文字中心点，扇形中心
        //中心点弧度
        CGFloat centerChart = M_PI * percentage + start;
        //三角函数计算相对圆心的偏移量
        CGFloat transX = fabs(cos(centerChart) * _radius*0.7);
        CGFloat transY = fabs(sin(centerChart) * _radius*0.7);
        
        //计算坐标(顺时针方向)
        CGFloat centerX,centerY;
        if (centerChart > M_PI/2.0 && centerChart < M_PI + M_PI/2.0) {
            centerX = _centerPoint.x - transX;
        } else {
            centerX = _centerPoint.x + transX;
        }
        
        if (centerChart < M_PI) {
            centerY = _centerPoint.y + transY;
        } else {
            centerY = _centerPoint.y - transY;
        }
        CGPoint wordPoint = CGPointMake(centerX, centerY);
        CGRect rect = CGRectMake(wordPoint.x - 30, wordPoint.y - 10, 60, 20);
        //使用drawInRect无法显示是因为上面CAShapeLayer addSublayer，被添加的图层遮盖住了，文字drawrect到view上面，但是view.layer上面添加了图层CAShapeLayer
//        UIFont * font = [UIFont boldSystemFontOfSize:10.0];
//        NSMutableParagraphStyle* paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
//        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
//        NSDictionary * attribute = @{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle};
//        [title drawInRect:rect withAttributes:attribute];
        UILabel * label = [[UILabel alloc] initWithFrame:rect];
        label.text = title;
        label.font = [UIFont systemFontOfSize:10.0];
        label.adjustsFontSizeToFitWidth = YES;
        [self addSubview:label];
        
        //下个模块的start弧度
        start = chart;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    for (NSInteger i = 0; i < _pathArr.count; i ++) {
        CAShapeLayer * layer = _pathArr[i];
        CGPathRef path = layer.path;
        if (CGPathContainsPoint(path, NULL, point, NO)) {
            NSLog(@"touch In part %ld",(long)i);
            break;
        }
    }
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    UITouch * touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self];
//    for (NSInteger i = 0; i < _pathArr.count; i ++) {
//        CAShapeLayer * layer = _pathArr[i];
//        CGPathRef path = layer.path;
//        if (CGPathContainsPoint(path, NULL, point, NO)) {
//            NSLog(@"touch In layer %ld",(long)i);
//            break;
//        }
//    }
//
//}
@end
