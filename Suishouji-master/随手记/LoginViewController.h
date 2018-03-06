//
//  LoginViewController.h
//  随手记
//
//  Created by chen on 2017/11/17.
//  Copyright © 2017年 lhz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol wsLoginViewControllerDelegate
- (void)logingOrRegisterSuccess;
@end

@interface LoginViewController : UIViewController

@property(nonatomic,assign)id delegate;
@property(nonatomic,assign)BOOL isLogin;

@end
