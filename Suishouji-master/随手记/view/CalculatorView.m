//
//  CalculatorView.m
//  随手记
//
//  Created by 刘怀智 on 16/5/25.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import "CalculatorView.h"
#import "MoneyView.h"
#import "SZCalendarPicker.h"
@interface CalculatorView ()

@property (nonatomic, copy) NSString *currentStr; ///<当前字符
@property (nonatomic, copy) NSString *lastStr; ///<上一个字符
@property (nonatomic, copy) NSString *beforStr; ///<小数点前的字符
@property (nonatomic, copy) NSString *afterStr; ///<小数点后的字符
@property (nonatomic, assign) BOOL isTapPoint; ///<是否点击了小数点
@property (nonatomic, assign) BOOL isPlussign; ///<是否是加号
@property (nonatomic, assign) BOOL isOperation; ///<是否在运算
@property (weak, nonatomic) IBOutlet UIButton *CalendarBtn;
@end
@implementation CalculatorView



- (void)awakeFromNib
{
    self.beforStr = @"0";
    self.afterStr = @"00";
    self.currentStr = [NSString stringWithFormat:@"%@.%@",self.beforStr,self.afterStr];
    self.lastStr = nil;
    self.isTapPoint = NO;
    self.isOperation = NO;
    [self outStringOfCalculator];
    
    NSDateFormatter *formater = [[NSDateFormatter alloc]init];
    formater.dateFormat = @"yyyy-MM-dd";
    NSString *dateStr = [formater stringFromDate:[NSDate date]];
    [self.CalendarBtn setTitle:dateStr forState:UIControlStateNormal];
}


- (IBAction)btnAction:(UIButton *)sender {
    NSString *title = [sender titleForState:UIControlStateNormal];
    
    if ([title isEqualToString:@"."]) { //点击“.”  输入小数点后的数字
        self.isTapPoint = YES;
        return;
    }
    else if ([title isEqualToString:@"清零"]) //所有参数改为初始值
    {
        self.beforStr = @"0";
        self.afterStr = @"00";
        self.currentStr = [NSString stringWithFormat:@"%@.%@",self.beforStr,self.afterStr];
        self.lastStr = nil;
        self.isTapPoint = NO;
        self.isOperation = NO;
        NSLog(@"%@",self.currentStr);
        [self outStringOfCalculator];
        return;
    }
    else if([title isEqualToString:@"+"] || [title isEqualToString:@"-"])//点击“+”或“-” 开始运算， 输入第二个数字
    {
        if ([title isEqualToString:@"+"]) {
            self.isPlussign = YES;
            float count = self.lastStr.floatValue + self.currentStr.floatValue;
            self.currentStr = [NSString stringWithFormat:@"%.2f",count];
        }
        else{
            if (self.lastStr.floatValue != 0) {
                float jian = self.lastStr.floatValue - self.currentStr.floatValue;
                self.currentStr = [NSString stringWithFormat:@"%.2f",jian];
            }
            self.isPlussign = NO;
            
        }
        [self outStringOfCalculator];
        self.lastStr = self.currentStr;
        self.beforStr = @"0";
        self.afterStr = @"00";
        self.isTapPoint = NO;
        self.isOperation = YES;
        return;
    }
    else if ([title isEqualToString:@"="]) //点击“=” 在运算时执行
    {
        if (self.isOperation == NO) return;
        
        if (self.isPlussign == YES) {
            float count = self.lastStr.floatValue + self.currentStr.floatValue;
            self.currentStr = [NSString stringWithFormat:@"%.2f",count];
        }else{
            float jian = self.lastStr.floatValue - self.currentStr.floatValue;
            self.currentStr = [NSString stringWithFormat:@"%.2f",jian];
        }
        [self outStringOfCalculator];
        NSLog(@"last:%@ current: %@", self.lastStr, self.currentStr);
        self.beforStr = @"0";
        self.afterStr = @"00";
        self.lastStr = nil;
        self.isTapPoint = NO;
        self.isOperation = NO;
        self.currentStr = [NSString stringWithFormat:@"%@.%@",self.beforStr,self.afterStr];
        return;
    }
    
    if (self.isTapPoint == YES) { // 判断是否已近点击“.”
        self.afterStr = [NSString stringWithFormat:@"%@0",title];
    }
    else // 输入小数点前的数字
    {
        if ([self.beforStr isEqualToString: @"0"]) //第一次输入小数点前的数字
        {
            self.beforStr = [NSString stringWithFormat:@"%@",title];
            
        }
        else
        {
            self.beforStr = [NSString stringWithFormat:@"%@%@",self.beforStr,title];
        }
    }
   self.currentStr = [NSString stringWithFormat:@"%@.%@",self.beforStr,self.afterStr];
    NSLog(@"%@",self.currentStr);
    [self outStringOfCalculator];
}

- (void)outStringOfCalculator
{
    if ([self.delegate respondsToSelector:@selector(outStrOfCalculatorViewWithWord:)]) {
        [self.delegate outStrOfCalculatorViewWithWord:self.currentStr];
    }
}
#pragma mack - 日历
- (IBAction)CalendarBtnAction:(UIButton *)sender {
    SZCalendarPicker *calendarPicker = [SZCalendarPicker showOnView:self];
    calendarPicker.today = [NSDate date];
    calendarPicker.date = calendarPicker.today;
    calendarPicker.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    calendarPicker.calendarBlock = ^(NSInteger day, NSInteger month, NSInteger year){
    
        NSLog(@"%li-%li-%li", year,month,day);
        NSString *dateStr = [NSString stringWithFormat:@"%li-%li-%li", year,month,day];
        [self.CalendarBtn setTitle:dateStr forState:UIControlStateNormal];
        [self CalendarStringOfCalculator:dateStr];
    };

}
//设置显示的日期
- (void)setCalendarBtnTitle:(NSString *)time
{
    [self.CalendarBtn setTitle:time forState:UIControlStateNormal];
}
- (void)CalendarStringOfCalculator:(NSString *)calendarStr
{
    if ([self.delegate respondsToSelector:@selector(CalculatorWithWord:)]) {
        [self.delegate CalculatorWithWord:calendarStr];
    }
}
#pragma mack - note
- (IBAction)noteBtnAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(tapAddNote)]) {
        [self.delegate tapAddNote];
    }
}
@end
