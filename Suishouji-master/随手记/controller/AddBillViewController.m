//
//  AddBillViewController.m
//  随手记
//
//  Created by 刘怀智 on 16/5/24.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import "AddBillViewController.h"
#import "editCategoryViewController.h"
#import "JZMTBtnView.h"
#import "Bill.h"
#import "category.h"
#import "sqlManger.h"
#import "MoneyView.h"
#import "CalculatorView.h"
#import "NavView.h"

#define angelToRandian(x)  ((x)/180.0*M_PI)
#define Kscale [UIScreen mainScreen].bounds.size.width / 320
#define ktypeBtnWidth 40 * Kscale
#define ktypeBtnHeight 65 * Kscale
#define KscrollHeight 195 * Kscale
#define KscrollY 100 * Kscale + 20
#define  Ktag(index) (index + 1) * 100 ///<类别View标记
#define  Kindex(tag) (tag / 100) - 1 ///<tag获取类别数组下标

@interface AddBillViewController ()
<UIScrollViewDelegate, UIAlertViewDelegate, CalculatorViewDelegate, NavViewDelegate,MoneyViewDelegate>


@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITextField *noteText;
@property (nonatomic, strong) NSMutableArray *categoryArray;
@property (nonatomic, strong) MoneyView *moneyView;
@property (nonatomic, strong) CalculatorView *calculatorView;
@property (nonatomic, strong) NavView *nav;
@property (nonatomic, strong) Bill *thisBill;
@property (nonatomic, strong) sqlManger *dataBaseManager;
@property (nonatomic, strong) UIAlertView *noteAlert; ///<备注
@property (nonatomic, strong) UIAlertAction *secureTextAlertAction;
@property (nonatomic, assign) NSInteger viewsCount;
@property (nonatomic, assign) BOOL isModify; ///<是：修改 否 ：添加
@property (nonatomic, strong) NSMutableArray *typeViewsArray;
@property (nonatomic, strong) NSMutableArray *buttonArray;

@end

@implementation AddBillViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.thisBill == nil) {
        self.thisBill = [[Bill alloc]init];
        self.thisBill.time = [NSDate date];
        self.thisBill.money = @(0.00);
        self.isModify = NO;
    }
    else{
        self.isModify = YES;
    }
    self.dataBaseManager = [sqlManger dataBaseDefaultManager];
    //计算器
    self.calculatorView = [self.view viewWithTag:111];
    self.calculatorView.delegate = self;
    [self.view addSubview:self.calculatorView];
    //顶部的按钮
    self.nav = [[NavView alloc]init];
    self.nav.delegate = self;
    [self.view addSubview:self.nav];
    //显示类别／金额
    self.moneyView = [[MoneyView alloc]init];
    [self.view addSubview:self.moneyView];
    //添加备注
    [self inputNoteText];
    //类别
    [self creatCategoryViews];
    //添加备注
    [self inputNoteText];
    
    //修改账单
    if (self.isModify == YES) {
        [self showBillValues];
    }
    self.moneyView.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self showBillValues];
    [self categoryArray];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//账单对象
//- (Bill *)thisBill
//{
//    if (_thisBill == nil) {
//        _thisBill = [[Bill alloc]init];
//        _thisBill.time = [NSDate date];
//        _thisBill.money = @(0.00);
//        self.isModify = NO;
//    }
//    else{
//        self.isModify = YES;
//    }
//
//    return _thisBill;
//}

//类别数组
- (NSMutableArray *)categoryArray
{
    if (!_categoryArray) {
        _categoryArray = [self.dataBaseManager readTheCatgory:YES];
    }
    
    category *end = _categoryArray.lastObject;
    if (![end.categoryName isEqualToString:@"编辑"])
    {
        category *add = [[category alloc]init];
        add.iconName = @"type_add";
        add.categoryName = @"编辑";
        [_categoryArray addObject:add];
    }
    
    //让一般类别保证一直在第一个
    for (int i = 0; i < _categoryArray.count; i++ )
    {
        category *cat = _categoryArray[i];
        if ([cat.categoryName isEqualToString:@"一般"])
        {
            category *elem = _categoryArray[0];
            if (self.isModify == NO)
            {
                self.thisBill.categoryID = elem.categoryID; //为添加时默认类别为“一般”
            }
            _categoryArray[0] = cat;
            _categoryArray[i] = elem;
        }
    }
    
    return _categoryArray;
}
#pragma mark - 类别部分

