//
//  MoneyView.m
//  随手记
//
//  Created by 刘怀智 on 16/5/25.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import "MoneyView.h"

#define Kscale [UIScreen mainScreen].bounds.size.width / 320 ///< 比例
#define  Kheight 50 * Kscale ///<高
@interface MoneyView ()
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *moneyLabel;

@end

@implementation MoneyView
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        self.frame = CGRectMake(0, Kheight + 20, width, Kheight);
        [self creatViews];
    }
    return self;
}

- (void)creatViews
{
    self.image = [[UIImageView alloc]initWithFrame:CGRectMake(8 * Kscale, 5 * Kscale, 40 * Kscale, 40 *Kscale)];
    self.image.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gesture:)];
    [self.image addGestureRecognizer:tap];
    self.image.image = self.typeImage;
    [self addSubview:self.image];
    
    self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(56 * Kscale, 15 * Kscale, 60 * Kscale, 20 * Kscale)];
    self.nameLabel.text = self.typeName;
    self.nameLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.nameLabel];
    
    self.moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 200 * Kscale - 8 *Kscale, 15 * Kscale, 200 * Kscale, 20 * Kscale)];
    self.moneyLabel.textColor = [UIColor whiteColor];
    self.moneyLabel.textAlignment = NSTextAlignmentRight;
    self.money = @"0.00";
    self.moneyLabel.text = [NSString stringWithFormat:@"¥%@",self.money];
    [self addSubview:self.moneyLabel];
    
    
}

-(void)setTypeName:(NSString *)typeName
{
    self.nameLabel.text = typeName;
    _typeName = typeName;
}
-(void)setTypeImage:(UIImage *)typeImage
{
    self.image.image = typeImage;
    _typeImage = typeImage;
}
-(void)setColor:(UIColor *)color
{
    self.backgroundColor = color;
    _color = color;
}
-(void)setMoney:(NSString *)money
{
    if (money == nil) {
        money = @"0.00";
    }
    self.moneyLabel.text = [NSString stringWithFormat:@"¥%@",money];
    _money = money;
}

- (void)gesture:(UITapGestureRecognizer *)sender{
    NSLog(@"1111");
    if([self.delegate respondsToSelector:@selector(clickOnPicture:)])
    {
        [self.delegate clickOnPicture:self];
    }
}

@end
