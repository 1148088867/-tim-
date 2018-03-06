//
//  LEDLabView.m
//  BingoLottery
//
//  Created by chen on 2017/3/20.
//  Copyright © 2017年 bingo. All rights reserved.
//

#import "LEDLabView.h"

@interface LEDLabView()
{
    
    CGRect currentFrame;
    
    CGRect behindFrame;
    
    NSMutableArray *labelArray;
    
    CGFloat labelHeight;
    
    
    NSInteger time;
    
    UIView *showContentView;
}

@end


@implementation LEDLabView

-(instancetype)initWithFrame:(CGRect)frame withTitleArray:(NSArray<NSString *> *)titleArr
{
    
    NSMutableString *mString = [NSMutableString string];
    for (NSString *str in titleArr) {
        [mString appendFormat:@"     %@",str];
    }
    
    self = [super initWithFrame:frame];
    self.backgroundColor = RGB(138, 166, 201);
    if (self) {
        _isStop = NO;
        showContentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        showContentView.clipsToBounds = YES;
        showContentView.backgroundColor = RGB(138, 166, 201);
        [self addSubview: showContentView];
        
        CGFloat viewHeight = frame.size.height;
        labelHeight = viewHeight;
        
        time = mString.length/4 < 10? 10:(mString.length / 4);
        
        UILabel *myLable = [[UILabel alloc]init];
        myLable.text = mString;
        myLable.font = [UIFont systemFontOfSize:13.0f];
        myLable.backgroundColor = RGB(138, 166, 201);
        myLable.textColor = RGB(248, 248, 255);
        //        myLable.se
        
        CGFloat calcuWidth = [self widthForTextString:mString height:labelHeight fontSize:13.0f];
        if (calcuWidth < SCREEN_WIDTH) {
            calcuWidth = SCREEN_WIDTH;
        }
        
        currentFrame = CGRectMake(0, 0, calcuWidth, labelHeight);
        //  -1 是为了隐藏UIlabel的边框线
        behindFrame = CGRectMake(currentFrame.origin.x+currentFrame.size.width-1, 0, calcuWidth, labelHeight);
        
        myLable.frame = currentFrame;
        
        [showContentView addSubview:myLable];
        
        labelArray  = [NSMutableArray arrayWithObject:myLable];
        [labelArray addObject:myLable];
        
        if (calcuWidth>frame.size.width) {
            UILabel *behindLabel = [[UILabel alloc]init];
            behindLabel.frame = behindFrame;
            behindLabel.text = mString;
            behindLabel.font = [UIFont systemFontOfSize:13.0f];
            behindLabel.textColor = UIColorFromRGB(0x666666);
            behindLabel.backgroundColor = [UIColor whiteColor];
            [labelArray addObject:behindLabel];
            [showContentView addSubview:behindLabel];
            [self doAnimation];
        }
    }
    
    
    return  self;
}

-(void)setIsStop:(BOOL)isStop {
    _isStop = isStop;
    [self doAnimation];
}

- (void)doAnimation
{
    
    UIApplicationState state = [UIApplication sharedApplication ].applicationState;
    BOOL result = (state == UIApplicationStateBackground);
    if (result) {
        return;
    }
    
    if (_isStop == NO ) {
        
        //UIViewAnimationOptionCurveLinear是为了让lable做匀速动画
        [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            UILabel *lableOne = labelArray[0];
            UILabel *lableTwo = labelArray[1];
            
            lableOne.transform = CGAffineTransformMakeTranslation(-currentFrame.size.width, 0);
            lableTwo.transform = CGAffineTransformMakeTranslation(-currentFrame.size.width, 0);
            
        } completion:^(BOOL finished) {
            
            if (finished) {
                
            UILabel *lableOne = labelArray[0];
            lableOne.transform = CGAffineTransformIdentity;
            lableOne.frame = behindFrame;
            
            UILabel *lableTwo = labelArray[1];
            lableTwo.transform = CGAffineTransformIdentity;
            lableTwo.frame = currentFrame;
            
            [labelArray replaceObjectAtIndex:1 withObject:lableOne];
            [labelArray replaceObjectAtIndex:0 withObject:lableTwo];
            
            //递归调用
            [self doAnimation];
            }

        }];
    }
}


- (CGFloat) widthForTextString:(NSString *)tStr height:(CGFloat)tHeight fontSize:(CGFloat)tSize{
    
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:tSize]};
    CGRect rect = [tStr boundingRectWithSize:CGSizeMake(MAXFLOAT, tHeight) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    return rect.size.width+5;
    
}



@end
