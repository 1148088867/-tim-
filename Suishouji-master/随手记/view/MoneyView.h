//
//  MoneyView.h
//  随手记
//
//  Created by 刘怀智 on 16/5/25.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "category.h"

@class MoneyView;
@protocol MoneyViewDelegate <NSObject>

- (void)clickOnPicture:(MoneyView *)money;

@end

@interface MoneyView : UIView
@property (nonatomic, strong) id<MoneyViewDelegate>delegate;
@property (nonatomic, strong) UIImage *typeImage; ///<类别图片
@property (nonatomic, copy) NSString *typeName; ///<类别名
@property (nonatomic, copy) NSString *money; ///<金额
@property (nonatomic, strong) UIColor *color; ///<颜色
@property (nonatomic, strong) category *theCateg;

- (instancetype)init;
@end
