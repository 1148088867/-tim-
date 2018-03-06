//
//  HomeViewController.m
//  随手记
//
//  Created by 刘怀智 on 16/5/4.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import "HomeViewController.h"
#import "AddBtnView.h"
#import "contentCell.h"
#import "AddBillViewController.h"
#import "sqlManger.h"
#import "HYBImageCliped.h"
#import "Bill.h"
#import "RunningAccountViewController.h"
#import "DetailViewController.h"
#import "HeaderTableViewCell.h"
#import "budgetController.h"

#define SVIEW_WIDTH self.view.frame.size.width
#define SVIEW_HIGHT self.view.frame.size.height
#define KViewScale SVIEW_WIDTH / 320  ///<比例
#define SCREEN_SIZE [[UIScreen mainScreen] bounds].size
#define KAddBtnWidth  84  * KViewScale
#define KimageHeight SVIEW_HIGHT / 4
#define KmoneyTypeLabelHeight KAddBtnWidth / 2  ///<总收支的view高
#define KDailyBillWidth 150
#define KDailyBillHeight 40
#define KIntermediateLabelHeight (KmoneyTypeLabelHeight - 15) / 2.0
#define KIntermediateLabelWidth (SVIEW_WIDTH - KAddBtnWidth) / 2.0
#define KdropdownLineViewHeight 1
#define KtextColor [UIColor colorWithRed:0.153 green:0.153 blue:0.153 alpha:0.5] ///<默认字体颜色
#define KselectedColor [UIColor colorWithRed:237/255.00 green:146/255.00 blue:65/255.00 alpha:1]///<选中的字体颜色
#define KtitleStr @"当月结余" ///<当月结余显示标题
/** 时光轴颜色 */
#define LineColor [UIColor colorWithWhite:0.800 alpha:1.000];

@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource, contentCellDelegate, AddBtnViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *headView; 
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *dropdownLineView;///<时光轴下拉线条
@property (nonatomic, strong) UIButton *BalanceButton; ///<当月结余显示
@property (nonatomic, strong) UIButton *constomPhoto; ///<更改图片
@property (nonatomic, strong) UILabel *incomeMoney;///<收入金额
@property (nonatomic, strong) UILabel *expensesMoney;///<支出金额
@property (nonatomic, assign) BOOL isClick;
@property (nonatomic, strong) NSIndexPath *currentOpenedCellIndex;
@property (nonatomic, strong) AddBtnView *addBtn;
@property (nonatomic, strong) sqlManger *dataBase;
@property (nonatomic, strong) NSMutableArray *billArray;///<账单数组
@property (nonatomic, assign) BOOL isOut;///<总支出／总收入
@property (nonatomic, strong) NSMutableArray *isOutLabelArray;
@property (nonatomic, strong) NSMutableArray *dateArray;
@property (nonatomic, strong) NSMutableDictionary *billDic;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataBase = [sqlManger dataBaseDefaultManager];
    self.billDic = [self.dataBase billDicWithDate];
    
    self.dateArray = [self.dataBase selectTimesOfBill];
    self.billArray = [NSMutableArray array];
    
    for (NSString *time in self.dateArray)
    {
        [self.billArray addObjectsFromArray:self.billDic[time]];
    }
    
    self.isOut = YES;
    
    [self displayView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.addBtn updataLayer:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateValues];
    [self.BalanceButton setTitle:KtitleStr forState:UIControlStateNormal];
}

- (void)updateValues
{
    self.billDic = [self.dataBase billDicWithDate];
    self.dateArray = [self.dataBase selectTimesOfBill];
    [self.tableView reloadData];
    self.expensesMoney.text = [self.dataBase totalMoney:YES date:nil];
    self.incomeMoney.text = [self.dataBase totalMoney:NO date:nil];
    self.isOut = NO;
    [self setupRingAnimation];
}

#pragma mark TableViewDelegate,TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dateArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *cellIndentifer = @"HeaderTableViewCell";
    NSArray *nib = [[NSBundle mainBundle]loadNibNamed:cellIndentifer owner:nil options:nil];
    HeaderTableViewCell *cell = [nib objectAtIndex:0];
    cell.dateLabel.text = self.dateArray[section];
    NSString *key = self.dateArray[section];
    //显示当天支出金额
    NSArray *bills = self.billDic[key];
    NSMutableArray *outBills = [NSMutableArray array];
    for (Bill *abill in bills) {
        if (abill.category.isOut == YES) {
            [outBills addObject:abill];
        }
    }
    cell.totalMoneyLabel.text = [NSString stringWithFormat:@"%.2f",[self.dataBase totalMoneyOfBillList:outBills]];
    
    return (UIView *)cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSString *time = self.dateArray[section];
    NSMutableArray *array = self.billDic[time];
    
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIndentifer = @"contentCell";

    contentCell *cell = (contentCell *)[tableView dequeueReusableCellWithIdentifier:cellIndentifer];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:cellIndentifer owner:nil options:nil];
        cell = [nib objectAtIndex:0];
