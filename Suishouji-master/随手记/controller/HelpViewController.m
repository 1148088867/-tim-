//
//  HelpViewController.m
//  随手记
//
//  Created by chen on 2017/11/14.
//  Copyright © 2017年 lhz. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()
@property(nonatomic,strong)UILabel *changeLabel;
@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
}

-(void)setIndex:(int)index {
    _index = index;
    
    switch (index) {
        case 0:
            _changeLabel.text = @"联系QQ:3124738950";
            break;
        case 1:
            _changeLabel.text = @"厦门北烽网络有限公司";
            break;
        case 2:
            _changeLabel.text = [self getVersionNumber];
            break;

        default:
            break;
    }
    
}

- (void)setupUI {
    //应用图标
    UIImageView *topIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    CGPoint center = CGPointMake(self.view.center.x, 90 + 40);
    topIcon.center = center;
    topIcon.image = [self getAppIconName];
    [self.view addSubview:topIcon];
    //应用名称
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    center.y += 70;
    nameLabel.center = center;
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = [UIFont systemFontOfSize:18];
    nameLabel.text = [self getAppName];
    [self.view addSubview:nameLabel];
    //应用版本号
    UILabel *versionNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 34)];
    center.y += 44;
    versionNumLabel.center = center;
    versionNumLabel.textColor = [UIColor blackColor];
    versionNumLabel.font = [UIFont systemFontOfSize:15];
    versionNumLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:versionNumLabel];
    _changeLabel = versionNumLabel;
    
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

- (NSString *)getVersionNumber {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *string = [infoDict objectForKey:@"CFBundleVersion"];
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
