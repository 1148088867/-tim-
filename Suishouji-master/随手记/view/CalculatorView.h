//
//  CalculatorView.h
//  随手记
//
//  Created by 刘怀智 on 16/5/25.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CalculatorView;
@protocol  CalculatorViewDelegate <NSObject>

-(void)outStrOfCalculatorViewWithWord: (NSString *)str;///<计算器
- (void)CalculatorWithWord:(NSString *)str;///<日历
- (void)tapAddNote;///<备注
@end;

@interface CalculatorView : UIView

@property (weak, nonatomic)id<CalculatorViewDelegate> delegate;
- (void)setCalendarBtnTitle:(NSString *)time; //设置显示的日期

@end
