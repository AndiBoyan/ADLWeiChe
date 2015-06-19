//
//  ViewController.m
//  ADLWeiChe
//
//  Created by icePhoenix on 15/6/3.
//  Copyright (c) 2015年 aodelin. All rights reserved.
//

#import "ViewController.h"
#import "OBShapedButton.h"
#import <sqlite3.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import <math.h>
#import "Reachability.h"
#import "CarPointViewController.h"
#import "LoadViewController.h"
#import "NewsViewController.h"
#import "UserInfoViewController.h"
#import "LoginViewController.h"
#import "HYActivityView.h"
#import "UserDefaults.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "ControlViewController.h"
#import "TrackViewController.h"
#import <CoreFoundation/CoreFoundation.h>
#import "GesturePasswordController.h"
#import "KeychainItemWrapper.h"
#import "Analyse.h"
#import "GpsPoint.h"
#import "ControlReslut.h"
#import "CarState.h"
#import "CSqlite.h"
#import "AppDelegate.h"
#import "AddCarViewController.h"

@interface ViewController ()<AMapSearchDelegate,UIActionSheetDelegate>
{
    sqlite3 *database;
    AMapSearchAPI *_search;
    UILabel *addressLab;//地址label
    UILabel *adrTitle;
    UIView *hostView;
    UIView *contentView;
    UILabel *tempLab;
    UILabel *wertherLab;
    UIImageView *wearthIV;
    CSqlite *m_sqlite;
    BOOL moveState;
    UILabel *loginLab;
}

@property (nonatomic, strong) HYActivityView *activityView;
@property (nonatomic,strong) GesturePasswordView * gesturePasswordView;

@end

@implementation ViewController
{
    NSString * previousString;
    NSString * password;
}

@synthesize gesturePasswordView;


