//
//  NavView.m
//  随手记
//
//  Created by 刘怀智 on 16/5/29.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import "NavView.h"

#define Kscale [UIScreen mainScreen].bounds.size.width / 320 ///< 比例
#define  Kheight 50 * Kscale ///<高
#define KcancellBtnWidth 25 * Kscale
#define KoutBtnWidth 40 * Kscale
#define KoutBtnHeight 30 * Kscale
#define KtextColor [UIColor grayColor]
#define KselectedColor [UIColor colorWithRed:237/255.00 green:146/255.00 blue:65/255.00 alpha:1]
#define KbackgroundColor [UIColor whiteColor]
@interface NavView ()

@property (nonatomic, strong) UIImageView *cancellBtn;
@property (nonatomic, strong) UIButton *outBtn;
@property (nonatomic, strong) UIButton *inputBtn;
@property (nonatomic, strong) UIButton *keepBtn;

@end

@implementation NavView

- (instancetype)init
{
    if (self = [super init]) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        self.frame = CGRectMake(0, 20, size.width, Kheight);
        self.backgroundColor = KbackgroundColor;
        
        [self creatBtns];
    }
    return self;
}

- (void)creatBtns
{
    //返回
    self.cancellBtn = [[UIImageView alloc]initWithFrame:CGRectMake(10, 25/2.0 * Kscale, KcancellBtnWidth, KcancellBtnWidth)];
    self.cancellBtn.image = [UIImage imageNamed:@"cancel"];
    self.cancellBtn.userInteractionEnabled = YES;
    UITapGestureRecognizer *cancelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelTapGesture:)];
    [self.cancellBtn addGestureRecognizer:cancelTap];
    [self addSubview:self.cancellBtn];
    //支出
    self.outBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width/2 - KoutBtnWidth, 10 * Kscale, KoutBtnWidth, KoutBtnHeight)];
    [self.outBtn setTitle:@"支出" forState:UIControlStateNormal];
    [self.outBtn setTitleColor:KselectedColor forState:UIControlStateNormal];
    UITapGestureRecognizer *outBtnTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(outBtnsTap:)];
    [self.outBtn addGestureRecognizer:outBtnTap];
        [self addSubview: self.outBtn];
    
    //收入
    self.inputBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width/2, 10 * Kscale, KoutBtnWidth, KoutBtnHeight)];
    [self.inputBtn setTitle:@"收入" forState:UIControlStateNormal];
    [self.inputBtn setTitleColor:KtextColor forState:UIControlStateNormal];

    UITapGestureRecognizer *inputBtnTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(inputBtnsTap:)];
    [self.inputBtn addGestureRecognizer:inputBtnTap];
    [self addSubview: self.inputBtn];
    //保存
    self.keepBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - KoutBtnWidth, 10 * Kscale, KoutBtnWidth, KoutBtnHeight)];
    UITapGestureRecognizer *keepBtnTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keepBtnTap:)];
    [self.keepBtn addGestureRecognizer:keepBtnTap];
    [self.keepBtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.keepBtn setTitleColor:KtextColor forState:UIControlStateNormal];
    [self addSubview: self.keepBtn];
    
}

-(void)cancelTapGesture:(UITapGestureRecognizer *)sender
{
    NSLog(@"cancel");
    [self selectedBtnWithBtnName:cancel];
}
- (void)outBtnsTap:(UITapGestureRecognizer *)sender
{
    [self.outBtn setTitleColor:KselectedColor forState:UIControlStateNormal];
    [self.inputBtn setTitleColor:KtextColor forState:UIControlStateNormal];
    NSLog(@"out");
    [self selectedBtnWithBtnName:outBtn];
}

- (void)inputBtnsTap:(UITapGestureRecognizer *)sender
{
    [self.inputBtn setTitleColor:KselectedColor forState:UIControlStateNormal];
    [self.outBtn setTitleColor:KtextColor forState:UIControlStateNormal];
    
    NSLog(@"input");
    [self selectedBtnWithBtnName:inputBtn];
}
- (void)keepBtnTap:(UITapGestureRecognizer *) sender
{
    NSLog(@"keep");
    [self selectedBtnWithBtnName:keepBtn];
}

- (void)selectedBtnWithBtnName:(BtnName) name
{
    if ([self.delegate respondsToSelector:@selector(selectedBtnName:)]) {
        [self.delegate selectedBtnName:name];
    }
}
- (void)selectedBtnBetweenOutInput:(BtnName) name
{
    if (name == 1) {
        [self.outBtn setTitleColor:KselectedColor forState:UIControlStateNormal];
        [self.inputBtn setTitleColor:KtextColor forState:UIControlStateNormal];
    }
    else if (name == 2)
    {
        [self.inputBtn setTitleColor:KselectedColor forState:UIControlStateNormal];
        [self.outBtn setTitleColor:KtextColor forState:UIControlStateNormal];
    }
    
}
@end
