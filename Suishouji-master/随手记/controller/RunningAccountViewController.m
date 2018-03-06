//
//  RunningAccountViewController.m
//  随手记
//
//  Created by 何易东 on 16/6/2.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import "RunningAccountViewController.h"
#import "DetailViewController.h"
#import "sqlManger.h"
#import "runningCell.h"
#import "CakeViewController.h"


#define SVIEW_WIGHT self.view.frame.size.width
#define SVIEW_HEIGHT self.view.frame.size.height
#define BALANCES_HEIGHT 200
#define MONEYVIEW_LEBELWIDtH 100
#define BALANCES_BACKCOLOR [UIColor colorWithRed:0.7 green:0.4 blue:0.5 alpha:0.7]
#define MONEY_COLOR [UIColor colorWithRed:0.8 green:0.5 blue:0.3 alpha:0.7]
#define ICONMELABEL_X 120
#define ICONMELABEL_W 25
#define ICONMELABEL_H 15

@interface RunningAccountViewController()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) sqlManger *dataBase;
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) NSMutableDictionary *dict; ///<每个section的点击值
@property (nonatomic, assign) NSInteger currentMonth; ///<返回当月的cell
@property (nonatomic, strong) NSArray *reversedArray; ///<当前月到1月的数组
@property (nonatomic, strong) NSMutableArray *allMoneyArray; ///<所有金钱
@property (nonatomic, strong) NSMutableArray *billArray; ///<所有账单
@property (nonatomic, copy) NSString *indexString; ///<保存上一个的状态是否打开
@property (nonatomic, assign) BOOL isOpen; ///<进入第一次的判断
@property (nonatomic, strong) NSMutableArray *perMonthArray; ///<数据库账单的所有月份
@property (nonatomic, assign) NSInteger st; //每个section的变量
@property (nonatomic, strong) NSMutableArray *saveTime; //判断时间是否重叠
@property (nonatomic, copy) NSString *readYear;

@end

@implementation RunningAccountViewController{
    float iconme;  //收入
    float outlsy; //支出
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataBase = [sqlManger dataBaseDefaultManager];
    self.saveTime = [[NSMutableArray alloc]init];

    NSString *String = [NSString stringWithFormat:@"%@",[self years][0]];
    self.perMonthArray = [[NSMutableArray alloc]init];
    self.perMonthArray = [self.dataBase selectBillOfMonth:String];
    
    self.allMoneyArray = [self.dataBase allMoney:String];
    
    self.readYear = String;
    [self displayView];
}


- (void)displayView
{
    //返回按钮
    UIView *BalancesView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SVIEW_WIGHT, BALANCES_HEIGHT)];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(8, 20, 32, 32)];
    [button setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(JumpPage:) forControlEvents:UIControlEventTouchUpInside];
