//
//  CakeViewController.m
//  随手记
//
//  Created by 刘怀智 on 16/6/12.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import "CakeViewController.h"
#import "TypeBillListViewController.h"
#import "budgetController.h"
#import "AddBtnView.h"
#import "sqlManger.h"
#import "category.h"
#import "iCarousel.h"

#define KMainViewWidth self.view.frame.size.width
#define KMainViewHeight self.view.frame.size.height
#define KScaleOfView   KMainViewWidth / 320.0 ///< 屏幕适配比例
#define kcakeViewWidth 150 * KScaleOfView ///<饼图宽
#define KPointViewHeight 20 * KScaleOfView ///<指针线高
#define KtextColor [UIColor colorWithRed:0.153 green:0.153 blue:0.153 alpha:0.5] ///<默认字体颜色
#define KselectedColor [UIColor colorWithRed:237/255.00 green:146/255.00 blue:65/255.00 alpha:1]///<选中的字体颜色
#define KanimationTime 0.5 ///< 饼图旋转动画时间
#define KYearH 13 * KScaleOfView
#define KYearW 40 * KScaleOfView
#define KYearW1 72 * KScaleOfView
#define KTimeListH 50 * KScaleOfView
#define KMonthTextFont 14 * KScaleOfView

@interface CakeViewController () <iCarouselDelegate,iCarouselDataSource>

@property (nonatomic, strong) AddBtnView *cakeView; ///< 饼图
@property (nonatomic, strong) sqlManger *dataBaseManager;
@property (nonatomic, assign) CGFloat firstEngle; ///< 进入界面时调整到最大的部分的中心
@property (nonatomic, assign) NSInteger index; ///< 当前选中的数组中的第几个
@property (nonatomic, assign) CGFloat begainEngle; ///< 开始旋转的弧度
@property (nonatomic, strong) UIView *pointView;///<  指针
@property (nonatomic, strong) UILabel *moneyLabel; ///<  类别金额
@property (nonatomic, strong) UILabel *nameLabel; ///< 类别名称
@property (nonatomic, strong) UIImageView *typeImage; ///< 类别图
@property (nonatomic, strong) UILabel *scaleLabel; ///< 比例label
@property (nonatomic, strong) UIButton *changBtn; ///< 旋转按钮
@property (nonatomic, strong) UILabel *countLabel; ///< 账单数量
@property (nonatomic, strong) UILabel *incomeLabel;
@property (nonatomic, strong) UILabel *outLabel;
@property (nonatomic, assign) BOOL isOut;
@property (nonatomic, assign) BOOL isFirstAnimation;
@property (nonatomic, assign) BOOL isAnimationRunning;
@property (nonatomic, copy)   NSString *selectedTimeStr;
@property (nonatomic, strong) category *selectedType;
 //时间列表
@property (nonatomic, strong) NSDictionary *items;
@property (nonatomic, strong) iCarousel *carousel;
@property (nonatomic, strong) UILabel *yearLabel;
@property (nonatomic, strong) NSMutableArray *viewArray;
@property (nonatomic, assign) NSInteger previousSelectedIndex;
@property (nonatomic, strong) NSArray *timeArray;
@property (nonatomic, strong) NSMutableArray *showArray;


@end

@implementation CakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isOut = YES;
    self.isFirstAnimation = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
//    sqlManager
    self.dataBaseManager  = [sqlManger dataBaseDefaultManager];
    //cakeView
    [self creatCakeView];
    //time
    [self creatTimeList];
    // back
    [self creatGestureRecognizer];
//    topViews
    [self creatTopLabels];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (category *)selectedType
{
    NSDictionary *dic = self.cakeView.aboutRingArray[self.index];
    _selectedType = dic[@"type"];
    return _selectedType;
}

- (void) creatPonitViews
{
    NSDictionary *dict = self.cakeView.aboutRingArray[self.index];
    category *type = dict[@"type"];
    NSString *scale = dict[@"scale" ];
//    pointView
    self.pointView = [[UIView alloc]initWithFrame:CGRectMake(KMainViewWidth / 2 - 1.5 * KScaleOfView, ((KMainViewHeight - kcakeViewWidth) / 2) - KPointViewHeight - 10, 1 * KScaleOfView, KPointViewHeight)];
    [self.view addSubview:self.pointView];
//    MoneyLabel
    CGFloat moneyX = (KMainViewWidth - 100) / 2;
    CGFloat moneyY = self.pointView.frame.origin.y - 20;
    self.moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(moneyX, moneyY, 100, 20)];
    self.moneyLabel.textAlignment = NSTextAlignmentCenter;
    self.moneyLabel.font = [UIFont systemFontOfSize:KMonthTextFont];
    self.moneyLabel.textColor = KtextColor;
    [self.view addSubview: self.moneyLabel];
    //    NameLabel
    CGFloat nameX = (KMainViewWidth - 100) / 2;
    CGFloat nameY = self.moneyLabel.frame.origin.y - 20;
    self.nameLabel =[[UILabel alloc]initWithFrame:CGRectMake(nameX, nameY, 100, 20)];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.textColor = KtextColor;
    self.nameLabel.font = [UIFont systemFontOfSize:KMonthTextFont];
    [self.view addSubview:self.nameLabel];
    [self creatCakeCenterViews];
    [self setViewsValue:type scale:scale time:nil];
}

