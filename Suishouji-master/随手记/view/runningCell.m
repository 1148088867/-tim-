//
//  runningCell.m
//  随手记
//
//  Created by 何易东 on 16/6/8.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import "runningCell.h"

@interface runningCell()

@end

@implementation runningCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //初始化时间
        _typeTime = [[UILabel alloc]initWithFrame:CGRectMake(10, self.frame.size.height/4, self.frame.size.width/4, 20)];
        _typeTime.textAlignment = NSTextAlignmentCenter;
        _typeTime.font = [UIFont systemFontOfSize:20];
        [self.contentView addSubview:_typeTime];
        
        // 初始化视图对象
        // 图片
        _typeImage = [[UIImageView alloc] initWithFrame:CGRectMake(_typeTime.frame.size.width+10, 0, 50, 50)];
        // 添加到父视图
        // 自定义cell的时候, 所有视图都添加到cell的contentView中
        [self.contentView addSubview:_typeImage];
        
        // 名字
        _typeName = [[UILabel alloc] initWithFrame:CGRectMake(_typeImage.frame.origin.x+50, self.frame.size.height/4, self.frame.size.width/3, 20)];
        [self.contentView addSubview:_typeName];
        
        // 价格
        _typeMoney = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width, self.frame.size.height/4, self.frame.size.width/3, 20)];
        _typeMoney.font = [UIFont systemFontOfSize:20];
        _typeMoney.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_typeMoney];
        
    }
    return self;
}

- (void)config:(Bill *)model
{
    self.typeImage.image = [UIImage imageNamed:model.category.iconName];
    self.typeName.text = model.category.categoryName;
    if (model.category.isOut) {
        self.typeMoney.textColor = [UIColor redColor];
    }else{
        self.typeMoney.textColor = [UIColor greenColor];
    }
    
    self.typeMoney.text = model.money.stringValue;
}
@end
