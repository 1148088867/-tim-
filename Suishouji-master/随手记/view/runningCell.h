//
//  runningCell.h
//  随手记
//
//  Created by 何易东 on 16/6/8.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bill.h"

@interface runningCell : UITableViewCell

@property (nonatomic, strong) UILabel *typeName;
@property (nonatomic, strong) UIImageView *typeImage;
@property (nonatomic, strong) UILabel *typeMoney;
@property (nonatomic, strong) UILabel *typeTime;
@property (nonatomic, copy) NSString *strName;

- (void)config:(Bill *)model;

@end