- (void)creatCakeCenterViews
{
    UIView *centerView = [[UIView alloc]initWithFrame:CGRectMake(self.cakeView.lineWidth, self.cakeView.lineWidth, kcakeViewWidth - self.cakeView.lineWidth-35, kcakeViewWidth - self.cakeView.lineWidth-35)];
    UITapGestureRecognizer *centerTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(typeBillList:)];
    [centerView addGestureRecognizer:centerTap];
    
    centerView.center = self.cakeView.center;
    [self.view addSubview:centerView];
    CGFloat imageX = centerView.frame.size.width / 2 - 20 * KScaleOfView;
    CGFloat imageY = centerView.frame.size.height / 2 - 5 - 40 * KScaleOfView;
    self.typeImage = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, imageY, 40 * KScaleOfView, 40 * KScaleOfView)];
    [centerView addSubview:self.typeImage];
    
    CGFloat scaleX = centerView.frame.size.width / 2 - 40 * KScaleOfView;
    CGFloat scaleY = centerView.frame.size.height / 2 - 5 ;
    self.scaleLabel = [[UILabel alloc]initWithFrame:CGRectMake(scaleX, scaleY, 80 * KScaleOfView, 40 * KScaleOfView)];
    self.scaleLabel.textAlignment = NSTextAlignmentCenter;
    self.scaleLabel.textColor = KtextColor;
    [centerView addSubview:self.scaleLabel];
    [self creatBtnViews];
    
}

- (void)creatBtnViews
{
    CGFloat countX = KMainViewWidth / 2 - 40 * KScaleOfView;
    CGFloat countY = self.cakeView.frame.origin.y + kcakeViewWidth + 60 * KScaleOfView;
    self.countLabel = [[UILabel alloc]initWithFrame:CGRectMake(countX, countY, 80 * KScaleOfView, 30 * KScaleOfView)];
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    self.countLabel.textColor = KtextColor;
    [self.view addSubview:self.countLabel];
    
    CGFloat btnX = KMainViewWidth / 2 - 20 * KScaleOfView;
    CGFloat btnY = self.countLabel.frame.origin.y + self.countLabel.frame.size.height ;
    self.changBtn = [[UIButton alloc]initWithFrame:CGRectMake(btnX, btnY, 40 * KScaleOfView, 40 * KScaleOfView)];
    [self.changBtn setImage:[UIImage imageNamed:@"chang"] forState:UIControlStateNormal];
    //    点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(animationForCakeView)];
    [self.changBtn addGestureRecognizer:tap];
    [self.view addSubview:self.changBtn];
    
}

- (void)setViewsValue:(category *)type scale:(NSString *)scale time:(NSString *)timeStr
{
    self.pointView.backgroundColor = type.categoryColor;
    self.moneyLabel.text = [NSString stringWithFormat:@"%.2f",[self.dataBaseManager totalMoneyOfType:type.categoryID time:timeStr]];
    self.nameLabel.text = type.categoryName;
    self.typeImage.image = type.iconImage;
    self.scaleLabel.text = [NSString stringWithFormat:@" %.2f％",scale.floatValue * 100];
    self.countLabel.text = [NSString  stringWithFormat:@"%ld 笔",[self.dataBaseManager billCountOfCategory:type.categoryID time:timeStr]];

}

