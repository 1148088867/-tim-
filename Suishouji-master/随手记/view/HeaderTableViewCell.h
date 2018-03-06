//
//  HeaderTableViewCell.h
//  随手记
//
//  Created by 刘怀智 on 16/6/22.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalMoneyLabel;

@end
