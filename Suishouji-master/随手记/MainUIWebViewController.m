//
//  MainUIWebViewController.m
//  testNotify2
//
//  Created by chen on 2017/9/8.
//  Copyright © 2017年 jackywhite. All rights reserved.
//

#import "MainUIWebViewController.h"
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "AppDelegate.h"
#import "SDAutoLayout.h"
#import "LEDLabView.h"
#import "WebViewJavascriptBridge.h"

#import "MainTabarController.h"

//浏览器导航栏的高度
#define UrlNavHeight 30
//浏览器导航栏的宽度
#define UrlNavWidth ([[UIScreen mainScreen] bounds].size.width)
//
#define ImageEdgeInsetMargin 5

// 状态栏颜色
#define STATUS_BAR_COLOR [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:255.0/255.0 alpha:1]

@interface MainUIWebViewController () <UIWebViewDelegate>

@property(nonatomic,strong)UIWebView *webView;
@property(nonatomic,strong)WKWebView *aDWebView;
@property(nonatomic,strong)UIView *noDataView;

//外部链接
@property(nonatomic,copy)NSString *outUrlString;
//是否调用外部浏览器
@property(nonatomic,copy)NSString *isOutSide;

//广告内容
@property(nonatomic,copy)NSString *adContent;
//显示方式
@property(nonatomic,copy)NSString *showType;

//底部导航栏和广告
@property(nonatomic,strong)UIView *bottomNavView;

//返回按钮
@property(nonatomic,strong)UIButton *backButton;
//前进按钮
@property(nonatomic,strong)UIButton *forwardButton;
//刷新按钮
@property(nonatomic,strong)UIButton *closeButton;
//主页按钮
@property(nonatomic,strong)UIButton *mainUrlButton;

//广告view
@property(nonatomic,strong)LEDLabView *ledView;

//jwURL
@property(nonatomic,strong)NSString *JWURLString;

//jw返回按钮
@property(nonatomic,strong)UIButton *goBackBtn;

// js接口处理
@property(nonatomic,strong)WebViewJavascriptBridge *bridge;

@property(nonatomic,assign)BOOL isClose;
//要打开的第三方应用程序
@property(nonatomic,copy)NSString *appType;
//服务端传回的Url
@property(nonatomic,copy)NSString *serviceUrl;

@end



@implementation MainUIWebViewController

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webreload) name:@"h5Url" object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isClose = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = YES;
    // Do any additional setup after loading the view.
    
    if (_isFaildNet || ![AppDelegate isExistenceNetwork]) {
        [self addLoadFail];
    }else {
        // 输出日志
        //[WebViewJavascriptBridge enableLogging];
        
    }
    [self setupUI];
    
    [self buildNavUI];
    
}