//        cell=[[[NSBundle mainBundle]loadNibNamed:cellIndentifer owner:nil options:nil]firstObject];
        
    }
    
//    if (indexPath.row == 0) {
//        Bill *thebill = self.billArray[indexPath.row];
//        cell.data.text = thebill.timeStr; //时间
//        //总消费
//        [cell TraditionalValues:thebill];
//    }
//    else{
//        Bill *lastBill = self.billArray[indexPath.row - 1];
    NSString *time = self.dateArray [indexPath.section];
    NSMutableArray *array = self.billDic[time];
    Bill *currentBill = array[indexPath.row];
//        if ([lastBill.timeStr isEqualToString:currentBill.timeStr]) {
//            cell.data.text = nil;
//            cell.modifiedPhotos.hidden = YES;
//            cell.totalConsumption.hidden = YES;
//            //圆点、总消费 隐藏
//        }
//        else{
////            cell.data.text = currentBill.timeStr;
//            //添加 圆点、总消费
//            
//        }
        [cell TraditionalValues:currentBill];
//    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate=self;
//    _tableView.rowHeight = 50;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailViewController *controller = [[DetailViewController alloc]init];
    NSArray *key = self.dateArray[indexPath.section];
    NSMutableArray *array = self.billDic[key];
    
    Bill *theBill = array[indexPath.row];
    [controller setValue:theBill forKey:@"toBill"];
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:controller animated:YES completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    CGFloat viewHeight = scrollView.contentOffset.y;
    CGPoint offset = scrollView.contentOffset;  // 当前滚动位移
    CGRect bounds = scrollView.bounds;          // UIScrollView 可视高度
    CGSize size = scrollView.contentSize;         // 滚动区域
    UIEdgeInsets inset = scrollView.contentInset;
    float ys = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    
    float reload_distance = 10;
    if (ys > (h + reload_distance)) {
        // 滚动到底部
//        NSLog(@"滚动到底部");
        // ...
    }
    
//    NSLog(@"offset: %f", offset.y);
//    NSLog(@"content.height: %f", size.height);
//    
//    NSLog(@"inset.top: %f", inset.top);
//    NSLog(@"inset.bottom: %f", inset.bottom);
//    NSLog(@"pos: %f of %f", y, h);
    
    
    
    CGFloat  y = [scrollView.panGestureRecognizer translationInView:self.tableView].y;
//    NSLog(@"scrollView--%f",scrollView.contentOffset.y);
    if (y > -4.5){
//        NSLog(@"yyyyy%f",y);
        //        NSLog(@"hhhhhh%f",viewHeight);
        self.dropdownLineView.frame = CGRectMake((SCREEN_SIZE.width-3)/2, -y, KdropdownLineViewHeight, y);
        [self.tableView bringSubviewToFront:self.dropdownLineView];
    }else{
//        NSLog(@"123yyyyy%f",scrollView.contentOffset.y);
        self.dropdownLineView.frame = CGRectMake((SCREEN_SIZE.width-3)/2, scrollView.contentOffset.y, KdropdownLineViewHeight, scrollView.contentOffset.y);
        [self.tableView sendSubviewToBack:self.dropdownLineView];
    }
//
}

- (void)longPressOfHeadImage
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"更换图片" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self constomPhoto];
    }];
    [controller addAction:cancelAction];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)displayView{
    //头部图片显示
    
    self.headView = [[UIView alloc]initWithFrame:CGRectMake(0,0, SVIEW_WIDTH, SVIEW_HIGHT/4)];
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressOfHeadImage)];
    [self.headView addGestureRecognizer:longPress];
    self.headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.headView.frame.size.width, KimageHeight)];
    
    
    
    self.headImageView.image = [UIImage imageNamed:@"night"];
    if ([self.dataBase isHaveImage] ) {
        self.headImageView.image = [self.dataBase readImage][0];
    }
    [self.headView addSubview:self.headImageView];
    
    
    
    //当月结余显示
    self.BalanceButton = [[UIButton alloc]initWithFrame:CGRectMake(SVIEW_WIDTH/2-KDailyBillWidth/2, 20+20, KDailyBillWidth, KDailyBillHeight)];
    [self.BalanceButton setTitle:KtitleStr forState:UIControlStateNormal];
    self.BalanceButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.BalanceButton setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.3]];
    
    [self.BalanceButton hyb_addCornerRadius:50];
    self.BalanceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter; //文字居中
    self.BalanceButton.contentEdgeInsets = UIEdgeInsetsMake(0,10, 0, 10); //文字距离边框10个像素
    
    [self.BalanceButton addTarget:self action:@selector(Balance:) forControlEvents:UIControlEventTouchUpInside];
    self.isClick = YES;
    [self.headView addSubview:self.BalanceButton];
    
    //
    
    //更改图片
