//
//  sqlManger.h
//  layoutDemo
//
//  Created by 何易东 on 16/5/16.
//  Copyright © 2016年 dong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bill.h"
#import "category.h"
#import "FMDB.h"

typedef NS_ENUM(NSInteger,timeStyle)
{
    day = 1,
    month = 2,
    year = 3
};

@interface sqlManger : NSObject

@property (nonatomic, strong) FMDatabase *dabase;
@property (nonatomic, strong) Bill *bil;
@property (nonatomic, strong) category *categ;

+ (instancetype)dataBaseDefaultManager;



- (BOOL)addWithTheBill:(Bill *)theBill; ///<增加账单数据
- (void)modifyTheBill:(Bill *)theBill; ///<修改账单数据
//- (NSMutableDictionary *)BillDictionaryOfTime:(NSDate *)date timeStyle:(timeStyle) timeStyle ; ///<根据时间返回账单字典,timeStyle: day = 1,month = 2,year = 3
- (NSMutableArray *)allBill; ///<所有的账单
- (BOOL)deleteBill:(Bill *) theBill; ///<删除账单
- (NSMutableArray *)selectTimesOfBill; //查找当前账单所有月份
- (NSMutableArray *)selectBillOfMonth:(NSString *)year; ///<所有月
- (NSMutableArray *)readBillMonthNume:(NSString *)month; ///<根据月找到天数账单
- (NSMutableArray *)readBillMonth:(NSString *)month;///<搜索每月下的账单
//求账单数 参数：类别ID、时间、时间类别（年、月）
- (NSInteger)billCountOfCategory:(NSNumber *)typeID time:(NSString *)timeStr;
- (NSMutableArray *)allBillOfType:(NSNumber *)typeID; ///<某个类别的所有账单
- (NSMutableDictionary *)billDicWithDate; ///<按时间返回字典
- (int) categoryCount;
- (NSMutableArray *)categoryIdCount;

- (NSMutableArray *)timesOfBillWithType:(NSNumber *)typeID month:(NSString *)month;
- (NSMutableDictionary *)billDicOfType:(NSNumber *)typeID Month:(NSString *)month;

#pragma mark - 类别

- (BOOL)addTheCategory:(category *)theCategory; ///<增加类别数据
- (NSMutableArray *)readTheCatgory :(BOOL) isOut; ///<读取类别数据
- (category *)readCategoryBy:(NSNumber *) categoryID;///< 读取单个类别数据
- (BOOL)modifyTheCatgory:(category *)theCategory; ///<修改类别数据
- (BOOL)deleteCatgory:(category *)theCategroy; ///<删除类别

#pragma mark - 图片

- (BOOL )addImage:(UIImage *)theImage; ///<插入图片
- (NSArray *)readImage;
- (BOOL)isHaveImage; ///<是否有图片

#pragma mark - 计算
- (NSMutableArray *)scaleOfBillMoneyFromTotalMoney:(BOOL)isOut date:(NSString *)time;///<计算每笔账单的金额占总金额的比例
//计算收入支出的总金额
- (NSString *) totalMoney:(BOOL) isOut date:(NSString *)time;
//计算每个类别的总金额
- (float)totalMoneyOfType:(NSNumber *)typeID time:(NSString *)timeStr;

- (NSMutableArray *)allMoney:(NSString *)string;
- (float)allExpend:(NSMutableArray *)array; ///<所有支出金额
- (float)allRevenueAmount:(NSMutableArray *)arry; ///<所有收入金额

- (NSMutableArray *)monthOfAllBill; ///<查找已有的所有的月份
- (float)totalMoneyOfBillList:(NSMutableArray *)billArry;



#pragma  mark - 预算
- (BOOL )addBudget:(NSNumber *)budget; ///<添加预算
- (NSArray *)readBudget;
- (BOOL)modifyTheBudget:(NSNumber *)theBudget;


@end
