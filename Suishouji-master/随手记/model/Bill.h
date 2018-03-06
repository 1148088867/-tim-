//
//  Bill.h
//  layoutDemo
//
//  Created by 何易东 on 16/5/16.
//  Copyright © 2016年 dong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "category.h"
@interface Bill : NSObject

@property (nonatomic, strong) NSNumber *BillID; ///<账单ID
@property (nonatomic, strong) NSNumber *categoryID; ///<分类ID
@property (nonatomic, strong) NSNumber *money; ///<金额
@property (nonatomic, strong) NSDate *time; ///<时间
@property (nonatomic, copy) NSString *timeStr; ///<时间字符串
@property (nonatomic, copy) NSString *note;///<备注
@property (nonatomic, strong) category *category;///<类别


@end