//    self.constomPhoto = [[UIButton alloc]initWithFrame:CGRectMake(SVIEW_WIDTH-70, 20, 32, 32)];
//    [self.constomPhoto setBackgroundImage:[UIImage imageNamed:@"ph"] forState:UIControlStateNormal];
//    self.constomPhoto.titleLabel.font = [UIFont systemFontOfSize:15];
//    [self.constomPhoto setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.3]];
//    
//    [self.constomPhoto hyb_addCornerRadius:30];
//    self.constomPhoto.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter; //文字居中
//    self.constomPhoto.contentEdgeInsets = UIEdgeInsetsMake(0,10, 0, 10); //文字距离边框10个像素
//    
//    [self.constomPhoto addTarget:self action:@selector(constomPhoto:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.headView addSubview:self.constomPhoto];
    [self.view addSubview:self.headView];
    
    //总收入
    UIView *revenueExpenditure = [[UIView alloc]initWithFrame:CGRectMake(0, self.headView.frame.size.height, SVIEW_WIDTH, KmoneyTypeLabelHeight)];
    revenueExpenditure.backgroundColor = [UIColor clearColor];
    self.isOutLabelArray = [NSMutableArray array];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeAddBtnColorsByIsOut:)];
    
    UILabel *totalIncome = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, KIntermediateLabelWidth, KIntermediateLabelHeight)];
    totalIncome.textColor = KtextColor;
    totalIncome.font = [UIFont systemFontOfSize:15];
    totalIncome.textAlignment = NSTextAlignmentCenter;
    totalIncome.text = @"收入";
    [totalIncome addGestureRecognizer:tap];
    totalIncome.userInteractionEnabled = YES;
    
    self.incomeMoney = [[UILabel alloc]initWithFrame:CGRectMake(0,totalIncome.frame.origin.y + KIntermediateLabelHeight +5, KIntermediateLabelWidth, KIntermediateLabelHeight)];
    self.incomeMoney.textColor = KtextColor;
    self.incomeMoney.font = [UIFont systemFontOfSize:15];
    self.incomeMoney.userInteractionEnabled = YES;
    self.incomeMoney.tag = 110;
    self.incomeMoney.textAlignment = NSTextAlignmentCenter;
    [revenueExpenditure addSubview:self.incomeMoney];
    [self.incomeMoney addGestureRecognizer:tap];
    
    [self.isOutLabelArray addObject:totalIncome];
    [self.isOutLabelArray addObject:self.incomeMoney];
    //总支出
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeAddBtnColorsByIsOut:)];
    UILabel *totalExpenses = [[UILabel alloc]initWithFrame:CGRectMake(KIntermediateLabelWidth + KAddBtnWidth, 5, KIntermediateLabelWidth, KIntermediateLabelHeight)];
    totalExpenses.textColor = KtextColor;
    totalExpenses.font = [UIFont systemFontOfSize:15];
    totalExpenses.textAlignment = NSTextAlignmentCenter; //居中显示
    totalExpenses.userInteractionEnabled = YES; // 可点击
    totalExpenses.text = @"支出";
    [totalExpenses addGestureRecognizer:tap1];
    
    self.expensesMoney = [[UILabel alloc]initWithFrame:CGRectMake(totalExpenses.frame.origin.x, totalExpenses.frame.origin.y + KIntermediateLabelHeight + 5, KIntermediateLabelWidth, KIntermediateLabelHeight)];
    self.expensesMoney.textColor = KtextColor;
    self.expensesMoney.font = [UIFont systemFontOfSize:15];
    self.expensesMoney.userInteractionEnabled = YES;
    self.expensesMoney.textAlignment = NSTextAlignmentCenter;
    [revenueExpenditure addSubview:self.expensesMoney];
    self.expensesMoney.tag = 111;
    [self.expensesMoney addGestureRecognizer:tap1];
    [revenueExpenditure addSubview:totalExpenses];
    [revenueExpenditure addSubview:totalIncome];
    [self.view addSubview:revenueExpenditure];
    [self.isOutLabelArray addObject:totalExpenses];
    [self.isOutLabelArray addObject:self.expensesMoney];
    
    //添加账单按钮
    self.addBtn = [[AddBtnView alloc]initWithFrame:CGRectMake(SVIEW_WIDTH/2-50, self.headView.frame.size.height, KAddBtnWidth, KAddBtnWidth)];
    self.addBtn.delegate = self;
    self.addBtn.imageName = @"刷新";
    [self.view addSubview:self.addBtn];
    
    
    //tableView
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, revenueExpenditure.frame.origin.y+revenueExpenditure.frame.size.height, SVIEW_WIDTH, SVIEW_HIGHT - KimageHeight - KmoneyTypeLabelHeight)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
//    UISwipeGestureRecognizer *onWipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swape:)];
//    //设置方向(只支持一个方向)
//    onWipe.direction = UISwipeGestureRecognizerDirectionLeft;
//    [self.view addGestureRecognizer:onWipe];
    
