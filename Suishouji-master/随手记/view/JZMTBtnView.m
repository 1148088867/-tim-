//
//  JZMTBtnView.m
//  meituan
//  自定义美团菜单view
//  Created by jinzelu on 15/6/30.
//  Copyright (c) 2015年 jinzelu. All rights reserved.
//

#import "JZMTBtnView.h"

#define Kscale [UIScreen mainScreen].bounds.size.width / 320
#define KimageWidth 33 * Kscale
#define KLabelHeight 20 * Kscale
#define KimageTopDistance 10 * Kscale


@implementation JZMTBtnView

-(id)initWithFrame:(CGRect)frame title:(NSString *)title imageStr:(NSString *)imageStr{
    self = [super initWithFrame:frame];
    if (self) {
        //
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - KimageWidth) / 2 , KimageTopDistance / 2, KimageWidth, KimageWidth)];
        imageView.image = [UIImage imageNamed:imageStr];
        [self addSubview:imageView];
        
        //
        UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, KimageWidth + KimageTopDistance / 2, frame.size.width, KLabelHeight)];
        titleLable.text = title;
        titleLable.textAlignment = NSTextAlignmentCenter;
        titleLable.font = [UIFont systemFontOfSize:10 * Kscale];
        [self addSubview:titleLable];
    }
    return self;
}

@end
