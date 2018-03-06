    //
//  AddBtnView.m
//  随手记
//
//  Created by 刘怀智 on 16/5/9.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import "AddBtnView.h"
#import "category.h"
#define PI 3.14159265359
#define Kwidth self.frame.size.height///<view宽高
#define KviewCenterX [UIScreen mainScreen].bounds.size.width/2 ///<中心点X
#define KviewCenterY [UIScreen mainScreen].bounds.size.height/4  ///<中心点y
#define lineWid 3 ///< 线宽
#define   kDegreesToRadians(degrees)  ((PI * degrees)/ 180) ///<求弧度
#define layerRadius  (Kwidth / 2) - 5 ///<彩色圆环的半径； 5为彩色圆环外的白边宽度

@interface AddBtnView ()


@property (nonatomic, assign)  CGPoint selfCenter; ///< 相对于view的中心点
@property (nonatomic, strong)  CAShapeLayer *outLayer; ///<白色圆环
@property (nonatomic, strong)  CAShapeLayer *downRingLayer;
@property (nonatomic, assign)  BOOL isOut;

@end

@implementation AddBtnView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    CGPoint point = CGPointMake(KviewCenterX, KviewCenterY);
    self.center = point;
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = Kwidth / 2; //设置当前view的半径等同下面
    self.lineWidth = lineWid;
    
    self.selfCenter = CGPointMake(self.frame.size.width / 2, self.frame.size.width / 2);
    
    [self creatLayers];
    
   
    
    return self;
}

-(void)setColorsArray:(NSMutableArray *)colorsArray{

    _colorsArray = colorsArray;
    [self removeLayers];
    [self creatLayers];
}

- (void)setImageName:(NSString *)imageName
{
    CGRect frame = CGRectMake(0, 0, Kwidth/2, Kwidth/2);
    self.addImage = [[UIImageView alloc]initWithFrame:frame];
    self.addImage.image = [UIImage imageNamed:imageName];
    //    self.addImage.layer.cornerRadius = 18 / 2;
    self.addImage.center = self.selfCenter;
    [self addSubview:self.addImage];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addBtnTap:)];
    [self addGestureRecognizer:tap];
    
    _imageName = imageName;
}

#pragma mark - Layer

-(void) creatLayers
{
    [self downLayer];
//    self.outLayer.strokeEnd = 0;
}
- (void)removeLayers
{
    [self.outLayer removeFromSuperlayer];
    [self.downRingLayer removeFromSuperlayer];
    self.downRingLayer = nil;
}
-(void) downLayer
{
    [self ringLayerWithBillDic:self.colorsArray];
    self.outLayer = [CAShapeLayer layer];
    //    outLayer.position = self.selfCenter;
    //    路径
    UIBezierPath *outPath = [UIBezierPath bezierPathWithArcCenter:self.selfCenter radius:layerRadius startAngle:0 endAngle:M_PI * 2 clockwise:NO];
    self.outLayer.path = outPath.CGPath;
    self.outLayer.fillColor = [UIColor clearColor].CGColor; // //覆盖图片view的颜色
    self.outLayer.strokeColor = [UIColor whiteColor].CGColor;//初始化动画圈圈颜色
    self.outLayer.lineWidth = self.lineWidth + 3;
    [self.layer addSublayer:self.outLayer];
}

