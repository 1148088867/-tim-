//
//  LoginViewController.m
//  随手记
//
//  Created by chen on 2017/11/17.
//  Copyright © 2017年 lhz. All rights reserved.
//

#import "LoginViewController.h"
#import "WSLoginView.h"

@interface LoginViewController ()
@property(nonatomic,strong)WSLoginView *loginView;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WSLoginView *wsLoginV = [[WSLoginView alloc]initWithFrame:self.view.bounds];
    wsLoginV.isLogining = _isLogin;
    wsLoginV.titleLabel.text = [self getAppName];
    wsLoginV.titleLabel.textColor = [UIColor grayColor];
    wsLoginV.hideEyesType = AllEyesHide;
    _loginView = wsLoginV;
    [self.view addSubview:wsLoginV];
    
    [_loginView setClickBlock:^(NSString *textField1Text, NSString *textField2Text) {
        if (_isLogin) {
            [self btnLoginClick];
        }else {
            [self btnRegisterBtnClick];
        }
    }];
    
}

- (void)btnRegisterBtnClick {
    
    NSString *textField1 = _loginView.textField1.text;
    NSString *textField2 = _loginView.textField2.text;
    if (textField1.length > 0 && textField2.length > 0) {
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setValue:textField1 forKeyPath:@"account"];
        [userDefault setValue:textField2 forKeyPath:@"pwd"];
        
        UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"注册成功，并登录" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertV show];
        
        [userDefault setBool:YES forKey:@"isShowAccount"];
        
    }else {
        
        UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"账号或密码格式不对" message:@"账号和密码非空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertV show];
    }
    
}

- (void)btnLoginClick {
    NSString *textField1 = _loginView.textField1.text;
    NSString *textField2 = _loginView.textField2.text;
    if (textField1.length > 0 && textField2.length > 0) {
            
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            NSString *accountStr = [userDefault stringForKey:@"account"];
            NSString *pwdStr = [userDefault stringForKey:@"pwd"];
            
            if ([accountStr isEqualToString: textField1] && [pwdStr isEqualToString:textField2]) {
                UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"登录成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertV show];
                [userDefault setBool:YES forKey:@"isShowAccount"];
            }else {
                UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"登录失败" message:@"账号和密码不匹配，请重新输入或重新注册" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertV show];
            }
        
    }else {
        
        UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"账号或密码格式不对" message:@"账号和密码非空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertV show];
    }
    
}



-(void)viewWillAppear:(BOOL)animated  {
    [super viewWillAppear: animated];
    self.navigationController.navigationBarHidden = NO;
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}


- (NSString *)getAppName {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *string = [infoDict objectForKey:@"CFBundleDisplayName"];
    return string;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
