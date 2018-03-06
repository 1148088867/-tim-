//
//  category.h
//  layoutDemo
//
//  Created by 何易东 on 16/5/16.
//  Copyright © 2016年 dong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface category : NSObject

@property (nonatomic, copy) NSString *iconName; ///<图标
@property (nonatomic, copy) NSString *categoryName; ///<名称
@property (nonatomic, strong) NSNumber *categoryID; ///<ID
@property (nonatomic, assign) BOOL isOut;  ///<是否是支出
@property (nonatomic, copy) NSString *categoryColorStr; ///<颜色字符
@property (nonatomic, strong) UIColor *categoryColor; ///<颜色
@property (nonatomic, strong) UIImage *iconImage;
@end