- (void)ringLayerWithBillDic:(NSMutableArray * )colorArray
{
    if (!colorArray) {
        return;
    }
    self.aboutRingArray = [NSMutableArray array];
    self.downRingLayer = [CAShapeLayer layer];
    self.downRingLayer.frame = CGRectMake(0, 0, layerRadius, layerRadius);
    self.downRingLayer.cornerRadius = layerRadius;

    NSArray *dicArray = [colorArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDictionary *dict1 = obj1;
        NSDictionary *dict2 = obj2;
        NSString *key1 = dict1[@"scale"];
        NSString *key2 = dict2[@"scale"];
        return [key1 compare:key2];
    }];
    
    CGFloat startAngle = M_PI / 2;
    CGFloat endAngle;
    for (int i = 0; i < dicArray.count; i++)
    {
        NSDictionary *dic = dicArray[i];
        NSString *elem = dic[@"scale"];
        endAngle  = elem.floatValue * M_PI * 2 + startAngle;
        if (i == dicArray.count - 1) {
            endAngle = 2 * M_PI + M_PI_2;
        }
        [self aboutOfRingStart:startAngle end:endAngle ringDic:dic];
//        NSLog(@"%.2f angle: %.2f %.2f",endAngle,elem.floatValue * M_PI * 2 ,2 * M_PI + M_PI_2);
        
        CAShapeLayer *ringLayer = [CAShapeLayer layer];
        UIBezierPath *outPath = [UIBezierPath bezierPathWithArcCenter:self.selfCenter radius:layerRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
//        NSLog(@"start: %.2f ; end: %.2f ;all: %.2f",startAngle, endAngle, 2 * M_PI + M_PI_2);
        
        ringLayer.lineWidth = self.lineWidth;
        ringLayer.path = outPath.CGPath;
        
        UIColor *storkeColor = dic[@"color"];
        ringLayer.strokeColor = storkeColor.CGColor;
        ringLayer.fillColor = [UIColor clearColor].CGColor;
        
        startAngle = endAngle;
        [self.downRingLayer addSublayer:ringLayer];
    }
    [self.layer addSublayer:self.downRingLayer];
    
}

#pragma mark - 开始弧度、结束弧度、所属类别、比例
- (void) aboutOfRingStart:(CGFloat)start  end:(CGFloat)end  ringDic:(NSDictionary *)dic
{
    CGFloat center = (end - start) / 2.00;
    NSDictionary *ringDic = @{@"type":dic[@"type"], @"name":dic[@"name"], @"start":@(start), @"end":@(end),@"center":@(center), @"scale":dic[@"scale"]};
    [self.aboutRingArray addObject:ringDic];
}
#pragma mark - 动画

-(void) updataLayer:(BOOL)isShow
{
//    [CATransaction begin];
//    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
//    
//    [CATransaction setAnimationDuration:0.5];
//    NSInteger n;
//    if (isShow == YES) {
////        self.outLayer.strokeStart=100;
//        n = 0;
//    }
//    else {
//        n = 100;
//    }
//    
//    self.outLayer.strokeEnd = n / 100.0;
//    //    self.percentLabel.text = [NSString stringWithFormat:@"%@%%", @(number)];
//    NSLog(@"%@",self.outLayer);
//
//    [CATransaction commit];
//    [CATransaction setCompletionBlock:^{
//        NSLog(@"%@",self.outLayer);
//        NSLog(@"done");
////        [CATransaction flush];
////        if ([self.delegate respondsToSelector:@selector(juttonJump:)]) {
////            [self.delegate juttonJump:self];
////        }
//
//    }];
    if (isShow) {
        CABasicAnimation *outerAnimation=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        outerAnimation.duration=0.5;
        outerAnimation.toValue=@0;
        outerAnimation.repeatCount=0;
        outerAnimation.removedOnCompletion=NO;
        outerAnimation.fillMode=kCAFillModeForwards;
        [self.outLayer addAnimation:outerAnimation forKey:@"show"];
    }else{
        CABasicAnimation *outerAnimation=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        outerAnimation.duration=0.5;
        outerAnimation.toValue=@1;
        outerAnimation.repeatCount=0;
        outerAnimation.removedOnCompletion=NO;
        outerAnimation.fillMode=kCAFillModeForwards;
        [self.outLayer addAnimation:outerAnimation forKey:@"hide"];
    }
    
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 0.5;
    animation.toValue = [NSNumber numberWithFloat:1 * M_PI];
    animation.repeatCount = 0;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    [self.addImage.layer addAnimation:animation forKey:@"transform.rotation.z"];

}

- (void)addBtnTap:(UITapGestureRecognizer *)sender
{
    [self updataLayer:NO];
    if ([self.delegate respondsToSelector:@selector(juttonJump:)]) {
        [self.delegate juttonJump:self];
    }
}

//判断点击的point是否在layer 中


-(NSInteger)getLayerIndexWithPoint:(CGPoint)point {
    CGAffineTransform transform = CGAffineTransformIdentity;
    for (NSInteger i=0; i< [self.downRingLayer sublayers].count; i++) {
        CAShapeLayer *layer = (CAShapeLayer *)[self.downRingLayer sublayers][i];
        CGPathRef path = [layer path];
        if (CGPathContainsPoint(path, &transform, point, 0)) {
            return i;
        }
    }
    return -1;
    
}
@end
