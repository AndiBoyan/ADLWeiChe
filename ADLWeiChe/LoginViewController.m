//
//  LoginViewController.m
//  ADLWeiChe
//
//  Created by icePhoenix on 15/6/3.
//  Copyright (c) 2015年 aodelin. All rights reserved.
//

#import "LoginViewController.h"
#import "ViewController.h"
#import "OBShapedButton.h"
#import "AddNewUserViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    UIImageView *backgroundIV = [[UIImageView alloc]initWithFrame:self.view.frame];
    backgroundIV.image = [UIImage imageNamed:@"loginViewControllerBG@3x.png"];
    //[self.view addSubview:backgroundIV];
    self.isAutoLogin = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"%@",[self nowHour]);
}
-(void)viewDidAppear:(BOOL)animated
{
    if (self.isAutoLogin) {
        ViewController *vc= [[ViewController alloc]init];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else
    {
        self.view.backgroundColor = [UIColor whiteColor];
        //添加背景图片
        UIImageView *backgroundImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        backgroundImage.image = [UIImage imageNamed:@"loginViewControllerBG@3x"];
        [self.view addSubview:backgroundImage];
        
       float w = self.view.frame.size.width;
        NSLog(@"%f",w);
        userNameField = [self fieldWithFrame:CGRectMake((w-200)/2, 180, 200, 35) isSecureTextEntry:NO placeholder:@"手机号码" tag:1000];
        userPassField = [self fieldWithFrame:CGRectMake((w-200)/2, 230, 200, 35) isSecureTextEntry:YES placeholder:@"密码" tag:1001];
        [self.view addSubview:userNameField];
        [self.view addSubview:userPassField];
        
        [self checkButton:CGRectMake((w-200)/2, 280, 20, 20) isSelect:YES checkBtnTag:1002 labWithText:@"记住密码"];
        [self checkButton:CGRectMake(125+(w-200)/2, 280, 20, 20) isSelect:YES checkBtnTag:1003 labWithText:@"使用手势"];
        
        [self drawObshapedButton:CGRectMake(w/2-62.5, 320, 125, 35) tag:1005 image:@"loginViewControllerloginBtn@3x.png"];
        [self label:CGRectMake(20, 380, 100, 20) text:@"新用户注册"];
        [self label:CGRectMake(self.view.frame.size.width - 160, 380, 100, 20) text:@"忘记密码？"];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 用户输入框
//用户名输入框以及密码输入框
-(UITextField*)fieldWithFrame:(CGRect)frame isSecureTextEntry:(BOOL)isSecureTextEntry placeholder:(NSString*)placeholder tag:(int)tag
{
    UITextField *field = [[UITextField alloc]initWithFrame:frame];
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.font = [UIFont systemFontOfSize:13.0f];
    field.placeholder = placeholder;
    field.secureTextEntry = isSecureTextEntry;
    field.returnKeyType = UIReturnKeyDone;
    field.tag = tag;
    return field;
}

#pragma mark 复选框
//复选框实现记住密码+自动登录
-(void)checkButton:(CGRect)frame isSelect:(BOOL)isSelect checkBtnTag:(int)tag labWithText:(NSString*)string
{
    UIButton *checkbox=[[UIButton alloc]initWithFrame:CGRectZero];
    [self.view addSubview:checkbox];
    checkbox.frame=frame;
    [checkbox setImage:[UIImage imageNamed:@"check_off.png"]forState:UIControlStateNormal];
    //设置正常时图片为    check_off.png
    [checkbox setImage:[UIImage imageNamed:@"check_on.png"]forState:UIControlStateSelected];
    //设置点击选中状态图片为check_on.png
    [checkbox addTarget:self action:@selector(checkboxClick:)forControlEvents:UIControlEventTouchUpInside];
    checkbox.selected = isSelect;
    checkbox.tag = tag;
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x+20, frame.origin.y, 80, 20)];
    [self.view addSubview:lab];
    lab.text = string;
    lab.font = [UIFont systemFontOfSize:12.0f];
    
}

//实现checkboxClick方法
-(void)checkboxClick:(UIButton*)btn{
    btn.selected=!btn.selected;//每次点击都改变按钮的状态
    if(btn.selected){
         //在此实现打勾时的方法
        if (btn.tag == 1002) {
            NSLog(@"记住密码");
        }
        if (btn.tag == 1003) {
            NSLog(@"自动登录");
        }
        
    }else{
       //在此实现不打勾时的方法
        if (btn.tag == 1002) {
            NSLog(@"记住密码");
        }
        if (btn.tag == 1003) {
            NSLog(@"自动登录");
        }
    }
}

#pragma mark button
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
    OBShapedButton *button = (OBShapedButton*)sender;
    switch (button.tag) {
        case 1005:
        {
            //登录
            userName = userNameField.text;
            userPass = userPassField.text;
            if ((userName.length <= 0)||(userPass.length <= 0)) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"警告" message:@"您填写的用户名或者密码为空，请完善用户信息" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            //登录API
            /*********************************************************************/
            if (![userName isEqualToString:@"abc"]||![userPass isEqualToString:@"123"]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"警告" message:@"用户名或者密码错误，请检查后重新输入" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                userNameField.text = @"";
                userPassField.text = @"";
                return;
            }
            else
            {
                //登录成功
                ViewController *VC = [[ViewController alloc]init];
                [self presentViewController:VC animated:YES completion:nil];
            }
            
        }
            break;
        default:
            break;
    }
}

//用户登录判定
-(NSString*)isUserLogin:(NSString*)userName loginPass:(NSString*)userPass
{
    return @"1000";
}

#pragma mark textFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}
//判断时间
-(NSString*)nowHour
{
    NSDate *date = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitHour fromDate:date];
    if (([components hour]>=0)&&([components hour]<6)) {
        return @"凌晨好";
    }
    if (([components hour]>=6)&&([components hour]<9)) {
        return @"早上好";
    }
    if (([components hour]>=9)&&([components hour]<12)) {
        return @"上午好";
    }
    if (([components hour]>=12)&&([components hour]<14)) {
        return @"中午好";
    }
    if (([components hour]>=14)&&([components hour]<18)) {
        return @"下午好";
    }
    if (([components hour]>=18)&&([components hour]<20)) {
        return @"傍晚好";
    }
    if (([components hour]>=20)&&([components hour]<22)) {
        return @"晚上好";
    }
    else
        return @"夜深了，注意休息";
}

-(void)label:(CGRect)frame text:(NSString*)string
{
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentRight;
    label.text = string;
    label.font = [UIFont systemFontOfSize:13.0f];
    [self.view addSubview:label];
    
    label.userInteractionEnabled = YES;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTouchUpInside:)];
     [label addGestureRecognizer:labelTapGestureRecognizer];
}
-(void) labelTouchUpInside:(UITapGestureRecognizer *)recognizer{
    
    UILabel *label=(UILabel*)recognizer.view;
    if ([label.text isEqualToString:@"新用户注册"]) {
        //用户注册
        AddNewUserViewController *VC = [[AddNewUserViewController alloc]init];
        [self presentViewController:VC animated:YES completion:nil];
    }
    else
    {
        //忘记密码
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([userNameField resignFirstResponder]) {
        [userPassField becomeFirstResponder];
    }
    else {
        [userPassField becomeFirstResponder];
    }
    return YES;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (![self.view isExclusiveTouch]) {
        [userNameField resignFirstResponder];
        [userPassField resignFirstResponder];
    }
}
@end
