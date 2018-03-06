//
//  budgetController.m
//  随手记
//
//  Created by 何易东 on 16/6/22.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import "budgetController.h"
#import "sqlManger.h"


@interface budgetController()

@property (weak, nonatomic) IBOutlet UIView *IconBackground; //黑色的背景图
@property (weak, nonatomic) IBOutlet UIButton *installButton; //设置
@property (nonatomic, strong) UIAlertAction *secureTextAlertAction;
@property (weak, nonatomic) IBOutlet UILabel *Balance; //结余
@property (nonatomic, strong) sqlManger *database;
@property (weak, nonatomic) IBOutlet UILabel *expenditure; //支出
@property (weak, nonatomic) IBOutlet UILabel *money; //月预算
@property (nonatomic, assign) float outMoney;
@property (weak, nonatomic) IBOutlet UILabel *daysLabel; //结算日


@end

@implementation budgetController

- (void)viewDidLoad{
    self.database = [sqlManger dataBaseDefaultManager];
    
    //支出金额
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM";
    NSString *month = [formatter stringFromDate:date];
    NSString *payMoney = [self.database totalMoney:YES date:month];
    self.outMoney = payMoney.floatValue; //支出
    self.expenditure.text = payMoney;
    
    // 预算 / 结余
    NSArray *budgetArray = [self.database readBudget];
    if (budgetArray.count!=0) {
        self.money.text = budgetArray[0];
        float st = [budgetArray[0] floatValue];
        self.Balance.text = [NSString stringWithFormat:@"%.2f",st - self.outMoney];
    }else{
        self.money.text = @"0.00";
        self.Balance.text = [NSString stringWithFormat:@"%.2f",self.money.text.floatValue - self.outMoney];
    }
    
    // 距离结算日
    self.daysLabel.text = [NSString stringWithFormat:@"%ld", [self theDaysToLastDay]];
    
    [self creatGestureRecognizer];
    [self layerFrame];
}

//返回手势
- (void)creatGestureRecognizer
{
    UISwipeGestureRecognizer *back = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftSwipeAction:)];
    back.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:back];
}
//手势响应函数
- (void)leftSwipeAction:(UISwipeGestureRecognizer *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//更改中间的view、设置按钮的样式
- (void)layerFrame
{
    self.IconBackground.layer.cornerRadius = self.IconBackground.frame.size.height / 3;
    self.IconBackground.center = CGPointMake(self.IconBackground.frame.size.width/3, self.IconBackground.frame.size.height/3);
    
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.bounds = CGRectMake(0, 0, self.installButton.frame.size.width, self.installButton.frame.size.height);
    borderLayer.position = CGPointMake(CGRectGetMidX(self.installButton.bounds), CGRectGetMidY(self.installButton.bounds));
    borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:borderLayer.bounds cornerRadius:CGRectGetWidth(borderLayer.bounds)/2].CGPath;
    //    borderLayer.lineWidth = 1. / [[UIScreen mainScreen] scale];
    
    //虚线边框
    borderLayer.lineDashPattern = @[@8, @8];
    //实线边框
    //    borderLayer.lineDashPattern = nil;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.strokeColor = [UIColor grayColor].CGColor;
    [self.installButton.layer addSublayer: borderLayer];
}

