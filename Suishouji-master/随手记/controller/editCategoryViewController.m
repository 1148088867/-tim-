//
//  editCategoryViewController.m
//  随手记
//
//  Created by 何易东 on 16/6/17.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import "editCategoryViewController.h"
#import "JZMTBtnView.h"
#import "Bill.h"
#import "category.h"
#import "MoneyView.h"
#import "sqlManger.h"

#define  Kindex(tag) (tag / 100) - 1 ///<tag获取类别数组下标
#define  Ktag(index) (index + 1) * 100 ///<类别View标记
#define Kscale [UIScreen mainScreen].bounds.size.width / 320
#define ktypeBtnWidth 40 * Kscale //view的宽
#define ktypeBtnHeight 55 * Kscale
#define angelToRandian(x)  ((x)/180.0*M_PI) //旋转角度

@interface editCategoryViewController()<UIScrollViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField; //文本框
@property (weak, nonatomic) IBOutlet UIImageView *icomImage; //文本框图标
@property (nonatomic, strong) UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *barView;  //保存或者返回view
@property (weak, nonatomic) IBOutlet UIView *modifView; //修改类别view
@property (nonatomic, assign) NSInteger viewsCount;
@property (nonatomic, strong) MoneyView *moneyView; //类别view
@property (nonatomic, strong) NSArray *categoryArray; //类别
@property (nonatomic, strong) sqlManger *dataBase;
@property (nonatomic, strong) category *categ;
@property (nonatomic, assign) BOOL isOut; //判断进来是支出还是收入

@end

@implementation editCategoryViewController{
    int g;
}

-(void)viewDidLoad{
    self.modifView.layer.borderWidth=1; //设置类别的宽
    self.modifView.layer.borderColor = [UIColor grayColor].CGColor;
    
    self.categoryArray = [self categorysFromPlist];//读取类别
    
    self.textField.delegate = self;
    self.dataBase = [sqlManger dataBaseDefaultManager];
    
    [self creatCategoryViews];
    [self.view addSubview:self.scrollView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];// 1
    [self.textField becomeFirstResponder];// 2 //弹出
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillAppear:animated];// 1
    [self.textField resignFirstResponder];// 2  //取消
}

- (NSArray *) categorysFromPlist
{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"CategoryList" ofType:@"plist"];
    NSDictionary *categoryDic = [[NSDictionary alloc]initWithContentsOfFile:path];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    NSArray *ID = [categoryDic allKeys];
    for (int i = 0; i < ID.count; i ++) {
        category *cate = [[category alloc]init];
        NSString *categoryID = ID[i];
        cate.categoryID = @(categoryID.intValue);
        NSDictionary  *dic = categoryDic[categoryID];
        NSString *boolstr = dic[@"isOut"];
        cate.isOut = boolstr.boolValue;
        //        NSLog(@"%@",dic[@"isOut"]);
        cate.categoryColorStr = dic[@"color"];
        cate.iconName = dic[@"imageName"];
        [array addObject:cate];
    }
    return array;
}

#pragma mark scrollView

- (UIScrollView *)scrollView{
    //初始化 scrollView
    {
        if (_scrollView == nil)
        {
            //            UIScreen mainScreen].bounds.size.height-300
            _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.modifView.frame.origin.y+self.modifView.frame.size.height, self.view.frame.size.width, ktypeBtnHeight*4)];
            [self.view addSubview:_scrollView];
            _scrollView.bounces = NO;
            _scrollView.pagingEnabled = NO; //是否分页
            _scrollView.showsHorizontalScrollIndicator=NO; //不显示水平滚动
            _scrollView.showsVerticalScrollIndicator=NO;//不显示垂直滚动
            _scrollView.delegate = self; //设置代理
            
        }
        return _scrollView;
    }
}

- (void)creatCategoryViews
{
    self.viewsCount = self.categoryArray.count / 32;
    if ((self.categoryArray.count - 24 * self.viewsCount) > 0) {
        self.viewsCount += 1;
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, ktypeBtnHeight*8);
    
    for (int j = 0; j < 2; j ++) {
        UIView *cateView = [[UIView alloc]initWithFrame:CGRectMake(0, j * self.scrollView.frame.size.height, self.scrollView.frame.size.width, ktypeBtnHeight*4)];
        NSInteger categoryCount = 32;
        if (j == self.viewsCount -1) {
            categoryCount = self.categoryArray.count % 32;
        }
        for (int i = 0; i < categoryCount; i++) {
            NSInteger index = i + j * 32;
            category *cat = self.categoryArray[index];
            int t;
            int s;
            if (i == 0) {
                g=0;
            }else if(0 == i % 8){
                g++;
            }
            t = i - 8 * g;
            s = i / 8;
            
            CGRect frame = CGRectMake(t * ktypeBtnWidth, s * ktypeBtnHeight, ktypeBtnWidth , ktypeBtnHeight);
            JZMTBtnView *categoryView = [[JZMTBtnView alloc]initWithFrame:frame title:nil imageStr:cat.iconName];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(categoryViewTap:)];
            
            if (i > 31) {
                NSLog(@"%ld",index);
            }
            
            [categoryView addGestureRecognizer:tapGesture];
            
            categoryView.tag = Ktag(index);
            
            [cateView addSubview:categoryView];
        }
        [self.scrollView addSubview:cateView];
    }
    
}

#pragma mark 点击响应
//点击类别的响应函数
- (void)categoryViewTap:(UITapGestureRecognizer *)sender
{
    NSInteger index = Kindex(sender.view.tag);
    if (sender == nil) {
        index = 0;
    }
    NSLog(@"%ld",sender.view.tag);
    
    if (index != [self categorysFromPlist].count -1) {
        [self MoneyViewWithType:self.categoryArray[index]];
    }
    self.categ = [[category alloc]init];
    self.categ = self.categoryArray[index];
    self.categ.isOut = self.isOut;
    NSMutableArray *idArray = [self.dataBase categoryIdCount];
    self.categ.categoryID = idArray[idArray.count-1];
    self.categ.categoryID = @(self.categ.categoryID.integerValue + 1);
    self.icomImage.image = [UIImage imageNamed:self.categ.iconName];
}

- (void)MoneyViewWithType:(category *)type
{
    self.moneyView.color = type.categoryColor;
    self.moneyView.typeImage = type.iconImage;
}

- (IBAction)backButton:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark UIAlertController
- (IBAction)saveButton:(UIButton *)sender
{
    if (self.textField.text.length == 0) {
        UIAlertController *contercoller = [UIAlertController alertControllerWithTitle:@"输入名字为空" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"请重新输入！！" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [contercoller addAction:action];
        [self presentViewController:contercoller animated:YES completion:nil];
    }
    else if (self.textField.text.length > 4)
    {
        UIAlertController *contercoller = [UIAlertController alertControllerWithTitle:@"不超过四个字" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"请重新输入！！" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [contercoller addAction:action];
        [self presentViewController:contercoller animated:YES completion:nil];
    }
    else
    {
        NSLog(@"%@",self.textField.text);
        self.categ.categoryName = self.textField.text;
        [self.dataBase addTheCategory:self.categ];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

@end
