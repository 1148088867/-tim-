//
//  Bill.m
//  layoutDemo
//
//  Created by 何易东 on 16/5/16.
//  Copyright © 2016年 dong. All rights reserved.
//

#import "Bill.h"
#import "sqlManger.h"
@implementation Bill

- (void)setTime:(NSDate *)time
{
    NSDateFormatter *formater = [[NSDateFormatter alloc]init];
    formater.dateFormat = @"yyyy-MM-dd";
    NSString *dateStr = [formater stringFromDate:time];
//    NSArray *strArray = [dateStr ]
    _time = [formater dateFromString:dateStr];
    
}

- (NSString *)timeStr
{
    if (_timeStr == nil) {
        NSDateFormatter *formater = [[NSDateFormatter alloc]init];
        formater.dateFormat = @"yyyy-MM-dd";
        _timeStr = [formater stringFromDate:self.time];
    }
    
    return _timeStr;
}

- (void)setCategoryID:(NSNumber *)categoryID
{
    self.category = [[sqlManger dataBaseDefaultManager]readCategoryBy:categoryID];
    _categoryID = categoryID;
}

@end