- (void)viewDidLoad {
    addressLab = [[UILabel alloc]init];
    adrTitle = [[UILabel alloc]init];
    hostView = [[UIView alloc]init];
    contentView = [[UIView alloc]init];
    moveState = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
  
    UIImageView *backgroundIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backgroundIV.image = [UIImage imageNamed:@"background.png"];
    [self.view addSubview:backgroundIV];
   
    UIImageView *IV = [[UIImageView alloc]initWithFrame:CGRectMake(98, 300, 16, 16)];
    IV.image = [UIImage imageNamed:@"main_logo.png"];
    [self.view addSubview:IV];
    [self rotationView:IV];
    
    [self drawObshapedButton:CGRectMake(108, 215, 89, 90) tag:1000 image:@"navigation.png"];
    [self drawObshapedButton:CGRectMake(108, 310, 179, 188) tag:1001 image:@"tracking.png"];
    [self drawObshapedButton:CGRectMake(202, 112, 100, 100) tag:1002 image:@"carlife.png"];
    [self drawObshapedButton:CGRectMake(27, 230, 76, 76) tag:1003 image:@"news.png"];
    [self drawObshapedButton:CGRectMake(25, 310, 79, 79) tag:1004 image:@"wearther.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(38, 72, 42, 42);
    UIImage *buttonImage = [UIImage imageNamed:@"login.png"];
    UIImage *stretchableButtonImage1 = [buttonImage  stretchableImageWithLeftCapWidth:12  topCapHeight:0];
    [button setBackgroundImage:stretchableButtonImage1 forState:UIControlStateNormal];
    [button addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    [self addressLabel:addressLab frame:CGRectMake(120, 350, 150, 40) numberOfLine:YES sizeOfFont:10 color:[UIColor colorWithRed:0.6078 green:0.6039 blue:0.5882 alpha:1.0f]];
    [self addressLabel:adrTitle frame:CGRectMake(120, 325, 100, 40) numberOfLine:NO sizeOfFont:12 color:[UIColor colorWithRed:0.223f green:0.667f blue:0.863f alpha:1.0f]];
    adrTitle.text = @"车辆位置:";
    
    tempLab = [[UILabel alloc]initWithFrame:CGRectMake(70, 325, 40, 20)];
    tempLab.font = [UIFont systemFontOfSize:12.0f];
    tempLab.textColor = [UIColor whiteColor];
    [self.view addSubview:tempLab];
    wearthIV = [[UIImageView alloc]initWithFrame:CGRectMake(25, 315, 45, 45)];
    [self.view addSubview:wearthIV];
    
    wertherLab = [[UILabel alloc]initWithFrame:CGRectMake(25, 360, 80, 20)];
    wertherLab.textColor = [UIColor whiteColor];
    wertherLab.textAlignment = NSTextAlignmentCenter;
    wertherLab.font = [UIFont systemFontOfSize:12.0f];
    [self.view addSubview:wertherLab];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(240, 390, 30, 30);
    [btn setTitle:@"+" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:btn];
    
    [self connect];
    lastLat = 0.0f;
    lastlon = 0.0f;
    m_sqlite = [[CSqlite alloc]init];
    [m_sqlite openSqlite];
}
-(void)login
{
    //用户信息
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    if (delegate.isLogin) {
        UserInfoViewController *userinfoVC = [[UserInfoViewController alloc]init];
        [self presentViewController:userinfoVC animated:YES completion:nil];
        
    }
    else
    {
        LoginViewController *VC = [[LoginViewController alloc]init];
        //AddCarViewController *VC = [[AddCarViewController alloc]init];
        [self presentViewController:VC animated:YES completion:nil];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    gesturePasswordView.hidden = YES;
    NSArray *ary = [self wertherInfo:@"广州"];
    wearthIV.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[ary objectAtIndex:1]]];
    tempLab.text = [NSString stringWithFormat:@"%@°C",[ary objectAtIndex:2]];
    if ([[ary objectAtIndex:1] isEqualToString:@"晴"]) {
        wertherLab.text = @"适宜洗车";
    }
    else
    {
        wertherLab.text = @"不宜洗车";
    }
    [self stateView:hostView frame:CGRectMake(120, 440, 15, 5) stateStr:@"主机状态"];
    [self stateView:contentView frame:CGRectMake(120, 460, 15, 5) stateStr:@"通信状态"];
    loginLab = [[UILabel alloc]initWithFrame:CGRectMake(30, 30, 60, 40)];
    loginLab.text = @"请登录";
    loginLab.font = [UIFont systemFontOfSize:17];
    loginLab.textAlignment = NSTextAlignmentCenter;
    loginLab.textColor = [UIColor whiteColor];
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    loginLab.hidden = delegate.isLogin;
    [self.view addSubview:loginLab];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 绘图
//绘制不规则按钮
-(void)drawObshapedButton:(CGRect)frame tag:(int)tag image:(NSString*)imageName
{
    OBShapedButton *obshapeButton = [OBShapedButton buttonWithType:UIButtonTypeRoundedRect];
    obshapeButton.frame = frame;
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *imageBtn = [image stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [obshapeButton setBackgroundImage:imageBtn forState:UIControlStateNormal];//定义背景图片
    obshapeButton.tag = tag;
    obshapeButton.backgroundColor = [UIColor clearColor];
    [obshapeButton addTarget:self action:@selector(obsapedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:obshapeButton];
}

//不规则按钮响应事件
-(void)obsapedButtonAction:(id)sender
{
    if ([self isNetWork]) {
        OBShapedButton *button = (OBShapedButton*)sender;
        switch (button.tag) {
            case 1000:
            {
                //导航
                UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"选择系统已安装的地图应用" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"高德地图",@"百度地图",@"腾讯地图", nil];
                [sheet showInView:self.view];
            }
                break;
            case 1001:
            {
                //工具类选择
                AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
                if(delegate.isLogin)
                {
                    [self toolButton];

                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您尚未登录，请登录后使用该功能" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                    return;
                }
            }
                break;
            case 1002:
            {
                //车生活
                
            }
                break;
            case 1003:
            {
                //新闻
                //NewsViewController *VC = [[NewsViewController alloc]init];
               // [self presentViewController:VC animated:YES completion:nil];
                
            }
                break;
            case 1004:
            {
                //天气
                //NSArray *ary = [self wertherInfo:@"花都"];
               /// wearthIV.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[ary objectAtIndex:1]]];
               // tempLab.text = [NSString stringWithFormat:@"%@°C",[ary objectAtIndex:2]];
               // if ([[ary objectAtIndex:1] isEqualToString:@"晴"]) {
               //     wertherLab.text = @"适宜洗车";
              //  }
              //  else
              //  {
                //    wertherLab.text = @"不宜洗车";
              //  }
                
            }
                break;
        default:
                break;
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"警告" message:@"当前无网络连接，请检查网络后重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
}

#pragma mark 弹出视窗

//选择手机已安装的地图应用
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        BOOL blCanOpenUrl = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]];
        if (blCanOpenUrl)
        {
             [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"iosamap://"]];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"警告" message:@"当前手机没有安装高德地图，请安装后使用本功能" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    if (buttonIndex == 1) {
        BOOL blCanOpenUrl = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://map/"]];
        if (blCanOpenUrl)
        {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"baidumap://map/"]];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"警告" message:@"当前手机没有安装百度地图，请安装后使用本功能" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    if (buttonIndex == 2) {
        BOOL blCanOpenUrl = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]];
        if (blCanOpenUrl)
        {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"qqmap://"]];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"警告" message:@"当前手机没有安装腾讯地图，请安装后使用本功能" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}
