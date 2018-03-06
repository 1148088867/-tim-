//
//  TypeBillListViewController.m
//  随手记
//
//  Created by 刘怀智 on 16/6/21.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import "TypeBillListViewController.h"
#import "DetailViewController.h"
#import "HeaderTableViewCell.h"
#import "contentCell.h"
#import "sqlManger.h"
#import "category.h"
#import "Bill.h"

@interface TypeBillListViewController ()<UITableViewDelegate, UITableViewDataSource, contentCellDelegate>
// views
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *typeImage;
@property (weak, nonatomic) IBOutlet UITableView *billTabelView;
//数据
//@property (nonatomic, strong) NSMutableArray *billArray;
@property (nonatomic, strong) category *thisCategory;
@property (nonatomic, copy)   NSString *timeStr;
@property (nonatomic, strong) sqlManger *database;
@property (nonatomic, strong) NSMutableDictionary *billDic;
@property (nonatomic, strong) NSMutableArray *timeArray; 

@end

@implementation TypeBillListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //数据库
    self.database = [sqlManger dataBaseDefaultManager];
    
    self.billTabelView.delegate = self;
    self.billTabelView.dataSource = self;
    self.billTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;//取消线条
    
    self.billDic = [self.database billDicOfType:self.thisCategory.categoryID Month:self.timeStr];
    self.timeArray = [self.database timesOfBillWithType:self.thisCategory.categoryID month:self.timeStr];
    
    [self setValueOfView];
    
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(dismissToPresentVC)];
    gesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:gesture];
    
    
}

- (void)dismissToPresentVC  {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews
{
    UIView *superView = self.typeImage.superview;
    CGPoint center = CGPointMake(superView.frame.size.width / 2, superView.frame.size.height);
    self.typeImage.center = center;
    
}

//- (NSMutableArray *)billArray
//{
//    if (!_billArray) {
//        _billArray = [self.database allBillOfType:self.thisCategory.categoryID];
//        
//    }
//    return  _billArray;
//}

- (IBAction)backBtnAction:(UIButton *)sender {
     [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)setValueOfView
{
    self.typeImage.image = self.thisCategory.iconImage;
    self.countLabel.text = [NSString stringWithFormat:@"%ld",[self.database billCountOfCategory:self.thisCategory.categoryID time:self.timeStr]];
    self.moneyLabel.text = [NSString stringWithFormat:@"%.2f", [self.database totalMoneyOfType:self.thisCategory.categoryID time:self.timeStr]];
    
}
#pragma mark - tableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.timeArray.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *cellIndentifer = @"HeaderTableViewCell";
    NSArray *nib = [[NSBundle mainBundle]loadNibNamed:cellIndentifer owner:nil options:nil];
    HeaderTableViewCell *cell = [nib objectAtIndex:0];
    cell.dateLabel.text = self.timeArray[section];
    NSString *key = self.timeArray[section];
    cell.totalMoneyLabel.text = [NSString stringWithFormat:@"%.2f",[self.database totalMoneyOfBillList:self.billDic[key]]];
    return (UIView *)cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *billArray = self.billDic[self.timeArray[section]];
    return billArray.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifer = @"contentCell";
    
    contentCell *cell = (contentCell *)[tableView dequeueReusableCellWithIdentifier:cellIndentifer];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:cellIndentifer owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        //        cell=[[[NSBundle mainBundle]loadNibNamed:cellIndentifer owner:nil options:nil]firstObject];
        
    }
    NSString *time = self.timeArray [indexPath.section];
    NSMutableArray *array = self.billDic[time];
    Bill *currentBill = array[indexPath.row];
     [cell TraditionalValues:currentBill];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate=self;
    tableView.rowHeight = 55;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DetailViewController *controller = [[DetailViewController alloc]init];
    NSString *time = self.timeArray [indexPath.section];
    NSMutableArray *array = self.billDic[time];
    Bill *theBill = array[indexPath.row];
    [controller setValue:theBill forKey:@"toBill"];
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
    
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
