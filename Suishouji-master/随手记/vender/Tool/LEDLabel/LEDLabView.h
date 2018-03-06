//
//  LEDLabView.h
//  BingoLottery
//
//  Created by chen on 2017/3/20.
//  Copyright © 2017年 bingo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LEDLabView : UIView

@property(nonatomic,assign)BOOL isStop;

-(instancetype)initWithFrame:(CGRect)frame withTitleArray:(NSArray<NSString *> *)titleArr;

@end