-(void)showMenu
{
    if (!self.activityView) {
        self.activityView = [[HYActivityView alloc]initWithTitle:@"选择开启" referView:self.view];
        ButtonView *bv = [[ButtonView alloc]initWithText:@"A类产品" image:[UIImage imageNamed:@"atype@2x.png"] handler:^(ButtonView *buttonView){
            [self saveDicInfo:@"A" key:@"type" saveName:@"typeOfTool"];
            [self saveDicInfo:@"YES" key:@"tool" saveName:@"fristTool"];
        }];
        [self.activityView addButtonView:bv];
        
        bv = [[ButtonView alloc]initWithText:@"B类产品" image:[UIImage imageNamed:@"btype@2x.png"] handler:^(ButtonView *buttonView){
            [self saveDicInfo:@"B" key:@"type" saveName:@"typeOfTool"];
            [self saveDicInfo:@"YES" key:@"tool" saveName:@"fristTool"];
        }];
        [self.activityView addButtonView:bv];
        
        bv = [[ButtonView alloc]initWithText:@"C类产品" image:[UIImage imageNamed:@"ctype@2x.png"] handler:^(ButtonView *buttonView){
            [self saveDicInfo:@"C" key:@"type" saveName:@"typeOfTool"];
            [self saveDicInfo:@"YES" key:@"tool" saveName:@"fristTool"];
        }];
        [self.activityView addButtonView:bv];
        
        bv = [[ButtonView alloc]initWithText:@"D类产品" image:[UIImage imageNamed:@"dtype@2x.png"] handler:^(ButtonView *buttonView){
            [self saveDicInfo:@"D" key:@"type" saveName:@"typeOfTool"];
            [self saveDicInfo:@"YES" key:@"tool" saveName:@"fristTool"];
        }];
        [self.activityView addButtonView:bv];
    }
    [self.activityView show];
}
-(void)toolButton
{
    NSDictionary *toolDic = [UserDefaults readUserDefaults:@"fristTool"];
    if (toolDic == nil) {
        
        [self showMenu];
    }
    else
    {
        previousString = [NSString string];
        KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
        password = [keychin objectForKey:(__bridge id)kSecValueData];
        NSLog(@"%@",password);
        NSDictionary *setPass = [UserDefaults readUserDefaults:@"setPass"];
        if (setPass == nil) {
            if ([self exist]) {
                [self clear];
            }
            [self reset];
        }
        else
        {
           [self verify];
        }
    }
}
//保存本地配置
-(void)saveDicInfo:(NSString*)object key:(NSString*)key saveName:(NSString*)name
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:object, nil]forKeys:[NSArray arrayWithObjects:key, nil]];
    [UserDefaults saveUserDefaults:dic :name];
}

