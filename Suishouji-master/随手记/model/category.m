//
//  category.m
//  layoutDemo
//
//  Created by 何易东 on 16/5/16.
//  Copyright © 2016年 dong. All rights reserved.
//

#import "category.h"
#import "ImageColor.h"
@implementation category

-(UIImage *)iconImage{
    return [UIImage imageNamed:self.iconName];
}

- (void)setIconName:(NSString *)iconName
{
    UIImage *image = [UIImage imageNamed:iconName];
    ImageColor *imageColor = [[ImageColor alloc]initWithImage:image Point:CGPointMake(image.size.width / 6 , image.size.height / 5)];
    self.categoryColor = imageColor.imageColor;
    _iconName = iconName;
}
@end
