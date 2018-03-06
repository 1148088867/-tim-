//
//  MainTabarController.m
//  随手记
//
//  Created by chen on 2017/11/13.
//  Copyright © 2017年 lhz. All rights reserved.
//

#import "MainTabarController.h"
#import "HomeViewController.h"
#import "budgetController.h"
#import "CakeViewController.h"
#import "RunningAccountViewController.h"
#import "WhiteViewController.h"
#import "SettingViewController.h"

#import "AddBillViewController.h"

@interface MainTabarController () <UITabBarControllerDelegate>

@end

@implementation MainTabarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    [self addChildViewControllers];
}

- (UIViewController *)childViewControllerWithClsName:(NSString *)clsName title:(NSString *)title imageName:(NSString *)imageName {
    
    UIViewController *vc;
    if ([clsName isEqualToString:@"budgetController"]) {
        vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"budget"];
    }else {
        Class cls = NSClassFromString(clsName);
        NSAssert([cls isSubclassOfClass:[UIViewController class]], @"传入了的类名不正确，无法创建控制器类");
        
        vc = [cls new];
    }
    
    vc.title = title;
    vc.tabBarItem.image = [UIImage imageNamed:imageName];
    
    
    return vc;
}

/// 添加所有子控制器
- (void)addChildViewControllers {
    NSMutableArray *children = [NSMutableArray array];
    
    [children addObject:[self childViewControllerWithClsName:@"HomeViewController" title:@"首页" imageName:@"首页"]];
    
    [children addObject:[self childViewControllerWithClsName:@"budgetController" title:@"预算" imageName:@"预算"]];
    [children addObject:[self childViewControllerWithClsName:@"WhiteViewController" title:@" " imageName:@"add"]];
    [children addObject:[self childViewControllerWithClsName:@"RunningAccountViewController" title:@"结余" imageName:@"结余"]];
    
    UIStoryboard *storyB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingViewController *settingVC = [storyB instantiateViewControllerWithIdentifier:@"setting"];
    settingVC.title = @"更多";
    settingVC.tabBarItem.image = [UIImage imageNamed:@"设置"];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:settingVC];
    [children addObject:nav];
//    [children addObject:[self childViewControllerWithClsName:@"WhiteViewController" title:@"设置" imageName:@"设置"]];
    
    self.viewControllers = children.copy;
}


- (UITabBarItem *)createTabarItemWith:(UIViewController *)vc andTitle:(NSString *)title{
    UITabBarItem *item = [[UITabBarItem alloc]initWithTitle:title image:[UIImage imageNamed:@""] selectedImage:[UIImage imageNamed:@""]];
    
    return item;
}

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[WhiteViewController class]]) {
        NSLog(@"");
        UIStoryboard *storyB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AddBillViewController *controller = [storyB instantiateViewControllerWithIdentifier:@"RightWin"];
        
        [self presentViewController:controller animated:YES completion:nil];
        
    }else {
        
    }
    return  YES;
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