//    [BalancesView addSubview:button];
    
    //饼图按钮
    UIButton *cakeButton = [[UIButton alloc]initWithFrame:CGRectMake(SVIEW_WIGHT - 32 - 8, 20+20, 32, 32)];
    [cakeButton setBackgroundImage:[UIImage imageNamed:@"cake.png"] forState:UIControlStateNormal];
    [cakeButton addTarget:self action:@selector(pushToCake:) forControlEvents:UIControlEventTouchUpInside];
    [BalancesView addSubview:cakeButton];
    
    //余额
    UILabel *BalancesLabel = [[UILabel alloc]initWithFrame:CGRectMake(SVIEW_WIGHT/2-50, BALANCES_HEIGHT/2-50, 100, 50)];
    BalancesView.backgroundColor = [UIColor whiteColor];
    //    BalancesLabel.font = [UIFont systemFontOfSize:40];///<label字体改变
    //    BalancesLabel.font=[UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
    BalancesLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:40];
    BalancesLabel.text = @"结余";
    BalancesLabel.textColor = BALANCES_BACKCOLOR;
    BalancesLabel.textAlignment = NSTextAlignmentCenter;///<label字体对齐
    
    //余额显示金钱
    UILabel *BalancesMoney = [[UILabel alloc]initWithFrame:CGRectMake(SVIEW_WIGHT/2-150, BALANCES_HEIGHT/2, 300, 50)];
    BalancesMoney.font = [UIFont fontWithName:@"CourierNewPS-ItalicMT" size:30];
    
    NSArray *array = [self.dataBase readBudget];
    float st = 0;
    if (array.count != 0) {
        st = [array[0] floatValue];
    }
    
    //支出金额
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM";
    NSString *month = [formatter stringFromDate:date];
    NSString *payMoney = [self.dataBase totalMoney:YES date:month];
    NSInteger outmoney = payMoney.floatValue; //支出
    
    NSString *string = [NSString stringWithFormat:@"%.2f",st - outmoney];
    
    BalancesMoney.text = string;
    BalancesMoney.textColor = MONEY_COLOR;
    BalancesMoney.textAlignment = NSTextAlignmentCenter;///<label字体对齐
    
    
    [BalancesView addSubview:BalancesMoney];
    [BalancesView addSubview:BalancesLabel];
    
    //    UIImageView *imageView = [[UIImageView alloc]initWithFrame:BalancesView.bounds];
    //    imageView.image = [UIImage imageNamed:@"s15.jpg"];
    //    [BalancesView addSubview:imageView];
    //    [BalancesView sendSubviewToBack:imageView];
    [self.view addSubview:BalancesView];
    
    
    //统计金钱
    
    UIView *moneyView = [[UIView alloc]initWithFrame:CGRectMake(0, BalancesView.frame.size.height-50, SVIEW_WIGHT, 50)];
    UILabel *moneyIncome = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 100, moneyView.frame.size.height/2)];
    moneyIncome.text = @"收入";
    moneyIncome.textColor = MONEY_COLOR;
    moneyIncome.textAlignment = NSTextAlignmentCenter;///<label字体对齐
    
    //收入
    UILabel *income = [[UILabel alloc]initWithFrame:CGRectMake(20, moneyIncome.frame.size.height, MONEYVIEW_LEBELWIDtH, moneyView.frame.size.height/2)];
    NSString *incomeString = self.allMoneyArray[1];
    income.text = incomeString;
    income.textColor = MONEY_COLOR;
    income.textAlignment = NSTextAlignmentCenter;///<label字体对齐
    [moneyView addSubview:income];
    [moneyView addSubview:moneyIncome];
    
    
    UILabel *OutlayLabel = [[UILabel alloc]initWithFrame:CGRectMake(moneyView.frame.size.width-120, 0, MONEYVIEW_LEBELWIDtH, moneyView.frame.size.height/2)];
    OutlayLabel.text = @"支出";
    OutlayLabel.textColor = MONEY_COLOR;
    OutlayLabel.textAlignment = NSTextAlignmentCenter;///<label字体对齐
    
    //支出
    UILabel *outlay = [[UILabel alloc]initWithFrame:CGRectMake(moneyView.frame.size.width-120, moneyIncome.frame.size.height, MONEYVIEW_LEBELWIDtH, moneyView.frame.size.height/2)];
    outlay.text = self.allMoneyArray[0];
    outlay.textColor = MONEY_COLOR;
    outlay.textAlignment = NSTextAlignmentCenter;///<label字体对齐
    [moneyView addSubview:outlay];
    [moneyView addSubview:OutlayLabel];
    
    //虚线
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.bounds = CGRectMake(0, 0, moneyView.frame.size.width, moneyView.frame.size.height);
    borderLayer.position = CGPointMake(CGRectGetMidX(moneyView.bounds), CGRectGetMidY(moneyView.bounds));
    
    borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:borderLayer.bounds cornerRadius:CGRectGetWidth(borderLayer.bounds)/2].CGPath;
    //虚线边框
    borderLayer.lineDashPattern = @[@8, @8];
    //实线边框
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.strokeColor = [UIColor redColor].CGColor;
    
    //年
    UILabel *yearLabel = [[UILabel alloc]initWithFrame:CGRectMake(SVIEW_WIGHT/2-30, moneyView.frame.size.height/2-30, 60, 60)];
    
    yearLabel.text = [NSString stringWithFormat:@"%@",self.readYear];
    yearLabel.font = [UIFont systemFontOfSize:25];
    yearLabel.textColor = [UIColor redColor];

    [moneyView addSubview:yearLabel];
    
    [moneyView.layer addSublayer:borderLayer];
    [BalancesView addSubview:moneyView];
    
    self.dict = [NSMutableDictionary dictionary];
    
    
    
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, BALANCES_HEIGHT, SVIEW_WIGHT, SVIEW_HEIGHT-BALANCES_HEIGHT)];
    
    NSMutableArray *numArray = [[NSMutableArray alloc]init];
    for (int i=1; i<self.currentMonth+1; i++) {
        [numArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    self.reversedArray = [[numArray reverseObjectEnumerator] allObjects];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.tableFooterView = [[UIView alloc]init];
    
    //从右到左滑动
    UISwipeGestureRecognizer *RigWipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swapeR:)];
    //从左到右滑动
    UISwipeGestureRecognizer *LefWipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swapeL:)];
    
    RigWipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.tableview addGestureRecognizer:RigWipe];
    
    LefWipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableview addGestureRecognizer:LefWipe];
    
    self.isOpen = YES;
    self.st = 0;
    self.indexString = [[NSString alloc]init];
    [self.view addSubview:self.tableview];
    
}