- (void)addLoadFail{
    
    //缺省页
    _noDataView = [[UIView alloc]initWithFrame:self.view.bounds];
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, SCREEN_WIDTH/2-32, SCREEN_HEIGHT/2, 124)];
    imageView.centerX = SCREEN_WIDTH/2;
    imageView.image = [UIImage imageNamed:@"无网络"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_noDataView addSubview:imageView];
    
    
    
    UILabel *noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, imageView.bottom + 27, SCREEN_WIDTH, 16)];
    noDataLabel.font = [UIFont systemFontOfSize:15 ];
    noDataLabel.textColor = [UIColor colorWithRed:0x99/255 green:0x99/255 blue:0x99/255 alpha:1];
    noDataLabel.textAlignment = NSTextAlignmentCenter;
    noDataLabel.text = @"hello?好像没网络啊!";
    
    [_noDataView addSubview:noDataLabel];
    
    UIButton * noDataBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, noDataLabel.bottom+22, 100,22)];
    noDataBtn.centerX = SCREEN_WIDTH/2;
    [noDataBtn setTitle:@"刷新" forState:UIControlStateNormal];
    [noDataBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    noDataBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [noDataBtn.layer setCornerRadius:5];
    [noDataBtn.layer setMasksToBounds:YES];
    [noDataBtn.layer setBorderWidth:1];
    [noDataBtn.layer setBorderColor:[UIColor redColor].CGColor];
    [noDataBtn addTarget:self action:@selector(refreshBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [_noDataView addSubview:noDataBtn];
    
    [self.view addSubview:_noDataView];
    
    [NSThread sleepForTimeInterval:1.0];
    [self disconnect];
}

- (void)disconnect {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    window.backgroundColor = [UIColor whiteColor];
    MainTabarController *tabbar = [[MainTabarController alloc]init];
    [self presentViewController:tabbar animated:NO completion:nil];
    window.rootViewController = nil;
    window.rootViewController = tabbar;
    [window makeKeyAndVisible];
}

- (void)refreshBtn {
    
    if ([AppDelegate isExistenceNetwork]) {
        if (!_webView) {
            
            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appdelegate postH5Url];
            // self.JWURLString = appdelegate.h5UrlString;
            
            [self setupUI];
            
        }
    }else {
        if (!_noDataView) {
            [self addLoadFail];
        }
    }
}

- (void)addJSBridge{
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.bridge setWebViewDelegate:self];
    
    // NSLog(@"jackytes js");
    
    //广告
    [self.bridge registerHandler:@"BFJsBridge.showAd" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"BFJsBridge.showad, data = %@", data);
        if (responseCallback) {
            // 反馈给JS
            // responseCallback(@{@"userId": @"123456"});
        }
        
        self.adContent = [data valueForKey:@"contant"];
        
    }];
    //外部链接
    [self.bridge registerHandler:@"BFJsBridge.brower" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"BFJsBridge.brower, data = %@", data);
        if (responseCallback) {
            // 反馈给JS
            responseCallback(@{@"browerUrl": data[@"url"]});
        }
        
        self.outUrlString = [data valueForKey:@"url"];
        self.isOutSide = [NSString stringWithFormat:@"%@",data[@"isOutside"]];
        
    }];
    //ping++支付
    [self.bridge registerHandler:@"BFJsBridge.payWithPing" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@" BFJsBridge.payWithPing, data =%@", data);
        if (responseCallback) {
            // 反馈给JS
            // responseCallback(data[@"appType"]);
        }
        self.serviceUrl = [data valueForKey:@"serviceUrl"];
        //跳转到原生支付界面
//        PayNactiveViewController *payVC = [[PayNactiveViewController alloc]init];
//        payVC.serviceUrl = _serviceUrl.copy;
//        [self presentViewController:payVC animated:YES completion:nil];
        
        // serviceUrl
    }];
    //启动第三方应用
    [self.bridge registerHandler:@"BFJsBridge.startApp" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"BFJsBridge.startapp, data= %@", data);
        if (responseCallback) {
            // 反馈给JS
            // responseCallback(data[@"appType"]);
        }
        
        self.appType = [data valueForKey:@"appType"];
        [self openThirdApp:_appType.copy];
    }];
}

- (void)setupUI {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webreload) name:@"h5Url" object:nil];
    
    AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSLog(@"%@",_adContent);
    CGRect rect = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-20-((_isOutSide && _outUrlString)||_adContent?UrlNavHeight:0) );
    if (!_webView) {
        _webView = [[UIWebView alloc]initWithFrame:rect];
        // _webView = webView;
    }
    [UIView animateWithDuration:0.3 animations:^{
        _webView.frame = rect;
    }];
    
