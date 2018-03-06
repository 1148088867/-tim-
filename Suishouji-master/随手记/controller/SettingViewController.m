//
//  SettingViewController.m
//  随手记
//
//  Created by chen on 2017/11/14.
//  Copyright © 2017年 lhz. All rights reserved.
//

#import "SettingViewController.h"
#import "HelpViewController.h"
#import "LoginViewController.h"

static NSString *cellid = @"cellidentifier";

@interface SettingViewController () <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,copy)NSArray *dataArray;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;

@property(nonatomic,assign)BOOL isShowAccount;


@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isShowAccount = NO;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:NO forKey:@"isShowAccount"];

    
    self.icon.image = [self getAppIconName];
    self.titleLabel.text = [self getAppName];
    self.titleLabel.textColor = [UIColor blackColor];
    
    _dataArray = @[@"帮助与反馈",@"关于我们",@"当前版本",@"退出登录"];
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellid];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault boolForKey:@"isShowAccount"]) {
        NSString *accountStr = [userDefault stringForKey:@"account"];
        if (accountStr.length > 0) {
            _loginButton.alpha = 0;
            _registerButton.alpha = 0;
            _accountLabel.text = accountStr;
            _accountLabel.textColor = [UIColor blueColor];
            _accountLabel.font = [UIFont systemFontOfSize:15];
        }
    }else {
        _loginButton.alpha = 1;
        _registerButton.alpha = 1;
        _accountLabel.text = @"";
    }
    
}
- (IBAction)loginBtnClick:(UIButton *)sender {
    LoginViewController *loginVC = [[LoginViewController alloc]init];
    loginVC.isLogin = YES;
    [self.navigationController pushViewController:loginVC animated:YES];
}
- (IBAction)registerBtnClick:(UIButton *)sender {
    LoginViewController *loginVC = [[LoginViewController alloc]init];
    loginVC.isLogin = NO;
    [self.navigationController pushViewController:loginVC animated:YES];
}


- (UIImage *)getAppIconName {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    //获取app中所有icon名字数组
    NSArray *iconsArr = infoDict[@"CFBundleIcons"][@"CFBundlePrimaryIcon"][@"CFBundleIconFiles"];
    //取最后一个icon的名字
    NSString *iconLastName = [iconsArr lastObject];
    UIImage *image = [UIImage imageNamed:iconLastName];
    return image;
}

- (NSString *)getAppName {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *string = [infoDict objectForKey:@"CFBundleDisplayName"];
    return string;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellid forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellid];
    }
    cell.textLabel.text = _dataArray[indexPath.row];
    //cell
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HelpViewController *helpVC = [[HelpViewController alloc]init];
    helpVC.view.backgroundColor = [UIColor whiteColor];
    if (indexPath.row == _dataArray.count-1) {
        [UIView animateWithDuration:0.3 animations:^{
            [self logOut];
        }];
        return;
    }
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:helpVC animated:YES];
    helpVC.title = _dataArray[indexPath.row];
    helpVC.index = (int)indexPath.row;
    self.hidesBottomBarWhenPushed = NO;
    
}

- (void)logOut {
    
//    _loginButton.alpha = 1;
//    _registerButton.alpha = 1;
//    _accountLabel.text = @"";
    
    self.isShowAccount = NO;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:NO forKey:@"isShowAccount"];
//    [userDefault setValue:@"" forKey:@"pwd"];
}

-(void)setIsShowAccount:(BOOL)isShowAccount {
    
    _isShowAccount = isShowAccount;
    if (!isShowAccount) {
        [UIView animateWithDuration:0.3 animations:^{
            _loginButton.alpha = 1;
            _registerButton.alpha = 1;
            _accountLabel.text = @"";
        }];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            _loginButton.alpha = 0;
            _registerButton.alpha = 0;
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            _accountLabel.text = [userDefault stringForKey:@"account"];;
        }];
    }
    
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
