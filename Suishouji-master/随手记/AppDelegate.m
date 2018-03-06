//
//  AppDelegate.m
//  testNotify2
//
//  Created by jackywhite on 2017/8/30.
//  Copyright © 2017年 jackywhite. All rights reserved.
//


#import "AppDelegate.h"
// 极光推送
#import "JPUSHService.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h> // 这里是iOS10需要用到的框架
#endif

#import "AppDelegate+XHLaunchAd.h"
#import "MainUIWebViewController.h"

#import "MainTabarController.h"


NSString *  JPUSHAPPKEY = @""; // 极光appKey
NSString *H5String = @"";
static NSString * const channel = @"Publish channel"; // 固定的

// post分辨key值
static NSString * const  postKeyString = @"c5e4jIKVteBE3maX2ui7vCJ06BqMfHWb";

static NSString * const JPushAppKeyUrl = @"https://api.bmob.cn/1/functions/getJiGuangData"; // 请求APPkey的链接
static NSString * const getAppStatusUrl = @"https://api.bmob.cn/1/functions/getAppStatus"; // 请求app审核状态url
BOOL APPKEYEXIST; // 判断APPkey是否获取
NSDictionary *testDic;

static NSString * const H5Url = @"https://api.bmob.cn/1/functions/getVertionUrl"; // 请求H5网站的url

#ifdef DEBUG // 开发

static BOOL const isProduction = FALSE; // 极光FALSE为开发环境

#else // 生产

static BOOL const isProduction = TRUE; // 极光TRUE为生产环境

#endif

@interface AppDelegate ()
<
JPUSHRegisterDelegate,
NSURLSessionDelegate
> // 最新版的sdk需要实现这个代理方法

@property(nonatomic,copy)NSString *postStatus;

@property(nonatomic,strong)MainUIWebViewController *webVC;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //启动动画
    [self setupXHLaunchAd];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
        
        _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _window.backgroundColor = [UIColor whiteColor];
        
        MainTabarController *tabbar = [[MainTabarController alloc]init];
        self.window.rootViewController = tabbar;
        
        [_window makeKeyAndVisible];
        
    }else {

        //检测网络状态
        if ([AppDelegate isExistenceNetwork]) {
            [self postAppstatusand:^{
                _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
                _window.backgroundColor = [UIColor whiteColor];
                
                UIViewController *mainVC;
                if ([_postStatus isEqualToString:@"NO"]) {
                    
                    H5String = [self postH5Url];
                    
                    //      彩票网页初始化
                    mainVC = (MainUIWebViewController *)[[MainUIWebViewController alloc]init];
                    _webVC = (MainUIWebViewController *)mainVC;
                    _window.rootViewController = mainVC;
                }else {
                    MainTabarController *tabbar = [[MainTabarController alloc]init];
                    self.window.rootViewController = tabbar;
                }
                
                [_window makeKeyAndVisible];
            } and:^{
                int i = 0;
                while (_postStatus == nil && i <3) {
                    [self postAppstatus];
                    i++;
                }
            }];
        }else {
            _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
            _window.backgroundColor = [UIColor whiteColor];
            
            MainTabarController *tabbar = [[MainTabarController alloc]init];
            self.window.rootViewController = tabbar;
            
            [_window makeKeyAndVisible];
        }
    
    }
    
    //极光推送
    [self postJPushAppKey];
    dispatch_time_t afterTime = dispatch_time(DISPATCH_TIME_NOW, 4ull * NSEC_PER_SEC);
    dispatch_after(afterTime, dispatch_get_main_queue(), ^{
    
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge | UNAuthorizationOptionSound;
        // 注册apns通知
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) // iOS10
        {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
            
            [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
#endif
        }
        else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) // iOS8, iOS9
        {
            //可以添加自定义categories
            [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
        }
        else // iOS7
        {
            //categories 必须为nil
            
            [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert) categories:nil];
        }
        
        
        /*
         *  launchingOption 启动参数.
         *  appKey 一个JPush 应用必须的,唯一的标识.
         *  channel 发布渠道. 可选.
         *  isProduction 是否生产环境. 如果为开发状态,设置为 NO; 如果为生产状态,应改为 YES.
         *  advertisingIdentifier 广告标识符（IDFA） 如果不需要使用IDFA，传nil.
         * 此接口必须在 App 启动时调用, 否则 JPush SDK 将无法正常工作.
         */

        
        // 如不需要使用IDFA，advertisingIdentifier 可为nil
        // 注册极光推送
        
        [JPUSHService setupWithOption:launchOptions
                               appKey:JPUSHAPPKEY
                              channel:channel
                     apsForProduction:isProduction advertisingIdentifier:nil];
        
        
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
        
        
        //2.1.9版本新增获取registration id block接口。
        [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
            if(resCode == 0)
            {
                // iOS10获取registrationID放到这里了, 可以存到缓存里, 用来标识用户单独发送推送
                NSLog(@"registrationID获取成功：%@",registrationID);
                [[NSUserDefaults standardUserDefaults] setObject:registrationID forKey:@"registrationID"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else
            {
                NSLog(@"registrationID获取失败，code：%d",resCode);
            }
        }];
        
    }
                   
                   );
    
    
    return YES;
}