//旋转动画
-(void)rotationView:(UIImageView*)imageView
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotationAnimation.duration = 5;
    rotationAnimation.repeatCount = powl(100, 1000);//你可以设置到最大的整数值
    rotationAnimation.cumulative = NO;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    [imageView.layer addAnimation:rotationAnimation forKey:@"Rotation"];
}

//定位lab
-(void)addressLabel:(UILabel*)label frame:(CGRect)frame numberOfLine:(BOOL)number sizeOfFont:(CGFloat)size color:(UIColor*)color
{
    label.frame = frame;
    label.font = [UIFont systemFontOfSize:size];
    label.textColor = color;
    if (number) {
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
    }
    [self.view addSubview:label];
}

//状态灯
-(void)stateView:(UIView*)stateView frame:(CGRect)frame stateStr:(NSString*)string
{
    stateView.frame = frame;
    stateView.backgroundColor = [UIColor colorWithRed:0.223f green:0.667f blue:0.863f alpha:1.0f];
    stateView.layer.borderWidth = 1.0f;
    stateView.layer.borderColor = [UIColor clearColor].CGColor;
    stateView.layer.cornerRadius = 2.0f;
    [self.view addSubview:stateView];
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x+20, frame.origin.y-8, 40, 20)];
    lab.text = string;
    lab.textColor = [UIColor colorWithRed:0.6078 green:0.6039 blue:0.5882 alpha:1.0f];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.font = [UIFont systemFontOfSize:10.0f];
    [self.view addSubview:lab];
}

#pragma mark 天气
-(NSArray*)wertherInfo:(NSString*)cityName
{
    NSString *sqlFile = @"cityname.sqlite";
    NSArray *cachePath= NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDir = [cachePath objectAtIndex:0];
    NSString *databasePath = [cacheDir stringByAppendingPathComponent:sqlFile];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:databasePath]) {
        NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:sqlFile];
        NSError *error;
        [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:&error];
        
    }
    if(sqlite3_open([databasePath cStringUsingEncoding:NSASCIIStringEncoding], &database)==SQLITE_OK)
    {
    }
    else
    {
    }
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT city_num FROM citys where name=\'%@\'",cityName];
    sqlite3_stmt * statement;
    NSString *cityNumStr;
    if (sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *cityNum = (char*)sqlite3_column_text(statement, 0);
            cityNumStr = [[NSString alloc]initWithUTF8String:cityNum];
        }
    }
    sqlite3_close(database);
    
    NSString *wearthStringUrl = [NSString stringWithFormat:@"http://cdn.weather.hao.360.cn/api_weather_info.php?app=hao360&code=%@",cityNumStr];
    NSURL *wearthUrl = [NSURL URLWithString:wearthStringUrl];
    NSString *weartherString = [NSString stringWithContentsOfURL:wearthUrl encoding:NSUTF8StringEncoding error:nil];
    NSString *weartherJson0 = [weartherString substringFromIndex:10];
    NSString *weartherJson = [weartherJson0 substringToIndex:weartherJson0.length-2];
    
    NSData *weartherData = [weartherJson dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *weartherDic = [NSJSONSerialization JSONObjectWithData:weartherData options:NSJSONReadingMutableContainers error:nil];
    NSArray *weather = [weartherDic objectForKey:@"weather"];
    NSDictionary *todayDic = [weather objectAtIndex:0];
    NSDictionary *info = [todayDic objectForKey:@"info"];
    NSArray *day = [info objectForKey:@"day"];
    return day;
}

#pragma mark 逆地理编码
-(void)reGeocoding:(CGFloat)lat lon:(CGFloat)lon
{
    _search = [[AMapSearchAPI alloc] initWithSearchKey:@"d4713afc15d2a328b4242f24011dfdc8" Delegate:self];
    
    AMapReGeocodeSearchRequest *regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
    regeoRequest.searchType = AMapSearchType_ReGeocode;
    regeoRequest.location = [AMapGeoPoint locationWithLatitude:lat longitude:lon];
    regeoRequest.radius = 10000;
    regeoRequest.requireExtension = YES;
    
    //发起逆地理编码
    [_search AMapReGoecodeSearch: regeoRequest];
}

