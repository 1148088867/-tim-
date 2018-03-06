//
//  AddBtnView.h
//  随手记
//
//  Created by 刘怀智 on 16/5/9.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddBtnView;
@protocol AddBtnViewDelegate <NSObject>

- (void)juttonJump:(AddBtnView *)btn;

@end

@interface AddBtnView : UIView

@property (nonatomic, weak) id<AddBtnViewDelegate>delegate;

@property (nonatomic, strong) NSMutableArray *colorsArray;
@property (nonatomic, strong) UIImageView *addImage; ///<图片
@property (nonatomic, strong) UIView *centerView; ///<中间的View
@property (nonatomic, copy) NSString *imageName; ///<图片名
@property (nonatomic, assign) NSInteger lineWidth; ///<线宽
@property (nonatomic, strong) NSMutableArray *aboutRingArray;

-(void) updataLayer:(BOOL)isShow;
-(NSInteger)getLayerIndexWithPoint:(CGPoint)point;
@end