//    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeAction:)];
//    right.direction = UISwipeGestureRecognizerDirectionRight;
//    [self.view addGestureRecognizer:right];
    

    //时光轴下拉线条
    self.dropdownLineView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_SIZE.width-1)/2,0 , 1, 0)];
    self.dropdownLineView.backgroundColor = LineColor;
    [self.tableView addSubview:self.dropdownLineView];
    //* 放到tableView的最底层 */
    [self.tableView sendSubviewToBack:self.dropdownLineView];
}

#pragma mark - contentCellDelegate

- (void)willPressButton:(contentCell *)cell
{
    NSLog(@"%@",cell.menuIsOpened?@"开启":@"关闭");
    
    NSIndexPath *indexPath=[self.tableView indexPathForCell:cell];//点击cell的那一行
    
    if (self.currentOpenedCellIndex && self.currentOpenedCellIndex.row!=indexPath.row) {
        contentCell *theCell=[self.tableView cellForRowAtIndexPath:self.currentOpenedCellIndex];
        [theCell imageButton:nil];
    }
    
    if (cell.menuIsOpened) {
        self.currentOpenedCellIndex=indexPath; //如果是展开的，把点击的那一行赋值给全局
    }else{
        self.currentOpenedCellIndex=nil;
    }
}
//删除
- (void)deleteSelectedBill:(contentCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSArray *key = self.dateArray[indexPath.section];
    NSMutableArray *array = self.billDic[key];
    Bill *deletBill = array[indexPath.row];
    [self.dataBase deleteBill:deletBill];
    [array removeObject:deletBill];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    //跟新显示
    self.billDic = [self.dataBase billDicWithDate];
    self.dateArray = [self.dataBase selectTimesOfBill];
    [self.tableView reloadData];
    self.expensesMoney.text = [self.dataBase totalMoney:YES date:nil];
    self.incomeMoney.text = [self.dataBase totalMoney:NO date:nil];
    [self changeAddBtnColorsByIsOut:nil];

}
//修改
- (void)modifySelectedBill:(contentCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSArray *key = self.dateArray[indexPath.section];
    NSMutableArray *array = self.billDic[key];
    Bill *selectedBill = array[indexPath.row];
    
    AddBillViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RightWin"];
//    AddBillViewController *destVC = [[AddBillViewController alloc]init];
    [controller setValue:selectedBill forKey:@"thisBill"];
    
    [self presentViewController:controller animated:YES completion:nil];
    
    
}

#pragma mark AddBtnViewDelegate