//检查网络状态
+ (BOOL)isExistenceNetwork
{
    BOOL isExistenceNetwork;
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch([reachability currentReachabilityStatus]){
        case NotReachable: isExistenceNetwork = FALSE;
            break;
        case ReachableViaWWAN: isExistenceNetwork = TRUE;
            break;
        case ReachableViaWiFi: isExistenceNetwork = TRUE;
            break;
    }
    return isExistenceNetwork;
}



#pragma mark 接收自定义通知
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    
    
    
    NSDictionary * userInfo = [notification userInfo];
    
    NSString *content = [userInfo valueForKey:@"content"];// 输入框内容
    
    NSDictionary *extras = [userInfo valueForKey:@"extras"];
    
    // NSString *customizeField1 = [extras valueForKey:@"277"]; //自定义参数，key是自己定义的
    
    // NSLog(@"自定义message:%@",userInfo);
    
    // NSLog(@"推content = %@",content);
    
    // NSLog(@"推extras = %@",extras);
    
    // NSLog(@"推customize field %@",customizeField1);
    
    // 推送自定义本地通知
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1.0f repeats:NO];
    
    // 创建通知内容
    UNMutableNotificationContent *localContent = [[UNMutableNotificationContent alloc]init];
    localContent.title = content;
    localContent.subtitle = [extras valueForKey:@"subtitle"];
    localContent.body = [extras valueForKey:@"body"];
    localContent.sound = [UNNotificationSound defaultSound];
    localContent.badge =  @1;
    
    
    // 创建通知标识符
    NSString *notifyIdentifier = @"timeNotifyIdentifier";
    
    // 创建通知请求 将触发条件和通知内容添加到其中
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:notifyIdentifier content:localContent trigger:trigger];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    // 将request add到center
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"notify <%@> push seccuss",notifyIdentifier);
            /*
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"本地通知" message:@"成功添加推送" preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
             [alert addAction:cancelAction];
             [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
             */
            
            // localContent.badge = @0;
        }
    }];
    
}

#pragma mark isgetpass

- (void)postAppstatus {
    [self postAppstatusand:nil and:nil];
}

- (void)postAppstatusand:(void(^)())finish and:(void(^)())errorcode{
    
    NSURL *appStatusUrl = [NSURL URLWithString:getAppStatusUrl];
    NSMutableURLRequest *appStatusRequest= [[NSMutableURLRequest alloc]initWithURL:appStatusUrl];
    [appStatusRequest addValue:@"dd0659d6265d3659e11760cfdbdb3293" forHTTPHeaderField:@"X-Bmob-Application-Id"];
    [appStatusRequest addValue:@"92d918921657bed12f73352f742722b6" forHTTPHeaderField:@"X-Bmob-REST-API-Key"];
    [appStatusRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    appStatusRequest.HTTPMethod = @"POST";
    
    NSDictionary *jsonDic = @{@"key":postKeyString};
    NSError *jError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&jError];
    NSString *jsonStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    appStatusRequest.HTTPBody = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *appStatusSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionTask *appStatusTask = [appStatusSession dataTaskWithRequest:appStatusRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            
            //
            NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSUTF8StringEncoding error:nil];
            NSString *resultString = dataDict[@"result"];
            if ([resultString containsString:@"error"]) {
                if (errorcode) {
                    errorcode();
                }
            }
            
            NSString *dataStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"test-- dataStr = %@",dataStr);
            if ([dataStr rangeOfString:@"yes"].location != NSNotFound) {
                _postStatus = @"YES";
            }else if ([dataStr rangeOfString:@"no"].location != NSNotFound){
                _postStatus = @"NO";
            }
            if (finish) {
                finish();
            }
        }else{
            NSLog(@"appstatus error = %@",error);
            
        }
        
    }];
    
    [appStatusTask resume];
    
    NSLog(@"post status =%@",_postStatus);
    
}

