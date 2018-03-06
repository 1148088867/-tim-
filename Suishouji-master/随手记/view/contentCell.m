//
//  contentCell.m
//  随手记
//
//  Created by 何易东 on 16/5/23.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import "contentCell.h"
#import "sqlManger.h"
#import "category.h"

@interface contentCell()


@property (weak, nonatomic) IBOutlet UILabel *consumptionType; ///<支出名称
@property (weak, nonatomic) IBOutlet UILabel *money;  ///<支出金额
@property (weak, nonatomic) IBOutlet UILabel *noteOut;
@property (weak, nonatomic) IBOutlet UIButton *typeImage; ///<收入或者支出图片
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (weak, nonatomic) IBOutlet UILabel *IncomeType;  ///<收入名字
@property (weak, nonatomic) IBOutlet UILabel *moneyIncome; ///<收入金额
@property (weak, nonatomic) IBOutlet UILabel *Noteincome;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton; ///<删除button
@property (weak, nonatomic) IBOutlet UIButton *modify; ///<修改



@end
@implementation contentCell

-(BOOL)menuIsOpened{
    return self.deleteButton.isHidden;
}

-(NSMutableArray *)imageArray{
    if (!_imageArray) {
        NSMutableArray *array = [[NSMutableArray alloc]init];
        for (int i=1; i<11; i++) {
            NSString *string = [[NSString alloc]initWithFormat:@"type_big_%d",i];
            UIImage *image = [UIImage imageNamed:string];
            [array addObject:image];
        }
        return array;
    }
    return nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.typeImage addTarget:self action:@selector(imageButton:) forControlEvents:UIControlEventTouchUpInside];
}

//给cell中的label 赋值
- (void)TraditionalValues:(Bill *)theBill{
    self.deleteButton.hidden = YES;
    self.modify.hidden = YES;
    category *theCategory = [[sqlManger dataBaseDefaultManager]readCategoryBy:theBill.categoryID];
    if(theCategory.isOut)
    {
        self.IncomeType.hidden = YES;
        self.moneyIncome.hidden = YES;
        self.Noteincome.hidden = YES;
        if (theBill.note.length <= 0) {
            self.noteOut.text = nil;
            CGFloat x = self.consumptionType.center.x;
            CGFloat y = self.typeImage.center.y;
            self.consumptionType.center = CGPointMake(x, y);
            NSLog(@"x %f, y %f ",self.consumptionType.center.x, self.consumptionType.center.y);
        }
        self.noteOut.text = theBill.note;
        self.money.text = [NSString stringWithFormat:@"%.2f",theBill.money.floatValue];
        self.consumptionType.text = theCategory.categoryName;
        [self.typeImage setImage:[UIImage imageNamed:theCategory.iconName] forState:UIControlStateNormal];
    }
    else
    {
        self.money.text = nil;
        self.consumptionType.text = nil;
        self.noteOut.hidden = YES;
        if (theBill.note.length <= 0) {
            self.Noteincome.text = nil;
            CGFloat x = self.IncomeType.center.x;
            CGFloat y = self.typeImage.center.y;
            self.IncomeType.center = CGPointMake(x, y);
            NSLog(@"x %f, y %f ",self.consumptionType.center.x, self.consumptionType.center.y);
        }
        self.Noteincome.text = theBill.note;
        self.IncomeType.text = theCategory.categoryName;
        self.moneyIncome.text = [NSString stringWithFormat:@"%.2f",theBill.money.floatValue];
        [self.typeImage setImage:[UIImage imageNamed:theCategory.iconName] forState:UIControlStateNormal];
    }
    
}

- (void)imageButton:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(willPressButton:)] && sender) {
        [self.delegate willPressButton:self];
    }
    
    if (self.deleteButton.isHidden) {
        self.deleteButton.frame = CGRectMake(self.frame.size.width/2-50, self.typeImage.frame.origin.y, self.deleteButton.frame.size.width, self.deleteButton.frame.size.height);
        self.modify.frame = CGRectMake(self.typeImage.frame.origin.x+30, self.typeImage.frame.origin.y, self.modify.frame.size.width, self.modify.frame.size.height);
        [UIView animateWithDuration:0.5f animations:^{
            self.deleteButton.frame = CGRectMake((self.frame.size.width-32)/2, self.frame.size.height/2, 32, 31);
            self.modify.frame = CGRectMake(self.frame.size.width-33, self.frame.size.height/2, 32, 31);
            self.deleteButton.hidden = NO;
            self.modify.hidden = NO;
        }];
    }else{
        [UIView animateWithDuration:0.5f animations:^{
            self.deleteButton.frame = CGRectMake(self.frame.size.width/2-50, self.typeImage.frame.origin.y, self.deleteButton.frame.size.width, self.deleteButton.frame.size.height);
            self.modify.frame = CGRectMake(self.typeImage.frame.origin.x+30, self.typeImage.frame.origin.y, self.modify.frame.size.width, self.modify.frame.size.height);

        } completion:^(BOOL finished) {
            self.deleteButton.hidden = YES;
            self.modify.hidden = YES;
        }];
    }

    
}
- (IBAction)deleteButton:(UIButton *)sender {
    NSLog(@"删除");
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteSelectedBill:)] && sender) {
        [self.delegate deleteSelectedBill:self];
    }
}
- (IBAction)modifyButton:(UIButton *)sender {
    NSLog(@"修改");
    if (self.delegate && [self.delegate respondsToSelector:@selector(modifySelectedBill:)] && sender) {
        [self.delegate modifySelectedBill:self];
    }}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)prepareForReuse {

}
@end