//    //底部导航栏和广告 视图
//    _bottomNavView = [[UIView alloc]initWithFrame:CGRectMake(0, _webView.bottom, SCREEN_WIDTH, UrlNavHeight)];
//    _bottomNavView.backgroundColor = RGB(136, 188, 201);
//    [self.view addSubview:_bottomNavView];
    
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:appdelegate.h5UrlString]]];
//    NSLog(@"test-h5urlstring = %@",appdelegate.h5UrlString);
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
//        NSString *appHtml = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//        NSURL *baseURL = [NSURL fileURLWithPath:path];
//        [_webView loadHTMLString:appHtml baseURL:baseURL];
    
    [self.view addSubview:_webView];
    
    
    NSString *urlStr = [_isOutSide isEqualToString: @"1"]&&_outUrlString?_outUrlString:_webView.request.URL.scheme;
    //    NSLog(@"%@",urlStr);
    
    if ([_isOutSide isEqualToString: @"1"]&&_outUrlString) {
        if (!_aDWebView) {
            WKWebView *webView = [[WKWebView alloc]initWithFrame:rect];
            [self.view addSubview:webView];
            _aDWebView = webView;
        }
        [_aDWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    }
    
    
    _webView.delegate = self;
    
    [self buildNavUI];
    
    
}



#pragma mark 判断是否加载外部URL 和 广告


- (void)buildNavUI {
    int navWidth = UrlNavWidth;
    
    if (_backButton && _ledView) {
        return;
    }
    for (int i = 0; i < 4; i++) {                   //138 166 201
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(i * (navWidth/4), _webView.bottom, navWidth/4, UrlNavHeight)];
        //            NSLog(@"--chen-- %@",NSStringFromCGRect(btn.frame));
        [self.view addSubview:btn];
        btn.backgroundColor = RGB(138, 166, 201);
        btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
//        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.imageEdgeInsets = UIEdgeInsetsMake(ImageEdgeInsetMargin, 0, ImageEdgeInsetMargin, 0);
        /*
        switch (i) {
            case 0:
                _backButton = btn;
//                [btn setTitle:@"后退" forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"后退"] forState:UIControlStateNormal];
                
                [btn addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
                break;
            case 1:
                _forwardButton = btn;
//                [btn setTitle:@"前进" forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"前进"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(forwardButtonClick) forControlEvents:UIControlEventTouchUpInside];
                break;
            case 2:
                _closeButton = btn;
//                [btn setTitle:@"刷新" forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"刷新"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
                break;
            case 3:
                _mainUrlButton = btn;
//                [btn setTitle:@"主页" forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"首页"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(mainUrlButtonClick) forControlEvents:UIControlEventTouchUpInside];
                break;
            default:
                break;
        }
         */
        //按钮调换位置
        switch (i) {
            case 0:
                _backButton = btn;
                //                [btn setTitle:@"后退" forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"首页"] forState:UIControlStateNormal];
                
                [btn addTarget:self action:@selector(mainUrlButtonClick) forControlEvents:UIControlEventTouchUpInside];
                break;
            case 1:
                _forwardButton = btn;
                //                [btn setTitle:@"前进" forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"刷新"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
                break;
            case 2:
                _closeButton = btn;
                //                [btn setTitle:@"刷新" forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"后退"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
                break;
            case 3:
                _mainUrlButton = btn;
                //                [btn setTitle:@"主页" forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"前进"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(forwardButtonClick) forControlEvents:UIControlEventTouchUpInside];
                break;
            default:
                break;
        }

    }
    if (!_ledView) {
        
        LEDLabView *aDView = [[LEDLabView alloc]initWithFrame:CGRectMake(_mainUrlButton.right, _webView.bottom, navWidth, UrlNavHeight) withTitleArray:@[@"广告广告广告"]];
        aDView.layer.cornerRadius = 4;
        aDView.layer.masksToBounds = YES;
        [self.view addSubview:aDView];
        _ledView = aDView;
    }
    
}
#pragma mark 导航栏按钮

- (void)backButtonClick {
    
    if (_aDWebView) {
        [_aDWebView goBack];
        return;
    }else{
        [_webView goBack];
    }
    //    if ([_webView canGoBack]) {
    //        [_webView goBack];
    //    }
}
- (void)forwardButtonClick {
    if (_aDWebView) {
        [_aDWebView goForward];
    }else {
        [_webView goForward];
    }
    //    if ([_webView canGoForward]) {
    //        [_webView goForward];
    //    }
}
- (void)closeButtonClick {
    
    [_webView reload];
    
}

