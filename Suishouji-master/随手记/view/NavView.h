//
//  NavView.h
//  随手记
//
//  Created by 刘怀智 on 16/5/29.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddBillViewController.h"
@class NavView;
@protocol NavViewDelegate <NSObject>

- (void)selectedBtnName:(BtnName)btnName;

@end

@interface NavView : UIView

@property (nonatomic, strong) id<NavViewDelegate> delegate;

- (void)selectedBtnBetweenOutInput:(BtnName) name; ///<设置选中的收入支出的颜色
@end