#pragma mark tableViewDelegate &&tableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSString *yearsString = [NSString stringWithFormat:@"%@",[self years][0]];
    
    if ([self.readYear isEqualToString:yearsString])
    {
        return self.currentMonth;
    }
    
    return 12;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.tableview.frame.size.height/self.reversedArray.count)];
    //月
    UILabel *MonthLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, view.frame.size.height/4, 100, 20)];
    //天
    UILabel *dayLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, view.frame.size.height/2+10-4, 100, 20)];
    //收入
    UILabel *iconmeLabel = [[UILabel alloc]initWithFrame:CGRectMake(ICONMELABEL_X, MonthLabel.frame.origin.y, ICONMELABEL_W, ICONMELABEL_H)];
    //支出
    UILabel *OutlayLabel = [[UILabel alloc]initWithFrame:CGRectMake(ICONMELABEL_X, dayLabel.frame.origin.y, ICONMELABEL_W, ICONMELABEL_H)];
    
    UILabel *iconmeMoenyLabel = [[UILabel alloc]initWithFrame:CGRectMake(ICONMELABEL_X+ICONMELABEL_W, MonthLabel.frame.origin.y, ICONMELABEL_X, ICONMELABEL_H)];
    UILabel *outlsyMoenyLabel = [[UILabel alloc]initWithFrame:CGRectMake(ICONMELABEL_X+ICONMELABEL_W, dayLabel.frame.origin.y, ICONMELABEL_X, ICONMELABEL_H)];
    
    iconmeLabel.text = @"收:";
    OutlayLabel.text = @"支:";
    
    MonthLabel.text = [NSString stringWithFormat:@"%@月",self.reversedArray[section]];
    
    MonthLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:20];
    dayLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:20];
    
    [view addSubview:MonthLabel];
    view.tag = section;
    
    NSInteger resver = [self howManyDaysInThisMonth:[self.reversedArray[section] integerValue]];
    dayLabel.text = [NSString stringWithFormat:@"%@.%d-%@.%ld",self.reversedArray[section],1,self.reversedArray[section],resver];
    [view addSubview:dayLabel];
    
    
    //self.reversedArray 有6个数，分别是当前月到1月
    //self.perMonthArray 有三个数，分别为数据库存了的月份
    
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recognisg:)]];//添加点击事件
    
    NSString *str = [[NSString alloc]init];
    self.st = section;
    if (self.st >= self.perMonthArray.count) {
        self.st = self.perMonthArray.count-1;
    }
    
    if (self.perMonthArray.count != 0) {
        NSRange range1 = {5,2};
        str = [self.perMonthArray[self.st] substringWithRange:range1];//取出月的字符串
        if([str rangeOfString:@"0"].location !=NSNotFound){
            str = [str substringFromIndex:1];
        }
    }


    if ([self.reversedArray[section] isEqualToString: str]) { //判断是否月当前月的section的字符相同
        NSMutableArray *monthArray = [[NSMutableArray alloc]init]; //当前月的账单的和
        
        NSMutableArray *monthIconmeMoney = [[NSMutableArray alloc]init]; //支出
        NSMutableArray *monthoutlsyMoney = [[NSMutableArray alloc]init]; //收入
        
        iconme = 0;
        outlsy = 0;
        monthArray = [[sqlManger dataBaseDefaultManager]readBillMonthNume:self.perMonthArray[self.st]];
        
        for (int i=0; i<monthArray.count; i++) {
            Bill *theBill = [[Bill alloc]init];
            theBill = monthArray[i];
            category *cat = [[sqlManger dataBaseDefaultManager]readCategoryBy:theBill.categoryID];
            if (cat.isOut) {
                [monthoutlsyMoney addObject:theBill.money];
            }else{
                [monthIconmeMoney addObject:theBill.money];
            }
        }
        outlsy = [[sqlManger dataBaseDefaultManager]allExpend:monthoutlsyMoney];
        iconme  = [[sqlManger dataBaseDefaultManager]allRevenueAmount:monthIconmeMoney];
        outlsyMoenyLabel.text = [NSString stringWithFormat:@"%.3f",outlsy];
        iconmeMoenyLabel.text = [NSString stringWithFormat:@"%.3f",iconme];
    }

    
    [view addSubview:iconmeLabel];
    [view addSubview:OutlayLabel];
    [view addSubview:iconmeMoenyLabel];
    [view addSubview:outlsyMoenyLabel];
    //找到每月的收支
    
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.tableview.frame.size.height/self.reversedArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView ==_tableview)
    {
        CGFloat sectionHeaderHeight = self.tableview.frame.size.height/self.reversedArray.count;
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0)
        {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y,0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight)
        {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}