#pragma mark -  cakeView
// 饼图
- (void)creatCakeView
{
    self.cakeView = [[AddBtnView alloc]initWithFrame:CGRectMake(0, 0 , kcakeViewWidth, kcakeViewWidth)];
    self.cakeView.center = CGPointMake(KMainViewWidth / 2, KMainViewHeight / 2 );
    [self.view addSubview:self.cakeView];
//    线宽
    self.cakeView.lineWidth = 20 * KScaleOfView;
//    赋值
//    NSMutableArray *colorArray = [self.dataBaseManager scaleOfBillMoneyFromTotalMoney:YES date:nil];
//    self.cakeView.colorsArray = colorArray;
//    显示饼图内容
    [self.cakeView updataLayer:YES];
//    进入界面时选中的部分
    self.index = self.cakeView.aboutRingArray.count - 1;

//    修改cakeView当前的弧度 正好指着最大的部分的中心
//    NSDictionary *lastDic = self.cakeView.aboutRingArray.lastObject;
//    NSNumber *last = lastDic[@"center"];
//    self.firstEngle = - (M_PI - last.floatValue);
//    self.cakeView.transform = CGAffineTransformRotate(self.cakeView.transform, self.firstEngle);
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPie:)];
    self.cakeView.userInteractionEnabled = YES;
    [self.cakeView addGestureRecognizer:tapGR];
    
    self.isFirstAnimation = YES;
    //    pointView
    [self creatPonitViews];
}
- (void)clickPie:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:[tap view]];
   NSInteger index = [self.cakeView getLayerIndexWithPoint:point];
    NSLog(@"%i,index= %li",__LINE__,index);
}
//动画
- (void)animationForCakeView
{
//    是否在动画中
    if (self.isAnimationRunning == YES) {
        self.changBtn.enabled = NO;
        return;
    }
//    btn动画
    CABasicAnimation *btnAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    btnAnimation.fromValue=@(0);
    btnAnimation.toValue = @(M_PI * 2);
    btnAnimation.duration = KanimationTime;
    btnAnimation.repeatCount = 0;
    btnAnimation.removedOnCompletion = NO;
    btnAnimation.fillMode = kCAFillModeForwards;
    [self.changBtn.layer addAnimation:btnAnimation forKey:@"btn"];
//    第一次动画
    if (self.isFirstAnimation == YES) {
        self.begainEngle = self.firstEngle;
        self.isFirstAnimation = NO;
    }
    
//    当前的选中部分
    NSDictionary *dict1 = self.cakeView.aboutRingArray[self.index];
    NSNumber *elem1 = dict1[@"center"];
    CGFloat move1 = elem1.floatValue;
//    下次选中的部分
    NSInteger next = self.index - 1;
    if (next < 0) {
        next = self.cakeView.aboutRingArray.count - 1;
    }
    NSDictionary *dict2 = self.cakeView.aboutRingArray[next];
    NSNumber *elem2= dict2[@"center"];
    CGFloat move2 = elem2.floatValue;
    //移动的弧度
    CGFloat moveEngle = move1 + move2;
    
//    动画
    CABasicAnimation *cakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    cakeAnimation.fromValue=@(self.begainEngle);
    cakeAnimation.byValue = @(moveEngle);
    cakeAnimation.duration = KanimationTime;
    cakeAnimation.repeatCount = 0;
    cakeAnimation.removedOnCompletion = NO;
    cakeAnimation.fillMode = kCAFillModeForwards;
    [self.cakeView.layer addAnimation:cakeAnimation forKey:@"cake"];
//    动画完成后更新饼图的弧度
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(KanimationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.cakeView.transform = CGAffineTransformRotate(self.cakeView.transform, moveEngle);
        [self.cakeView.layer removeAllAnimations];
        [self setViewsValue:dict2[@"type" ] scale:dict2[@"scale"] time:self.selectedTimeStr ];
        self.isFirstAnimation = NO;
        self.changBtn.enabled = YES;
    });
    
//    重新赋值开始弧度
    self.begainEngle = self.begainEngle + moveEngle;
//    循环
    self.index --;
    if (self.index <0) {
        self.index = self.cakeView.aboutRingArray.count - 1;
    }
}

#pragma mark - 顶部的收入支出

- (void)creatTopLabels
{
    //  收入
    self.incomeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20+13, 80, 40 * KScaleOfView)];
    NSString *incomeMoney = [self.dataBaseManager totalMoney:NO date:self.selectedTimeStr];
    self.incomeLabel.text = [NSString stringWithFormat:@"收入 \n %.2f", incomeMoney.floatValue];
    self.incomeLabel.textColor = KtextColor;
    self.incomeLabel.numberOfLines = 2;
    self.incomeLabel.font = [UIFont systemFontOfSize:KMonthTextFont];
    self.incomeLabel.textAlignment = NSTextAlignmentCenter;
    self.incomeLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *incomeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(incomeTapGesture:)];
    [self.incomeLabel addGestureRecognizer:incomeTap];
    [self.view addSubview:self.incomeLabel];

    //  支出
    self.outLabel = [[UILabel alloc]initWithFrame:CGRectMake(KMainViewWidth - 90, 20 + 13, 80, 40 * KScaleOfView)];
    NSString *outMoney = [self.dataBaseManager totalMoney:YES date:self.selectedTimeStr];
    self.outLabel.text = [NSString stringWithFormat:@"支出 \n %.2f", outMoney.floatValue];
    self.outLabel.textColor = KselectedColor;
    self.outLabel.userInteractionEnabled = YES;
    self.outLabel.numberOfLines = 2;
    self.outLabel.font = [UIFont systemFontOfSize:KMonthTextFont];
    self.outLabel.textAlignment = NSTextAlignmentCenter;
    
    UITapGestureRecognizer *outTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(outTapGesture:)];
    [self.outLabel addGestureRecognizer:outTap];
    [self.view addSubview:self.outLabel];
}

