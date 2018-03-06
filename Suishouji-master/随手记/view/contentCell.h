//
//  contentCell.h
//  随手记
//
//  Created by 何易东 on 16/5/23.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bill.h"

@class contentCell;
@protocol contentCellDelegate <NSObject>

- (void)willPressButton:(contentCell *)cell;
- (void)deleteSelectedBill:(contentCell *)cell;
- (void)modifySelectedBill:(contentCell *)cell;
@end

@interface contentCell : UITableViewCell
@property (nonatomic, weak)id<contentCellDelegate>delegate;
@property (nonatomic, readonly) BOOL menuIsOpened;
@property (weak, nonatomic) IBOutlet UILabel *data; ///<时间
@property (weak, nonatomic) IBOutlet UIImageView *modifiedPhotos;  ///<隐藏的图片
@property (weak, nonatomic) IBOutlet UILabel *totalConsumption; ///<总消费

- (void)TraditionalValues:(Bill *)theBill;
- (void)imageButton:(UIButton *)sender;

@end