- (void)recognisg:(UITapGestureRecognizer *)sender
{
    NSString *str = [NSString stringWithFormat:@"%ld",sender.view.tag];
    int strNum = str.intValue;
    
    NSLog(@"section,%ld",sender.view.tag); //点击的哪个section
    if ([self.dict[str] isEqual:@(1)])
    {
        //如果点击的那个section点击过了就重新赋值并且关闭cell
        [self.dict setValue:@(0) forKey:str];
        [self.tableview reloadSections:[NSIndexSet indexSetWithIndex:sender.view.tag] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        if (strNum >= self.perMonthArray.count)
        {
            strNum = (int)self.perMonthArray.count-1;
        }
        
        if (self.perMonthArray.count != 0)
        {
            self.billArray = [self.dataBase readBillMonthNume:self.perMonthArray[strNum]];//在这里初始化点击后的cell
        }
        
        if (self.isOpen == YES)
        {
            //只有第一次点击展开才赋值
            self.indexString = str;
        }

        NSString *timeMoneth = [[NSString alloc]init];

        for (int i=0; i<self.perMonthArray.count; i++)
        {
            //从中找到数据库每个月
            timeMoneth = [self.perMonthArray[i] substringFromIndex:6];//取出月的字符串
            if ([self.reversedArray[sender.view.tag] isEqualToString: timeMoneth])
            {
                if(self.indexString == str)
                { //如果点击的值跟上个一样则执行
                    [self.dict setValue:@(1) forKey:str];
                    [self.tableview reloadSections:[NSIndexSet indexSetWithIndex:self.indexString.integerValue] withRowAnimation:UITableViewRowAnimationAutomatic];
                    self.isOpen = NO;
                }
                else
                {
                    [self.dict setValue:@(0) forKey:self.indexString]; //把上一个关闭
                    [self.tableview reloadSections:[NSIndexSet indexSetWithIndex:self.indexString.integerValue] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.dict setValue:@(1) forKey:str];
                    [self.tableview reloadSections:[NSIndexSet indexSetWithIndex:sender.view.tag] withRowAnimation:UITableViewRowAnimationAutomatic];
                    self.indexString = str;
                }
                break;
            }
            else
            {
                [self.dict setValue:@(0) forKey:self.indexString]; //把上一个关闭
                [self.tableview reloadSections:[NSIndexSet indexSetWithIndex:self.indexString.integerValue] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *str = [NSString stringWithFormat:@"%ld",section];
    
    if ([self.dict[str] isEqual:@(1)])
    {
        return self.billArray.count;
    }
    else
    {
        return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"cellID";
    runningCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell==nil)
    {
        cell = [[runningCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    if (self.billArray.count == 0)
    {
        return cell;
    }
    
    Bill *theBill ;
    theBill = self.billArray[indexPath.row];
    [cell config:theBill];
    NSLog(@"indexPath.row--%ld",indexPath.row);
    [self.saveTime addObject:theBill.timeStr];
    
    if (indexPath.row>=1)
    {
        if ([self.saveTime[indexPath.row]  isEqualToString:self.saveTime[indexPath.row-1]])
        {
            cell.typeTime.text = nil;
        }
        else
        {
            NSString *timestr = theBill.timeStr;
            timestr = [timestr substringFromIndex:6];
            cell.typeTime.text = timestr;
        }
    }
    else
    {
        NSString *timestr = theBill.timeStr;
        timestr = [timestr substringFromIndex:6];
        cell.typeTime.text = timestr;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"indexPath-----%ld",indexPath.row);
    DetailViewController *controller = [[DetailViewController alloc]init];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve; //跳转方式
    
    Bill *theBill = [[Bill alloc]init];
    theBill = self.billArray[indexPath.row];
    [controller setValue:theBill forKey:@"toBill"];
    
    [self presentViewController:controller animated:YES completion:nil];
    
}

#pragma mark 扫动

-(void)swapeL:(UISwipeGestureRecognizer *)sender
{
    NSLog(@"haha");
    NSInteger t = (NSInteger)self.readYear.integerValue + 1;
    NSString *year = [self years][0];
    
    if (t > year.integerValue)
    {
        NSLog(@"没有");
    }
    else
    {
        self.readYear = [NSString stringWithFormat:@"%ld",(long)t];
        NSString *yearString = [NSString stringWithFormat:@"%@",[self years][0]];
        if ([self.readYear isEqual:yearString]) {
            self.currentMonth = [[self years][1]integerValue];
        }else{
            self.currentMonth = 12;
        }
        self.perMonthArray = [self.dataBase selectBillOfMonth:self.readYear];
        [self displayView];
        [self.tableview reloadData];
    }

}

-(void)swapeR:(UISwipeGestureRecognizer *)sender
{
    NSLog(@"左咯");
    NSInteger t = (NSInteger)self.readYear.integerValue - 1;
    self.readYear = [NSString stringWithFormat:@"%ld",(long)t];
    NSString *yearString = [NSString stringWithFormat:@"%@",[self years][0]];
    if ([self.readYear isEqual:yearString])
    {
        self.currentMonth = [[self years][1]integerValue];
    }
    else
    {
        self.currentMonth = 12;
    }
    self.perMonthArray = [self.dataBase selectBillOfMonth:self.readYear];
    [self displayView];
    [self.tableview reloadData];
}

#define mark 计算日期
// 获取今年指定月的天数

- (NSInteger)howManyDaysInThisMonth :(NSInteger)imonth
{
    int year = (int)self.readYear.integerValue;
    
    if((imonth == 1)||(imonth == 3)||(imonth == 5)||(imonth == 7)||(imonth == 8)||(imonth == 10)||(imonth == 12))
        
        return 31 ;
    
    if((imonth == 4)||(imonth == 6)||(imonth == 9)||(imonth == 11))
        
        return 30;
    
    if((year%4 == 1)||(year%4 == 2)||(year%4 == 3))
        
    {
        
        return 28;
        
    }
    
    if(year%400 == 0)
        
        return 29;
    
    if(year%100 == 0)
        
        return 28;
    
    return 29;
    
}



#pragma mark 获取当前的年月

- (NSArray *) years
{
    NSMutableArray *yearArr = [[NSMutableArray alloc]init];
    
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth;
    
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    NSInteger year = [dateComponent year];
    
    self.currentMonth = [dateComponent month];
    
    [yearArr addObject:@(year)];
    
    [yearArr addObject:@(self.currentMonth)];
    
    return yearArr;
    
}

#pragma  mark 按钮
- (void)JumpPage:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pushToCake:(UITapGestureRecognizer *)sender
{
        CakeViewController *destVC = [[CakeViewController alloc]init];
        [self presentViewController:destVC animated:YES completion:nil];
}


@end