- (void)incomeTapGesture:(UITapGestureRecognizer *)sender
{
    self.isOut = NO;
//    self.timeArray = [self.dataBaseManager monthOfAllBill:self.isOut];
//    [self.carousel reloadData];
//    self.carousel.currentItemIndex = self.showArray.count - 1;
//    [self carouselCurrentItemIndexDidChange:self.carousel];
    [self updateViewsValue];
}
- (void)outTapGesture:(UITapGestureRecognizer *)sender
{
    self.isOut = YES;
//    self.timeArray = [self.dataBaseManager monthOfAllBill:self.isOut];
//    [self.carousel reloadData];
    [self updateViewsValue];
}

#pragma mark - 手势

- (void)creatGestureRecognizer
{
    //返回上一页
    UISwipeGestureRecognizer *back = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftSwipeAction:)];
    back.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:back];

}

- (void)leftSwipeAction:(UISwipeGestureRecognizer *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//跳转到类别账单
- (void)typeBillList:(UITapGestureRecognizer *)sender
{
    
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    //由storyboard根据myView的storyBoardID来获取我们要切换的视图
    TypeBillListViewController *controller = [story instantiateViewControllerWithIdentifier:@"typeBillList"];
    [controller setValue:self.selectedType forKey:@"thisCategory"];
    NSString *timeStr;
    if (self.carousel.currentItemIndex > self.timeArray.count - 1) {
        timeStr = nil;
    }
    else
    {
    timeStr = self.timeArray[self.carousel.currentItemIndex];
    }
    [controller setValue:timeStr forKey:@"timeStr"];
     [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - 时间列表
- (void)creatTimeList
{
    //时间列表
    self.carousel = [[iCarousel alloc]initWithFrame:CGRectMake(-1, 64 *KScaleOfView, self.view.frame.size.width + 2, KTimeListH)];
    self.carousel.type = iCarouselTypeLinear;
    
    [self.view addSubview:self.carousel];
    self.carousel.delegate = self;
    self.carousel.dataSource = self;
    self.carousel.layer.borderWidth = 0.5;
    self.carousel.layer.borderColor = KtextColor.CGColor;
    
    
    self.yearLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - KYearW / 2, self.carousel.frame.origin.y + self.carousel.frame.size.height - KYearH / 2, KYearW, KYearH )];
    self.yearLabel.textAlignment = NSTextAlignmentCenter;
    self.yearLabel.text = @"2016";
    self.yearLabel.font = [UIFont systemFontOfSize:KMonthTextFont - 3];
    self.yearLabel.textColor = KselectedColor;
    self.yearLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.yearLabel];
    self.viewArray = [NSMutableArray array];
    self.carousel.currentItemIndex = self.showArray.count - 1;
}
- (NSDictionary *)items {
    if (!_items) {
        _items = @{@"01":@"JAN\n1月",@"02":@"FEB\n2月",@"03":@"MAR\n3月",@"04":@"APR\n4月",@"05":@"MAY\n5月",@"06":@"JUN\n6月",@"07":@"JUL\n7月",@"08":@"AUG\n8月",@"09":@"SEP\n9月",@"10":@"OCT\n10月",@"11":@"NOV\n11月",@"12":@"DEC\n12月",@"all":@"ALL\n全部"};
    }
    return _items;
}
- (NSArray *)timeArray
{
    if (!_timeArray) {
        _timeArray = (NSArray *)[self.dataBaseManager monthOfAllBill];
    }
    return _timeArray;
}
- (NSMutableArray *)showArray
{
    
    _showArray = [NSMutableArray array];
    for (NSString *time in self.timeArray) {
        NSArray *strs = [time componentsSeparatedByString:@"-"];
        NSString *year = strs.firstObject;
        NSString *month = strs.lastObject;
        NSDictionary *dic = @{@"month":self.items[month], @"year":year};
        [_showArray addObject:dic];
    }
    NSDictionary *first = _showArray.firstObject;
    NSDictionary *last = _showArray.lastObject;
    NSString *year = [NSString stringWithFormat:@"%@~%@", first[@"year"], last[@"year"]];
    NSString *month = self.items[@"all"];
    NSDictionary *dic =  @{@"month":month, @"year":year};
    [_showArray addObject:dic];
    
    return _showArray;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.carousel = nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return self.showArray.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    
    UIButton *button = (UIButton *)view;
    //    if (!button) {
    button  = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 70, self.carousel.frame.size.height - 10) ];
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *dic = self.showArray[index];
    button.titleLabel.font = [UIFont systemFontOfSize:KMonthTextFont];
    [button setTitle:[NSString stringWithFormat:@"%@",dic[@"month"]] forState:UIControlStateNormal];
    [button setTitleColor:KtextColor forState:UIControlStateNormal];
    //    }
    return button;
}