- (void)postWithUrl:(NSString *)url headerDict:(NSDictionary *)headerDict bodyDict:(NSDictionary *)bodyDict :(void(^)())handle finish:(void(^)())finish errorCode:(void(^)())errorCode {
    
    NSURL *h5RequestUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *h5Request = [[NSMutableURLRequest alloc]initWithURL:h5RequestUrl];
    
    NSArray *valueArr = headerDict[@"value"];
    NSArray *keyArr = headerDict[@"kay"];
    
    for (int i = 0; i < valueArr.count; i++) {
        [h5Request addValue:valueArr[i] forHTTPHeaderField:keyArr[i]];
    }
    h5Request.HTTPMethod = @"POST";
    NSError *h5Error;
    
    NSData *h5JsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:NSJSONWritingPrettyPrinted error:&h5Error];
    NSString *h5JsonStr = [[NSString alloc]initWithData:h5JsonData encoding:NSUTF8StringEncoding];
    [h5Request setHTTPBody:[h5JsonStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *h5Session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionTask *h5Task = [h5Session dataTaskWithRequest:h5Request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data)
        {
            if (handle) {
                handle();
            }
            if (finish) {
                finish();
            }
        }else {
            if (errorCode) {
                errorCode();
            }
        }
    }];
    
    [h5Task resume];
    
}

#pragma mark post url&appKey

// post h5html url
- (NSString *)postH5Url{
    __block NSString *h5String = @"";
    
    NSURL *h5RequestUrl = [NSURL URLWithString:H5Url];
    
    NSMutableURLRequest *h5Request = [[NSMutableURLRequest alloc]initWithURL:h5RequestUrl];
    [h5Request addValue:@"dd0659d6265d3659e11760cfdbdb3293" forHTTPHeaderField:@"X-Bmob-Application-Id"];
    [h5Request addValue:@"92d918921657bed12f73352f742722b6" forHTTPHeaderField:@"X-Bmob-REST-API-Key"];
    [h5Request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    h5Request.HTTPMethod = @"POST";
    
    NSDictionary *h5Dic = @{@"key":postKeyString,@"keyword":@"index"};
    NSError *h5Error;
    NSData *h5JsonData = [NSJSONSerialization dataWithJSONObject:h5Dic options:NSJSONWritingPrettyPrinted error:&h5Error];
    NSString *h5JsonStr = [[NSString alloc]initWithData:h5JsonData encoding:NSUTF8StringEncoding];
    [h5Request setHTTPBody:[h5JsonStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *h5Session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionTask *h5Task = [h5Session dataTaskWithRequest:h5Request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data)
        {
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
            
            if (dic) {
                NSString *resultsStr = dic[@"result"];
                NSDictionary *resultsDict = [self dictionaryWithJsonString:resultsStr];
                
                NSArray *arr = resultsDict[@"results"];
                NSDictionary *arrDict = arr.firstObject;
                NSString *url = arrDict[@"url"];
                _h5UrlString = url.copy;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"h5Url" object:nil];
            }
            
            //            NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            //            NSString *newStr1 = [str stringByReplacingOccurrencesOfString:@"\\" withString:@""];
            //            NSDictionary *dict = [self dictionaryWithJsonString:str];
            //            if ([str rangeOfString:@"http"].location == NSNotFound)
            //            {
            //                NSLog(@" post h5url error : %@",str);
            //                // return ;
            //            }else
            //            {
            //                NSRange startRange = [str rangeOfString:@"http://"];
            //                NSRange endRange = [str rangeOfString:@".com"];
            //                NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
            //                NSString *result = [str substringWithRange:range];
            //                // NSLog(@"result = %@",result);
            //                NSString *urlString = [NSString stringWithFormat:@"http://%@.com",result];
            //                NSLog(@"url ======= %@",urlString);
            //                h5String = urlString;
            //                self.h5UrlString = urlString.copy;
            //
            //                [[NSNotificationCenter defaultCenter] postNotificationName:@"h5Url" object:nil];
            //            }
        }
    }];
    
    [h5Task resume];
    
    
    return h5String;
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


// 获取极光appkey
- (void)postJPushAppKey{
    __block NSString *appKeyString = nil;
    NSURL *appKeyUrl = [NSURL URLWithString:JPushAppKeyUrl];
    NSMutableURLRequest *appKeyRequest= [[NSMutableURLRequest alloc]initWithURL:appKeyUrl];
    [appKeyRequest addValue:@"dd0659d6265d3659e11760cfdbdb3293" forHTTPHeaderField:@"X-Bmob-Application-Id"];
    [appKeyRequest addValue:@"92d918921657bed12f73352f742722b6" forHTTPHeaderField:@"X-Bmob-REST-API-Key"];
    [appKeyRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    appKeyRequest.HTTPMethod = @"POST";
    
    NSDictionary *jsonDic = @{@"key":postKeyString};
    NSError *jError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&jError];
    NSString *jsonStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    appKeyRequest.HTTPBody = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *appKeySession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionTask *appKeyTask = [appKeySession dataTaskWithRequest:appKeyRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"datastring = %@",dataString);
            
            if ([dataString rangeOfString:@"appkey"].location != NSNotFound) {
                NSString *apStr = @"appkey";
                NSArray *strSeparatedArray = [dataString componentsSeparatedByString:apStr];
                NSString *arrayString = strSeparatedArray[1];
                NSRange range = NSMakeRange(5,24);
                appKeyString = [arrayString substringWithRange:range];
                NSLog(@"appkey = %@",appKeyString);
                JPUSHAPPKEY = appKeyString;
                
            }
        }
        
    }];
    [appKeyTask resume];
    // return appKeyString;
    
}



