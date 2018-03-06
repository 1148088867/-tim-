//
//  DetailViewController.h
//  随手记
//
//  Created by 何易东 on 16/6/15.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "category.h"
#import "Bill.h"
#import "sqlManger.h"

@interface DetailViewController : UIViewController

@property (nonatomic, strong) Bill *toBill;

@end