//实现逆地理编码的回调函数
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if(response.regeocode != nil)
    {
        //通过AMapReGeocodeSearchResponse对象处理搜索结果
        NSString *result = [NSString stringWithFormat:@"ReGeocode: %@", response.regeocode];
        
        int i = 0;
        int j = 0;
        int k = 0;
        int mark = 0;
        while (mark == 0) {
                NSString *str1 = [result substringWithRange:NSMakeRange(i, 8)];
                if ([str1 isEqualToString:@"address:"]) {
                    j = i + 9;
                }
                NSString *str2 = [result substringWithRange:NSMakeRange(i, 18)];
                if ([str2 isEqualToString:@", addressComponent"]) {
                    k = i - 1;
                    mark = 1;
                }
            i++;
        }
        addressLab.text = [result substringWithRange:NSMakeRange(j, k-j+1)];
    }
}
#pragma mark 判断网络
-(BOOL)isNetWork
{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    BOOL isNet = YES;
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            // 没有网络连接
            isNet = NO;
            break;
        case ReachableViaWWAN:
            // 使用3G网络
            break;
        case ReachableViaWiFi:
            // 使用WiFi网络
            break;
    }
    return isNet;
}

#pragma mark - 验证手势密码
- (void)verify{
    gesturePasswordView = [[GesturePasswordView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    gesturePasswordView.imgView.image = [self getEllipseImageWithImage:[UIImage imageNamed:@"80.png"]];
    [gesturePasswordView.tentacleView setRerificationDelegate:self];
    [gesturePasswordView.tentacleView setStyle:1];
    [gesturePasswordView setGesturePasswordDelegate:self];
    [self.view addSubview:gesturePasswordView];
}

#pragma mark - 重置手势密码
- (void)reset{
    gesturePasswordView = [[GesturePasswordView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [gesturePasswordView.tentacleView setResetDelegate:self];
    [gesturePasswordView.tentacleView setStyle:2];
    gesturePasswordView.imgView.image = [self getEllipseImageWithImage:[UIImage imageNamed:@"80.png"]];
    [gesturePasswordView.forgetButton setHidden:YES];
    [gesturePasswordView.changeButton setHidden:YES];
    [self.view addSubview:gesturePasswordView];
}

#pragma mark - 判断是否已存在手势密码
- (BOOL)exist{
    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
    password = [keychin objectForKey:(__bridge id)kSecValueData];
    if ([password isEqualToString:@""])return NO;
    return YES;
}

#pragma mark - 清空记录
- (void)clear{
    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
    [keychin resetKeychainItem];
}

#pragma mark - 改变手势密码
- (void)change{
    //[self.view willRemoveSubview:gesturePasswordView];
}

#pragma mark - 忘记手势密码
- (void)forget{
    
}

- (BOOL)verification:(NSString *)result{
    if ([result isEqualToString:password]) {
        [gesturePasswordView.state setTextColor:[UIColor colorWithRed:2/255.f green:174/255.f blue:240/255.f alpha:1]];
        [gesturePasswordView.state setText:@"输入正确"];
        //[self presentViewController:(UIViewController) animated:YES completion:nil];
        gesturePasswordView.hidden = YES;
        NSDictionary *typeDic = [UserDefaults readUserDefaults:@"typeOfTool"];
        NSString *type = [typeDic objectForKey:@"type"];
        if ([type isEqualToString:@"A"]) {
            TrackViewController *vc = [[TrackViewController alloc]init];
            [self presentViewController:vc animated:YES completion:nil];
        }
        
        if ([type isEqualToString:@"B"]) {
            
        }
        if ([type isEqualToString:@"C"]) {
            
        }
        if ([type isEqualToString:@"D"]) {
            ControlViewController *vc = [[ControlViewController alloc]init];
            vc.scoket = scoket;
            [self presentViewController:vc animated:YES completion:nil];
        }
        return YES;
    }
    [gesturePasswordView.state setTextColor:[UIColor redColor]];
    [gesturePasswordView.state setText:@"手势密码错误"];
    return NO;
}

- (BOOL)resetPassword:(NSString *)result{
    if ([previousString isEqualToString:@""]) {
        previousString=result;
        [gesturePasswordView.tentacleView enterArgin];
        [gesturePasswordView.state setTextColor:[UIColor colorWithRed:2/255.f green:174/255.f blue:240/255.f alpha:1]];
        [gesturePasswordView.state setText:@"请验证输入密码"];
        return YES;
    }
    else {
        if ([result isEqualToString:previousString]) {
            KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
            [keychin setObject:@"<帐号>" forKey:(__bridge id)kSecAttrAccount];
            [keychin setObject:result forKey:(__bridge id)kSecValueData];
            //[self presentViewController:(UIViewController) animated:YES completion:nil];
            [gesturePasswordView.state setTextColor:[UIColor colorWithRed:2/255.f green:174/255.f blue:240/255.f alpha:1]];
            [gesturePasswordView.state setText:@"已保存手势密码"];
            gesturePasswordView.hidden = YES;
            [self saveDicInfo:@"YES" key:@"pass" saveName:@"setPass"];
            return YES;
        }
        else{
            previousString =@"";
            [gesturePasswordView.state setTextColor:[UIColor redColor]];
            [gesturePasswordView.state setText:@"两次密码不一致，请重新输入"];
            return NO;
        }
    }
}

#pragma mark 头像
//将头像变成圆形
-(UIImage*)getEllipseImageWithImage:(UIImage*)originImage
{
    CGFloat padding = 0;//圆形图像距离图像的边距
    UIColor* epsBackColor = [UIColor clearColor];//图像的背景色
    CGSize originsize = originImage.size;
    CGRect originRect = CGRectMake(0, 0, originsize.width, originsize.height);
    UIGraphicsBeginImageContext(originsize);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //目标区域。
    CGRect desRect =  CGRectMake(padding, padding,originsize.width-(padding*2), originsize.height-(padding*2));
    //设置填充背景色。
    CGContextSetFillColorWithColor(ctx, epsBackColor.CGColor);
    //可以替换为 [epsBackColor setFill];
    UIRectFill(originRect);//真正的填充
    //设置椭圆变形区域。
    CGContextAddEllipseInRect(ctx,desRect);
    CGContextClip(ctx);//截取椭圆区域。
    [originImage drawInRect:originRect];//将图像画在目标区域。
    // 边框 //
    CGFloat borderWidth = 5;
    CGContextSetStrokeColorWithColor(ctx, [UIColor clearColor].CGColor);//设置边框颜色
    //可以替换为 [[UIColor whiteColor] setFill];
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGContextSetLineWidth(ctx, borderWidth);//设置边框宽度。
    CGContextAddEllipseInRect(ctx, desRect);//在这个框中画圆
    CGContextStrokePath(ctx); // 描边框。
    // 边框 //
    UIImage* desImage = UIGraphicsGetImageFromCurrentImageContext();// 获取当前图形上下文中的图像。
    UIGraphicsEndImageContext();
    return desImage;
}

#pragma mark Scoket通信

//初始化scoket
-(void)connect{
    IPAddress = @"202.116.48.86";
    port = @"8233";
    scoket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *err = nil;
    if(![scoket connectToHost:IPAddress onPort:[port intValue] error:&err])
    {
        
    }
    else
    {
        [scoket connectToHost:IPAddress onPort:[port intValue] error:&err];
    }
}

//连接服务器成功
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [scoket readDataWithTimeout:-1 tag:0];
    [self Recicer];
}

//断开服务器
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    [self connect];
}

//发送连接指令
-(void)Recicer{
    [self carCommand:@"PL" control:nil length:18];
}

//控制指令
-(void)carCommand:(NSString*)type control:(NSString*)controlStr length:(int)length
{
    Byte byte[length];
    byte[0] = 0x32;
    byte[1] = 0x32;
    byte[2] = 0x32;
    byte[3] = 0x32;
    //5~6位为控制类型
    for (int i = 0; i < 2; i++) {
        char typeChar = [type characterAtIndex:i];
        byte[4+i] = (int)typeChar;
    }
    if (controlStr != nil) {
        NSString *controlTy = [controlStr substringToIndex:controlStr.length-2];
        NSString *controlTi = [controlStr substringFromIndex:controlStr.length-2];
        byte[6] = controlTy.intValue;
        byte[7] = controlTi.intValue;
    }
    //时间戳的生成
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *now;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    now=[NSDate date];
    comps = [calendar components:unitFlags fromDate:now];
    NSInteger h = [comps hour];
    NSInteger m = [comps minute];
    NSInteger s = [comps second];
    NSString *hStr;
    NSString *mStr;
    NSString *sStr;
    hStr = [NSString stringWithFormat:@"%ld",(long)h];
    mStr = [NSString stringWithFormat:@"%ld",(long)m];
    sStr = [NSString stringWithFormat:@"%ld",(long)s];
    if (h < 10) {
        hStr = [NSString stringWithFormat:@"0%ld",(long)h];
    }
    if (m < 10) {
        mStr = [NSString stringWithFormat:@"0%ld",(long)m];
    }
    if (s < 10) {
        sStr = [NSString stringWithFormat:@"0%ld",(long)s];
    }
    NSString *timeStr = [NSString stringWithFormat:@"%@%@%@000",hStr,mStr,sStr];
    for (int i = 0; i < 9; i++)
    {
        char timeType = [timeStr characterAtIndex:i];
        byte[length-12+i] = (int)timeType;
    }
    byte[length-3] = 0x55;
    byte[length-2] = 0x00;
    byte[length-1] = 0x00;
    NSData *msgdata = [NSData dataWithBytes:byte length:length];
    [self sendMsg:msgdata];
}

//发送指令
-(void)sendMsg:(NSData*)data
{
    [scoket writeData:data withTimeout:-1 tag:0];
    [scoket readDataWithTimeout:-1 tag:0];
}

//接收数据函数
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"msg=%@",message);
    [self doMsg:message];
    [scoket readDataWithTimeout:-1 tag:0];
}