- (void)mainUrlButtonClick {
    if (_webView) {
        AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:appdelegate.h5UrlString]]];
    }
}

- (void)animationWebNaV:(BOOL)isShow {
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-20-(isShow?UrlNavHeight:0));
        _webView.frame = rect;
        
        int navWidth = UrlNavWidth;
        if (_adContent) {
            navWidth = navWidth/2;
            
        }
        for (int i = 0; i < 4; i++) {
            //            CGRect rect = CGRectMake(i * (navWidth/4), _webView.bottom, navWidth/4, UrlNavHeight);
            switch (i) {
                case 0:
                    
                    _backButton.frame = CGRectMake(_backButton.left, _webView.bottom, navWidth/4, UrlNavHeight);;
                    
                    break;
                case 1:
                    _forwardButton.frame = CGRectMake(_backButton.right, _webView.bottom, navWidth/4, UrlNavHeight);
                    
                    break;
                case 2:
                    _closeButton.frame = CGRectMake(_forwardButton.right, _webView.bottom, navWidth/4, UrlNavHeight);
                    
                    break;
                case 3:
                    _mainUrlButton.frame = CGRectMake(_closeButton.right, _webView.bottom, navWidth/4, UrlNavHeight);
                    
                    break;
                    
                default:
                    break;
            }
        }
        
        
        _ledView.frame = CGRectMake(_mainUrlButton.right, _webView.bottom, _ledView.width, UrlNavHeight);
        [_aDWebView removeFromSuperview];
        self.isClose = YES;
    } completion:^(BOOL finished) {
        if (isShow) {
            _ledView.isStop = NO;
        }else {
            _ledView.isStop = YES;
        }
    }];
    
}

-(void)setIsClose:(BOOL)isClose {
    
    _isClose = isClose;
    
}
-(void)setAdContent:(NSString *)adContent {
    _adContent = adContent.copy;
    [self animationBottomView];
    NSLog(@"adcontant ======== jw ==== %@",_adContent);
}
-(void)setOutUrlString:(NSString *)outUrlString {
    _outUrlString = outUrlString.copy;
    [self animationBottomView];
}
-(void)setIsOutSide:(NSString *)isOutSide {
    _isOutSide = isOutSide.copy;
    [self animationBottomView];
}