- (void)juttonJump:(AddBtnView *)btn
{
    [self.addBtn updataLayer:YES];
//    UIStoryboard *storyB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    AddBillViewController *controller = [storyB instantiateViewControllerWithIdentifier:@"RightWin"];
//    
//    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - 切换添加按钮的外环内容

-(void)setupRingAnimation
{
    self.isOut = YES;
    NSMutableArray *colorArray = [self.dataBase scaleOfBillMoneyFromTotalMoney:self.isOut date:nil];
    self.addBtn.colorsArray = colorArray;
    
    //收入
    UILabel *title = self.isOutLabelArray[0];
    title.textColor = KtextColor;
    self.incomeMoney.textColor = KtextColor;
    
    //支出
    UILabel *other = self.isOutLabelArray[2];
    other.textColor = KselectedColor;
    self.expensesMoney.textColor = KselectedColor;
}

- (void)changeAddBtnColorsByIsOut:(UITapGestureRecognizer *)sender
{
    [self.addBtn updataLayer:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (sender.view.tag == 110) {
            self.isOut = NO;
        }
        else
        {
            self.isOut = YES;
        }
        
        NSMutableArray *colorArray = [self.dataBase scaleOfBillMoneyFromTotalMoney:self.isOut date:nil];
        self.addBtn.colorsArray = colorArray;
        if (self.isOut  == NO)
        {
            //收入
            UILabel *title = self.isOutLabelArray[0];
            title.textColor = KselectedColor;
            self.incomeMoney.textColor = KselectedColor;
            //支出
            UILabel *other = self.isOutLabelArray[2];
            other.textColor = KtextColor;
            self.expensesMoney.textColor = KtextColor;
        }
        else
        {
            //收入
            UILabel *title = self.isOutLabelArray[0];
            title.textColor = KtextColor;
            self.incomeMoney.textColor = KtextColor;
            //支出
            UILabel *other = self.isOutLabelArray[2];
            other.textColor = KselectedColor;
            self.expensesMoney.textColor = KselectedColor;
        }

        [self.addBtn updataLayer:YES];
    });
}
#pragma mark  顶部背景图片点击点击事件

- (void)Balance:(UIButton *) sender
{
    if (self.isClick == YES)
    {
        NSArray *array = [self.dataBase readBudget];
        if(array.count == 0)
        {
            NSMutableArray *mutArray = [self.dataBase allMoney:@"2016"];
            float Surplus = [self.dataBase allExpend:mutArray];
            
            NSString *string = [NSString stringWithFormat:@"-%.2f",Surplus];
            
            //
//            self.BalanceButton.frame = CGRectMake(SVIEW_WIDTH/2-50, 20, KDailyBillWidth, KDailyBillHeight);
            
            [self.BalanceButton setTitle:string forState:UIControlStateNormal];
            
            self.isClick = NO;
        }
        else
        {
            float st = [array[0] floatValue];
            //支出金额
            NSDate *date = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            formatter.dateFormat = @"yyyy-MM";
            NSString *month = [formatter stringFromDate:date];
            NSString *payMoney = [self.dataBase totalMoney:YES date:month];
            float outMoney = payMoney.floatValue; //支出
            
//            NSMutableArray *mutArray = [self.dataBase allMoney:@"2016"];
//            float Surplus = [self.dataBase allExpend:mutArray];
            
            NSString *string = [NSString stringWithFormat:@"%.2f",st - outMoney];
//            //更改按钮宽度，使其适应文字宽度
//            CGSize titleSize = [string sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(KDailyBillWidth, KDailyBillHeight)];
//            CGRect rect = self.BalanceButton.frame ;
//            rect.size.width = titleSize.width;
//            self.BalanceButton.frame = rect;
            
            [self.BalanceButton setTitle:string forState:UIControlStateNormal];
            self.isClick = NO;
        }
    }
    else
    {
        [self.BalanceButton setTitle:KtitleStr forState:UIControlStateNormal];
        self.isClick = YES;
    }
    
}

//#pragma mark ---滑动方法的实现
//- (void)swape:(UISwipeGestureRecognizer *)aSwape
//{
//    RunningAccountViewController *controller = [[RunningAccountViewController alloc] init];
////    [self.navigationController pushViewController:controller animated:YES];
//    [self presentViewController:controller animated:YES completion:nil];
//    NSLog(@"骚动了哦");
//}

////跳转到预算
//- (void)rightSwipeAction:(UISwipeGestureRecognizer *)sender
//{
//    self.isClick = YES;
//    budgetController *contr = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"budget"];
//    [self presentViewController:contr animated:YES completion:nil];
//}

#pragma mark 读取图片
- (void)constomPhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *Picker = [[UIImagePickerController alloc]init]; //读取本地图片
        Picker.delegate = self;
        Picker.allowsEditing = YES;
        [self presentViewController:Picker animated:YES completion:nil];
    }
}

-(NSString *)imagePath:(NSString *)imageFileName
{
    NSArray *dirList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [dirList firstObject];
    NSLog(@"%@",path);
    return  [path stringByAppendingPathComponent:imageFileName];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //选择照片后的选择
    NSLog(@"%@",info);
    [self dismissViewControllerAnimated:YES completion:^{
        //是否开启视图动画
    }];
    self.headImageView.image = info[UIImagePickerControllerEditedImage];
    [[sqlManger dataBaseDefaultManager]addImage:info[UIImagePickerControllerEditedImage]];
    
}


@end 
