//
//  DetailViewController.m
//  随手记
//
//  Created by 何易东 on 16/6/15.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import "DetailViewController.h"
#import "AddBillViewController.h"

#define kVIEWFRAM_WIDTH view.frame.size.width
#define kVIEWFRAM_HEIGHT view.frame.size.height

@interface DetailViewController()

@property (nonatomic, strong) sqlManger *dataBase;

@end

@implementation DetailViewController

-(void)viewDidLoad
{
    self.dataBase = [sqlManger dataBaseDefaultManager];
    NSLog(@"%@",self.toBill);
    [self displayView];
}

- (void)displayView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    view.backgroundColor = [UIColor whiteColor];

    //上面的线
    UIView *uponView = [[UIView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, 0, 2, view.frame.size.height/2-100)];
    uponView.backgroundColor = [UIColor colorWithWhite:0.800 alpha:1.000];
    [view addSubview:uponView];
    
    //下面的线
    UIView *underView = [[UIView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, view.frame.size.height/2, 2, view.frame.size.height/2+50)];
    underView.backgroundColor = [UIColor colorWithWhite:0.800 alpha:1.000];
    [view addSubview:underView];
    
    //账单消费图片
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2-25, uponView.frame.size.height+15, 50, view.frame.size.height-uponView.frame.size.height-underView.frame.size.height)];
    imageView.image = [UIImage imageNamed:self.toBill.category.iconName];
    [view addSubview:imageView];
    
    //账单消费金额
    UILabel *moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(view.frame.size.width/2 + 5, imageView.frame.origin.y+50, view.frame.size.width/2 - 5, 25)];
    moneyLabel.text = [NSString stringWithFormat:@"%.2f", self.toBill.money.floatValue];
    [view addSubview:moneyLabel];
    
    //账单消费名字
    UILabel *typeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, imageView.frame.origin.y+50, view.frame.size.width/2 -5, 25)];
    typeLabel.text = self.toBill.category.categoryName;
    typeLabel.textAlignment = NSTextAlignmentRight;
    [view addSubview:typeLabel];
    
    //账单消费备注
    if (self.toBill.note != nil) {
        
        UILabel *note = [[UILabel alloc]initWithFrame:CGRectMake(0, moneyLabel.frame.origin.y + 30, self.view.frame.size.width, 25)];
        CGPoint center = CGPointMake(self.view.frame.size.width / 2, moneyLabel.frame.origin.y + 40);
        note.center = center;
        note.backgroundColor = [UIColor whiteColor];
        note.text = self.toBill.note;
        note.textAlignment = NSTextAlignmentCenter;
        [view addSubview:note];
    }
    
    //账单消费时间
    UILabel *times = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - (self.view.frame.size.width /2 - 10)) / 2, uponView.frame.size.height-10, view.frame.size.width/2-10, 25)];
    times.textAlignment = NSTextAlignmentCenter;
    times.text = self.toBill.timeStr;
    times.backgroundColor = [UIColor whiteColor];
    [view addSubview:times];
    
    //修改按钮
    UIButton *modifyButton = [[UIButton alloc]initWithFrame:CGRectMake(kVIEWFRAM_WIDTH/4+kVIEWFRAM_WIDTH/3, kVIEWFRAM_HEIGHT-70, 50, 50)];
    [modifyButton setTitle:@"修改" forState:UIControlStateNormal];
    [modifyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [modifyButton addTarget:self action:@selector(modify:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:modifyButton];
    
    //删除按钮
    UIButton *deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(kVIEWFRAM_WIDTH/4+kVIEWFRAM_WIDTH/2,kVIEWFRAM_HEIGHT-70 , 50, 50)];
    [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:deleteButton];
    
    //右滑
    UISwipeGestureRecognizer *RightWipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipe:)];
    
    [self.view addGestureRecognizer:RightWipe];
    [self.view addSubview:view];
}

- (void)modify:(UIButton *)sender
{
    NSLog(@"修改");
    AddBillViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"RightWin"];
    [controller setValue:self.toBill forKey:@"thisBill"];
 
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)delete:(UIButton *)sender
{
    NSLog(@"删除");
    [self.dataBase deleteBill:self.toBill];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//右滑响应事件
- (void)swipe:(UISwipeGestureRecognizer *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