//页面动画
- (void)animationBottomView {
    int navWidth = UrlNavWidth;
    //跳到外部链接
    if ( [_isOutSide isEqualToString:@"1"] && _outUrlString ){
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_outUrlString]];
        
    }else if ([_isOutSide  isEqualToString:@"0"] &&  _outUrlString ) {
        
        if (_adContent) {
            //底部显示广告 和导航
            navWidth = navWidth/2;
            [UIView animateWithDuration:0.3 animations:^{
                CGRect rect = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-20-UrlNavHeight);
                _webView.frame = rect;
                
                for (int i=0; i<4; i++) {
                    CGRect btnrect = CGRectMake(i * (navWidth/4), _webView.bottom, navWidth/4, UrlNavHeight);
                    float top = UrlNavHeight/2 -(UrlNavHeight-2*ImageEdgeInsetMargin)*3/8;
                    top = 8;
                    switch (i) {
                        case 0:
                            _backButton.frame = btnrect;
                            _backButton.imageEdgeInsets = UIEdgeInsetsMake(top, 0, top, 0);
                            break;
                        case 1:
                            _forwardButton.frame = btnrect;
                            _forwardButton.imageEdgeInsets = UIEdgeInsetsMake(top, 0, top, 0);
                            break;
                        case 2:
                            _closeButton.frame = btnrect;
                            _closeButton.imageEdgeInsets = UIEdgeInsetsMake(top, 0, top, 0);
                            break;
                        case 3:
                            _mainUrlButton.frame = btnrect;
                            _mainUrlButton.imageEdgeInsets = UIEdgeInsetsMake(top, 0, top, 0);
                            break;
                            
                            
                        default:
                            break;
                    }
                }
                
                if (_ledView) {
                    [_ledView removeFromSuperview];
                }
                LEDLabView *aDView = [[LEDLabView alloc]initWithFrame:CGRectMake(_mainUrlButton.right, _webView.bottom, navWidth, UrlNavHeight) withTitleArray:@[_adContent]];
                [self.view addSubview:aDView];
                aDView.layer.cornerRadius = 4;
                aDView.layer.masksToBounds = YES;
                _ledView = aDView;
            }];
        }else {
            //底部显示导航
            [UIView animateWithDuration:0.3 animations:^{
                CGRect rect = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-20-UrlNavHeight);
                _webView.frame = rect;
                
                for (int i=0; i<4; i++) {
                    CGRect btnrect = CGRectMake(i * (navWidth/4), _webView.bottom, navWidth/4, UrlNavHeight);
                    switch (i) {
                        case 0:
                            _backButton.frame = btnrect;
                            break;
                        case 1:
                            _forwardButton.frame = btnrect;
                            break;
                        case 2:
                            _closeButton.frame = btnrect;
                            break;
                        case 3:
                            _mainUrlButton.frame = btnrect;
                            break;
                            
                            
                        default:
                            break;
                    }
                }
                
            }];
        }
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_outUrlString]]];
        
    }else {     //不跳到外部链接
        if (_adContent) {
            //底部只显示广告
            //            [UIView animateWithDuration:0.3 animations:^{
            //                CGRect rect = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-20-UrlNavHeight);
            //                _webView.frame = rect;
            //
            //                if (_ledView) {
            //                    [_ledView removeFromSuperview];
            //                }
            //                CGRect ledVFrame = CGRectMake(0, _webView.bottom, navWidth, UrlNavHeight);
            //                if (_mainUrlButton) {
            //                    ledVFrame = CGRectMake(_mainUrlButton.right, _webView.bottom, navWidth, UrlNavHeight);
            //                }
            //                LEDLabView *aDView = [[LEDLabView alloc]initWithFrame:ledVFrame withTitleArray:@[_adContent]];
            //                [self.view addSubview:aDView];
            //                _ledView = aDView;
            //
            //            }];
            
            if (_ledView) {
                [_ledView removeFromSuperview];
            }
            
            LEDLabView *aDView = [[LEDLabView alloc]initWithFrame:CGRectMake(_mainUrlButton.right, _webView.bottom, navWidth, UrlNavHeight) withTitleArray:@[_adContent]];
            [self.view addSubview:aDView];
            _ledView = aDView;
            
            [self animationWebNaV:YES];
            
        }else {
            // 底部都不显示
            CGRect rect = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-20);
            _webView.frame = rect;
        }
    }
    
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

- (void)webViewDidStartLoad:(UIWebView *)webView{
    // jw JS调动原生
    
    
    
    
}

- (void)openThirdApp:(NSString *)appType {
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL  URLWithString:appType]]){
        NSLog(@"install--");
        NSArray *thirdAppArr = @[@"qq",@"weixin",@"alipay",@"sinaweibo"];
        NSArray *thirdUrlArr = @[@"mqq://",@"weixin://",@"alipay://",@"sinaweibo://"];
        NSString *thirdUtl ;
        for (int i = 0; i < thirdAppArr.count; i++) {
            if ([appType isEqualToString:thirdAppArr[i]]) {
                thirdUtl = thirdUrlArr[i];
                break;
            }
        }
        if (thirdUtl) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appType]];
        }
    }else{
        NSLog(@"no---");
    }
}


-(void)webViewDidFinishLoad:(UIWebView *)webView {
    // 判断是否为h5链接
    
    AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSString *urlStr = _webView.request.URL.absoluteString;
    if (![urlStr containsString:appdelegate.h5UrlString]) {
        [self animationWebNaV:YES];
    }else {
        [self animationWebNaV:NO];
    }
    
    NSLog(@"test- url%@",_webView.request.URL.absoluteString);
    
}



- (void)webreload {
    AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:appdelegate.h5UrlString]]];
    [self addJSBridge];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:@"h5Url"];
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