#pragma mark - 设置按钮响应函数 设置预算
- (IBAction)installButton:(UIButton *)sender
{
//    弹出对话框 输入预算
   UIAlertController *contercoller = [UIAlertController alertControllerWithTitle:@"请设定预算" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:contercoller.textFields.firstObject]; //KVO
        
        UITextField *textField = contercoller.textFields.firstObject;
        if ([self checkTheTestString:textField.text]) { //检查字符 正则表达式
//            更新界面的数据
            //预算－支出
            float balance = textField.text.floatValue - self.outMoney;
            //结余
            self.Balance.text = [NSString stringWithFormat:@"%.2f",balance];
            //预算
            self.money.text =[NSString stringWithFormat:@"%.2f", textField.text.floatValue];
            //判断预算是否为空
            if ([self.database readBudget].count == 0) {
                float st = self.money.text.floatValue;
                [self.database addBudget:@(st)];
            }else{
                float st = textField.text.floatValue;
                [self.database modifyTheBudget:@(st)];
            }
            
        }
        else
        {
//            弹出提示框
            UIAlertController *contercoller1 = [UIAlertController alertControllerWithTitle:nil message:@"请输入整数或不超过小数点后两位的小数！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                //响应知道了
                [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:contercoller.textFields.firstObject];
            }];

            [contercoller1 addAction:action3];
            //推出请输入整数提示控制器
            [self presentViewController:contercoller1 animated:YES completion:nil];
        }
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:contercoller.textFields.firstObject];
    }];
    
    //另外，很多时候，我们需要在alertcontroller中添加一个输入框，例如输入密码：
    [contercoller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
        
        textField.secureTextEntry = NO; //是否隐藏输入的字符
        
        textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }];
    action.enabled = NO;
    self.secureTextAlertAction = action;//定义一个全局变量来存储
    
    [contercoller addAction:action];
    [contercoller addAction:action2];
    //推出请设定预算控制器
    [self presentViewController:contercoller animated:YES completion:nil];
}

// 判断输入的字符串长度，为0 无法点击确定
- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = notification.object;
    
    // Enforce a minimum length of >= 5 characters for secure text alerts.
    self.secureTextAlertAction.enabled = textField.text.length > 0;
}

#pragma mark - 检查字符

- (BOOL)checkTheTestString:(NSString *)testString {
    //正则表达式
    // “ ^ ” 表示开始 “ [0-9] ” 表示0至9的数字 “ {1,} ” 表示一到无穷个0至9的数字 “ .* ” 表示以它后面的内容结尾 “ | ” 表示“或” 配合()使用 (A)|(B)  “ $ ” 表示结束
    NSString *number=@"^[0-9]{1,}.*(.[0-9]{1,2})|([0-9]{0,0})$";
    
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    BOOL result = [numberPre evaluateWithObject: testString];
    return result;
    
}

#pragma mark - 时间

//获取当前月份
- (NSString *)currentMonth
{
//    当前时间
    NSDate *nowDate = [NSDate date];
//    格式化时间 只要年月
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM";
    NSString *month = [formatter stringFromDate:nowDate];
    return month;
}

//获取结算的日期
- (NSString *)theLastDay
{
    NSString *currentMonth = [self currentMonth];
    NSArray *timeArray = [currentMonth componentsSeparatedByString:@"-"];
    NSString *month = timeArray.lastObject;
    NSString *year = timeArray.firstObject;
    NSString *nextMonth = [NSString stringWithFormat:@"%d", month.intValue + 1];
    
    NSString *nextYear = year;
    if (month.intValue < 9)
    {
//        判断当前是否小于9月  判断的原因：1-9月 int 值为一位数 ，需要两位字符 如：09
        nextMonth = [NSString stringWithFormat:@"0%d", month.intValue + 1];
    }
    if (nextMonth.intValue > 12)
    {
//        判断当前是否为12月
        nextMonth = @"01";
        nextYear = [NSString stringWithFormat:@"%d", year.intValue + 1];
    }
    NSString *theLastDay = [NSString stringWithFormat:@"%@-%@-01", nextYear, nextMonth];
    return theLastDay;
}

//计算间隔的天数
- (NSInteger)theDaysToLastDay
{
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *lastDateStr = [self theLastDay];
    NSDate *lastDate = [formatter dateFromString:lastDateStr];
    NSTimeInterval timer = [lastDate timeIntervalSinceDate:nowDate];
    
    int timeOfOneDay = 60 * 60  * 24;
    NSInteger days = timer / timeOfOneDay;
    return days;
}

@end
