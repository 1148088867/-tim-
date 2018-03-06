//
//  ImageColor.h
//  随手记
//
//  Created by 刘怀智 on 16/5/26.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageColor : UIColor

@property (nonatomic, strong) UIColor *imageColor;
- (instancetype)initWithImage:(UIImage *)image Point:(CGPoint)colorPoint;
@end