//处理scoket接受到的数据
-(void)doMsg:(NSString*)message
{
    if (message != nil)
    {
        double msgTag = -1;
        NSString *tagString;
        while (message.length > 5)
        {
            NSString *tag = [message substringWithRange:NSMakeRange(5, 1)];
            if ([tag isEqualToString:@"M"])
            {
                NSString *str = [message substringWithRange:NSMakeRange(0, 25)];
                message = [message substringFromIndex:25];
                char charTag1 = [str characterAtIndex:23];
                char charTag2 = [str characterAtIndex:24];
                double tagNum;
                tagNum = (int)charTag1*1000+(int)charTag2;
                if (tagNum > msgTag) {
                    if (tagNum == 255*1000+255) {
                        tagNum = -1;
                    }
                    msgTag = tagNum;
                    tagString = str;
                }
            }
            if ([tag isEqualToString:@"G"]) {
                NSString *latInteger = [message substringWithRange:NSMakeRange(7, 2)];
                NSString *latDecimal = [message substringWithRange:NSMakeRange(9, 7)];
                NSString *latStr = [NSString stringWithFormat:@"%f",latInteger.intValue+latDecimal.floatValue/60];
                if (![[message substringWithRange:NSMakeRange(16, 1)]isEqualToString:@"N"]) {
                    latStr = [NSString stringWithFormat:@"-%@",latStr];
                }
                NSString *lonInteger = [message substringWithRange:NSMakeRange(17, 3)];
                NSString *lonDecimal = [message substringWithRange:NSMakeRange(20, 7)];
                NSString *lonStr = [NSString stringWithFormat:@"%f",lonInteger.intValue+lonDecimal.floatValue/60];
                if (![[message substringWithRange:NSMakeRange(27, 1)]isEqualToString:@"E"]) {
                    latStr = [NSString stringWithFormat:@"-%@",latStr];
                }
                if ([self LantitudeLongitudeDist:lonStr.floatValue other_Lat:latStr.floatValue self_Lon:lastlon self_Lat:lastLat] > 200) {
                    int TenLat=0;
                    int TenLog=0;
                    TenLat = (int)(latStr.floatValue*10);
                    TenLog = (int)(lonStr.floatValue*10);
                    NSString *sql = [[NSString alloc]initWithFormat:@"select offLat,offLog from gpsT where lat=%d and log = %d",TenLat,TenLog];
                    sqlite3_stmt* stmtL = [m_sqlite NSRunSql:sql];
                    int offLat=0;
                    int offLog=0;
                    while (sqlite3_step(stmtL)==SQLITE_ROW)
                    {
                        offLat = sqlite3_column_int(stmtL, 0);
                        offLog = sqlite3_column_int(stmtL, 1);
                    }
                    float latitude = latStr.floatValue+offLat*0.0001;
                    float longitude = lonStr.floatValue + offLog*0.0001;
                    GpsPoint *gpsPoint = [GpsPoint gpsPointInstance];
                    gpsPoint.longitude = longitude;
                    gpsPoint.latitude = latitude;
                    lastLat = latitude;
                    lastlon = longitude;
                    NSString *latStr = [NSString stringWithFormat:@"%f",latitude];
                    NSString *lonStr = [NSString stringWithFormat:@"%f",longitude];
                    NSDictionary *dicGps = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:latStr,lonStr, nil]forKeys:[NSArray arrayWithObjects:@"lat",@"lon", nil]];
                    [UserDefaults saveUserDefaults:dicGps :@"lastGps"];
                    NSString *moveFlag = [message substringWithRange:NSMakeRange(40, 1)];
                    if ([moveFlag isEqualToString:@"0"]&&(moveState == NO)) {
                        [self reGeocoding:latitude lon:longitude];
                        moveState = YES;
                    }
                    if ([moveFlag isEqualToString:@"1"]) {
                        moveState = NO;
                    }
                }
                message = [message substringFromIndex:49];
            }
            if ([tag isEqualToString:@"T"]) {
                message = [message substringFromIndex:11];
            }
            if ([tag isEqualToString:@"R"]) {
                ControlReslut *controlReslut = [ControlReslut controlReslutInstance];
                controlReslut.type = 1;
                message = [message substringFromIndex:20];
            }
            if ([tag isEqualToString:@"E"]) {
                //设置成功
                message = [message substringFromIndex:15];
            }
            if ([tag isEqualToString:@"L"]) {
                message = [message substringFromIndex:18];
            }
            else
            {
                break;
            }
        }
        if (tagString != nil) {
            CarState *carState = [CarState instance];
            carState.stateString = tagString;
        }
    }
}