//初始化 scrollView
- (UIScrollView *)scrollView
{
    if (_scrollView == nil)
    {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, KscrollY, self.view.frame.size.width, KscrollHeight)];
        [self.view addSubview:_scrollView];
        _scrollView.bounces = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator=NO;
        _scrollView.showsVerticalScrollIndicator=NO;
        _scrollView.delegate = self;
        
    }
    return _scrollView;
}

//点击类别的响应函数
- (void)categoryViewTap:(UITapGestureRecognizer *)sender
{
    NSInteger index = Kindex(sender.view.tag);
    if (sender == nil)
    {
        index = 0;
    }
    NSLog(@"%ld",sender.view.tag);
    
    if (index != self.categoryArray.count -1)
    {
        [self MoneyViewWithType:self.categoryArray[index]];
    }
    
    if (sender.view.tag == self.categoryArray.count * 100)
    {
        editCategoryViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"stobd"];
        [controller setValue:@(self.thisBill.category.isOut) forKey:@"isOut"];
        [self presentViewController:controller animated:YES completion:nil];
    }
    
    category *cate = self.categoryArray[index];
    self.thisBill.categoryID = cate.categoryID;
}
//添加类别在scrollView中
- (void)creatCategoryViews
{
    self.typeViewsArray = [NSMutableArray array];
    self.buttonArray = [NSMutableArray array];
    self.viewsCount = self.categoryArray.count / 24;
    if ((self.categoryArray.count - 24 * self.viewsCount) > 0)
    {
        self.viewsCount += 1;
    }
    self.scrollView.contentSize = CGSizeMake(self.viewsCount * self.scrollView.bounds.size.width, 0);
    
    for (int j = 0; j < self.viewsCount; j ++)
    {
        UIView *cateView = [[UIView alloc]initWithFrame:CGRectMake(j * self.view.frame.size.width, 0, self.view.frame.size.width, KscrollHeight)];
        NSInteger categoryCount = 24;
        if (j == self.viewsCount -1)
        {
            categoryCount = self.categoryArray.count % 24;
            
        }
        for (int i = 0; i < categoryCount; i++)
        {
            NSInteger index = i + j * 24;
            //            NSLog(@"page: %d count: %ld index: %ld", j, (long)categoryCount,(long)index);
            if (i < 8)
            {
                category *cat = self.categoryArray[index];
                CGRect frame = CGRectMake(i * ktypeBtnWidth, 0, ktypeBtnWidth, ktypeBtnHeight);
                JZMTBtnView *categoryView = [[JZMTBtnView alloc]initWithFrame:frame title:cat.categoryName imageStr:cat.iconName];
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(categoryViewTap:)];
                [categoryView addGestureRecognizer:tapGesture];
                categoryView.tag = Ktag(index);
                
                UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
                
                longPressRecognizer.allowableMovement = 30;
                
                [categoryView addGestureRecognizer:longPressRecognizer];
                
                //删除按钮
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(categoryView.frame.size.width - 24, 0, 24, 24);
                [button setBackgroundImage:[UIImage imageNamed:@"dele"] forState:UIControlStateNormal];
                button.tag = i;
                [button addTarget:self action:@selector(buttonChange:) forControlEvents:UIControlEventTouchUpInside];
                [categoryView addSubview:button];
                button.hidden = YES;
                
                [cateView addSubview:categoryView];
                
                //添加到viewArray中
                if (index != self.categoryArray.count - 1 && index != 0)
                {
                    [self.typeViewsArray addObject:categoryView];
                    [self.buttonArray addObject:button];
                }
                
            }
            else if ((i / 8) >= 1 && (i / 8) < 2)
            {
                category *cat = self.categoryArray[index];
                CGRect frame = CGRectMake((i - 8) * ktypeBtnWidth, i / 8 * ktypeBtnHeight, ktypeBtnWidth , ktypeBtnHeight);
                JZMTBtnView *categoryView = [[JZMTBtnView alloc]initWithFrame:frame title:cat.categoryName imageStr:cat.iconName];
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(categoryViewTap:)];
                [categoryView addGestureRecognizer:tapGesture];
                categoryView.tag = Ktag(index);
                
                UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
                
                longPressRecognizer.allowableMovement = 30;
                
                [categoryView addGestureRecognizer:longPressRecognizer];
                
                //删除按钮
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(categoryView.frame.size.width - 24, 0, 24, 24);
                [button setBackgroundImage:[UIImage imageNamed:@"dele"] forState:UIControlStateNormal];
                button.tag = i;
                [button addTarget:self action:@selector(buttonChange:) forControlEvents:UIControlEventTouchUpInside];
                [categoryView addSubview:button];
                button.hidden = YES;
                [cateView addSubview:categoryView];
                
                //添加到viewArray中
                if (index != self.categoryArray.count - 1) {
                    [self.typeViewsArray addObject:categoryView];
                    [self.buttonArray addObject:button];
                }
                
            }
            else
            {
                category *cat = self.categoryArray[index];
                CGRect frame = CGRectMake((i - 16)  * ktypeBtnWidth, i / 8 * ktypeBtnHeight, ktypeBtnWidth, ktypeBtnHeight);
                JZMTBtnView *categoryView = [[JZMTBtnView alloc]initWithFrame:frame title:cat.categoryName imageStr:cat.iconName];
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(categoryViewTap:)];
                [categoryView addGestureRecognizer:tapGesture];
                categoryView.tag = Ktag(index);
                
                UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
                
                longPressRecognizer.allowableMovement = 30;
                
                [categoryView addGestureRecognizer:longPressRecognizer];
                
                //删除按钮
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(categoryView.frame.size.width - 24, 0, 24, 24);
                [button setBackgroundImage:[UIImage imageNamed:@"dele"] forState:UIControlStateNormal];
                button.tag = i;
                [button addTarget:self action:@selector(buttonChange:) forControlEvents:UIControlEventTouchUpInside];
                [categoryView addSubview:button];
                button.hidden = YES;
                [cateView addSubview:categoryView];
                
                //添加到viewArray中
                if (index != self.categoryArray.count - 1)
                {
                    [self.typeViewsArray addObject:categoryView];
                    [self.buttonArray addObject:button];
                }
                
            }
            
        }
        [self.scrollView addSubview:cateView];
    }
    
    if (self.isModify == NO)
    {
        [self categoryViewTap:nil];
    }
    
}