//  选中
- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    NSInteger index = carousel.currentItemIndex;
    NSDictionary *dic = self.showArray[index];
    //    选中的年
    self.yearLabel.text = dic[@"year"];
    if (index == self.showArray.count - 1) {
        self.yearLabel.frame = CGRectMake(self.view.frame.size.width / 2 - KYearW1 / 2, self.carousel.frame.origin.y + self.carousel.frame.size.height - KYearH / 2 ,KYearW1, KYearH);
    }
    else{
        self.yearLabel.frame = CGRectMake(self.view.frame.size.width / 2 - KYearW / 2, self.carousel.frame.origin.y + self.carousel.frame.size.height - KYearH / 2, KYearW, KYearH);
    }
    
    //    选中的月
    UIButton *button = (UIButton *)carousel.currentItemView;
    [button setTitleColor:KselectedColor forState:UIControlStateNormal];
    
    if (self.previousSelectedIndex != index) {
        UIButton *previousButton = (UIButton *)[carousel itemViewAtIndex:self.previousSelectedIndex];
        [previousButton setTitleColor:KtextColor forState:UIControlStateNormal];
    }
    self.previousSelectedIndex = index;
//    更新饼图
    if (index != self.showArray.count -1) {
        self.selectedTimeStr = self.timeArray[index];
    }
    else{
        self.selectedTimeStr = nil;
    }
    
    [self updateViewsValue];
}

- (void)updateViewsValue
{
    if (self.isOut == NO) {
        self.incomeLabel.textColor = KselectedColor;
        self.outLabel.textColor = KtextColor;
        
    }
    else{
        self.incomeLabel.textColor = KtextColor;
        self.outLabel.textColor = KselectedColor;
        
    }
    
    NSString *incomeMoney = [self.dataBaseManager totalMoney:NO date:self.selectedTimeStr];
    self.incomeLabel.text = [NSString stringWithFormat:@"收入 \n%.2f", incomeMoney.floatValue];
    
    NSString *outMoney = [self.dataBaseManager totalMoney:YES date:self.selectedTimeStr];
    self.outLabel.text = [NSString stringWithFormat:@"支出 \n%.2f", outMoney.floatValue];
    
    self.cakeView.transform = CGAffineTransformIdentity;
    NSMutableArray *colors = [self.dataBaseManager scaleOfBillMoneyFromTotalMoney:self.isOut date:self.selectedTimeStr];
    if (colors.count <= 0) {
        category *cat;
        if (self.isOut == YES) {
            cat = [self.dataBaseManager readCategoryBy:@(2)];
        }
        else{
            cat = [self.dataBaseManager readCategoryBy:@(41)];
        }
        
        NSString *scale = @"1.00";
        UIColor *color = KtextColor;
        NSDictionary *dic = @{@"name":cat.categoryName, @"scale":scale, @"color":color, @"type":cat};
        [colors addObject:dic];
    }
    self.cakeView.colorsArray = colors;
    [self.cakeView updataLayer:YES];
    self.index = self.cakeView.aboutRingArray.count - 1;
    NSDictionary *lastDic = self.cakeView.aboutRingArray.lastObject;
    NSNumber *last = lastDic[@"center"];
    self.firstEngle = - (M_PI - last.floatValue);
    self.cakeView.transform = CGAffineTransformRotate(self.cakeView.transform, self.firstEngle);
    NSDictionary *cakeDic = self.cakeView.aboutRingArray[self.index];
    
    [self setViewsValue:cakeDic[@"type"] scale:cakeDic[@"scale"] time:self.selectedTimeStr];
    
    self.isFirstAnimation = YES;
    self.isAnimationRunning = NO;

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