//计算两点之间的距离
-(double) LantitudeLongitudeDist:(double)lon1 other_Lat:(double)lat1 self_Lon:(double)lon2 self_Lat:(double)lat2{
    double er = 6378137;
    double radlat1 = M_PI*lat1/180.0f;
    double radlat2 = M_PI*lat2/180.0f;
    //now long.
    double radlong1 = M_PI*lon1/180.0f;
    double radlong2 = M_PI*lon2/180.0f;
    if( radlat1 < 0 ) radlat1 = M_PI/2 + fabs(radlat1);// south
    if( radlat1 > 0 ) radlat1 = M_PI/2 - fabs(radlat1);// north
    if( radlong1 < 0 ) radlong1 = M_PI*2 - fabs(radlong1);//west
    if( radlat2 < 0 ) radlat2 = M_PI/2 + fabs(radlat2);// south
    if( radlat2 > 0 ) radlat2 = M_PI/2 - fabs(radlat2);// north
    if( radlong2 < 0 ) radlong2 = M_PI*2 - fabs(radlong2);// west
    //spherical coordinates x=r*cos(ag)sin(at), y=r*sin(ag)*sin(at), z=r*cos(at)
    //zero ag is up so reverse lat
    double x1 = er * cos(radlong1) * sin(radlat1);
    double y1 = er * sin(radlong1) * sin(radlat1);
    double z1 = er * cos(radlat1);
    double x2 = er * cos(radlong2) * sin(radlat2);
    double y2 = er * sin(radlong2) * sin(radlat2);
    double z2 = er * cos(radlat2);
    double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
    //side, side, side, law of cosines and arccos
    double theta = acos((er*er+er*er-d*d)/(2*er*er));
    double dist  = theta*er;
    return dist;
}

@end