- (void)longPress:(UILongPressGestureRecognizer*)longPress
{
    if (longPress.state==UIGestureRecognizerStateBegan)
    {
        for (JZMTBtnView *typeView in self.typeViewsArray)
        {
            CAKeyframeAnimation* anim=[CAKeyframeAnimation animation];
            anim.keyPath=@"transform.rotation";
            anim.values=@[@(angelToRandian(-7)),@(angelToRandian(7)),@(angelToRandian(-7))];
            anim.repeatCount=MAXFLOAT;
            anim.duration=0.2;
            //            longPress.view.tag = i;
            
            [typeView.layer addAnimation:anim forKey:nil];
        }
        
        for (UIButton *button in self.buttonArray)
        {
            button.hidden = NO;
        }
        
        //   self.btn.hidden=NO;
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (JZMTBtnView *typeView in self.typeViewsArray)
    {
        [typeView.layer removeAllAnimations];
    }
    
    for (UIButton *button in self.buttonArray)
    {
        button.hidden = YES;
    }
}

- (void)buttonChange:(UIButton*)sender
{
    NSInteger s = sender.superview.tag;
    s = s /100 - 1;
    category *cat = self.categoryArray[s];
    [self.dataBaseManager deleteCatgory:self.categoryArray[s]];
    for (NSInteger index = s-1; index < self.typeViewsArray.count; index++)
    {
        JZMTBtnView *view = self.typeViewsArray[index];
        if (s == index+1)
        {
            //删除这个view
            [view removeFromSuperview];
            [self.scrollView removeFromSuperview];
            self.scrollView = nil;
            NSMutableArray *array = [self.dataBaseManager readTheCatgory:cat.isOut];
            category *add = [[category alloc]init];
            add.iconName = @"type_add";
            add.categoryName = @"编辑";
            [array addObject:add];
            self.categoryArray = array;
            [self creatCategoryViews];
        }
    }
    
}

//输入金额view

#pragma mark - CalculatorView
- (void)MoneyViewWithType:(category *)type
{
    self.moneyView.typeName = type.categoryName;
    self.moneyView.color = type.categoryColor;
    self.moneyView.typeImage = type.iconImage;
    self.moneyView.theCateg = type;
}

- (void)outStrOfCalculatorViewWithWord:(NSString *)str
{
    self.moneyView.money = str;
    self.thisBill.money = @(str.floatValue);
}

- (void)CalculatorWithWord:(NSString *)str
{
    NSDateFormatter *formater = [[NSDateFormatter alloc]init];
    formater.dateFormat = @"yyyy-MM-dd";
    self.thisBill.time = [formater dateFromString:str];
    self.thisBill.timeStr = [formater stringFromDate:self.thisBill.time];
}

- (void)tapAddNote
{
    [self.noteAlert show];
    //    UITextField *noteFielf = [self.noteAlert textFieldAtIndex:0];
    //    noteFielf.text = self.thisBill.note;
}

- (void)inputNoteText
{
    self.noteAlert = [[UIAlertView alloc] initWithTitle:@"添加备注" message:@" " delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"添加",nil];
    self.noteAlert.delegate = self;
    self.noteAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [self.noteAlert addSubview:self.noteText];
    //显示已有的备注
    if (self.isModify == YES) {
        UITextField *note = [self.noteAlert textFieldAtIndex:0];
        note.text = self.thisBill.note;
    }
    
}
- (void)alertViewCancel:(UIAlertView *)alertView
{
    self.thisBill.note = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    UITextField *note = [alertView textFieldAtIndex:0];
    self.thisBill.note = note.text;
}
#pragma mark - NavView

- (void)selectedBtnName:(BtnName)btnName
{
    [self.nav selectedBtnBetweenOutInput:btnName];
    switch (btnName) {
        case 1:
        {
            [self.scrollView removeFromSuperview];
            self.scrollView = nil;
            NSMutableArray *array = [self.dataBaseManager readTheCatgory:YES];
            category *add = [[category alloc]init];
            add.iconName = @"type_add";
            add.categoryName = @"编辑";
            [array addObject:add];
            self.categoryArray = array;
            [self creatCategoryViews];
        }
            break;
        case 2:
        {
            [self.scrollView removeFromSuperview];
            self.scrollView = nil;
            NSMutableArray *array = [self.dataBaseManager readTheCatgory:NO];
            category *add = [[category alloc]init];
            add.iconName = @"type_add";
            add.categoryName = @"编辑";
            [array addObject:add];
            self.categoryArray = array;
            [self creatCategoryViews];
        }
            break;
        case 3: //保存
        {
            if (self.isModify == YES) {
                [self.dataBaseManager modifyTheBill:self.thisBill];
            }
            else
            {
                [self.dataBaseManager addWithTheBill:self.thisBill];
            }
            //            NSLog(@"keep");
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            
            //注释掉，穿透效果
//            break;
            
        default: //返回
            
        {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            UITabBarController *tabbarV = window.rootViewController;
            if (tabbarV) {
                tabbarV.selectedIndex = 0;
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            
            break;
    }
}
#pragma mark - 修改账单
- (void)showBillValues
{
    
    //类别
    [self MoneyViewWithType:self.thisBill.category];
    //金额
    NSString *money = [NSString stringWithFormat:@"%.2f",self.thisBill.money.floatValue];
    [self outStrOfCalculatorViewWithWord:money];
    //收入支出
    if (self.thisBill.category.isOut == YES) {
        [self selectedBtnName:outBtn];
    }
    else
    {
        [self selectedBtnName:inputBtn];
    }
    [self.calculatorView setCalendarBtnTitle:self.thisBill.timeStr];
    
}

#pragma mark MoneyViewDelegate
- (void)clickOnPicture:(MoneyView *)money{
    NSLog(@"。。。");
    if ([money.typeName isEqualToString:@"一般"]) {
        UIAlertController *contercoller = [UIAlertController alertControllerWithTitle:@"“一般” 不能修改" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [contercoller addAction:action];
        [self presentViewController:contercoller animated:YES completion:nil];
    }else{
        UIAlertController *contercoller = [UIAlertController alertControllerWithTitle:@"请修改类别名字" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:contercoller.textFields.firstObject];
            UITextField *textField = contercoller.textFields.firstObject;
            money.theCateg.categoryName = textField.text;
            [self.dataBaseManager modifyTheCatgory:money.theCateg];
            NSLog(@"textField=%@",textField.text);
            //            [self categoryArray];
            [self showBillValues];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:contercoller.textFields.firstObject];
        }];
        
        //另外，很多时候，我们需要在alertcontroller中添加一个输入框，例如输入密码：
        [contercoller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
            //        textField.secureTextEntry = YES;
            //        textField.keyboardType = UIKeyboardTypeASCIICapable;
        }];
        action.enabled = NO;
        self.secureTextAlertAction = action;//定义一个全局变量来存储
        
        [contercoller addAction:action];
        [contercoller addAction:action2];
        
        
        
        [self presentViewController:contercoller animated:YES completion:nil];
    }
}

- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = notification.object;
    
    self.secureTextAlertAction.enabled = textField.text.length > 0 && textField.text.length < 4;
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