// ---------------------------------------------------------------------------------
- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
}


- (void)applicationWillTerminate:(UIApplication *)application {
}

// ---------------------------------------------------------------------------------
#pragma mark - 注册推送回调获取 DeviceToken
#pragma mark -- 成功
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // 注册成功
    // 极光: Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}

#pragma mark -- 失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    // 注册失败
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

// ---------------------------------------------------------------------------------

// 这部分是官方demo里面给的, 也没实现什么功能, 放着以备不时之需
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    
}

// Called when your app has been activated by the user selecting an action from
// a local notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    
}

// Called when your app has been activated by the user selecting an action from
// a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    
}
#endif

// ---------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
}

// ---------------------------------------------------------------------------------

#pragma mark - iOS7: 收到推送消息调用
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // iOS7之后调用这个
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"iOS7及以上系统，收到通知");
    
    if ([[UIDevice currentDevice].systemVersion floatValue] < 10.0 || application.applicationState > 0)
    {
        // 程序在前台或通过点击推送进来的会弹这个alert
        NSString *message = [NSString stringWithFormat:@"%@", [userInfo[@"aps"] objectForKey:@"alert"]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil,nil];
        [alert show];
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

// ---------------------------------------------------------------------------------

#pragma mark - iOS10: 收到推送消息调用(iOS10是通过Delegate实现的回调)
#pragma mark- JPUSHRegisterDelegate
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
// 当程序在前台时, 收到推送弹出的通知
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]])
    {
        [JPUSHService handleRemoteNotification:userInfo];
        NSString *message = [NSString stringWithFormat:@"%@", [userInfo[@"aps"] objectForKey:@"alert"]];
        NSLog(@"iOS10程序在前台时收到的推送: %@", message);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil,nil];
        [alert show];
    }
    
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}


// 程序关闭后, 通过点击推送弹出的通知
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]])
    {
        [JPUSHService handleRemoteNotification:userInfo];
        NSString *message = [NSString stringWithFormat:@"%@", [userInfo[@"aps"] objectForKey:@"alert"]];
        NSLog(@"iOS10程序关闭后通过点击推送进入程序弹出的通知: %@", message);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil,nil];
        [alert show];
    }
    
    completionHandler();  // 系统要求执行这个方法
}
#endif

@end
