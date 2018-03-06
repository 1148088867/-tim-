//
//  AppDelegate.h
//  随手记
//
//  Created by 刘怀智 on 16/5/4.
//  Copyright © 2016年 lhz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,copy)NSString *h5UrlString;

- (NSString *)postH5Url;
+ (BOOL)isExistenceNetwork;

/*
 self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
 self.window.backgroundColor = [UIColor whiteColor];
 MainTabarController *tabbar = [[MainTabarController alloc]init];
 self.window.rootViewController = tabbar;
 */

@end

