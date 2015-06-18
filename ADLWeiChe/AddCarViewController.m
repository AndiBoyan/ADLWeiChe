//
//  AddCarViewController.m
//  ADLWeiChe
//
//  Created by icePhoenix on 15/6/12.
//  Copyright (c) 2015年 aodelin. All rights reserved.
//

#import "AddCarViewController.h"
#import "ViewController.h"

@interface AddCarViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) UITextField *deviceIDTextField;
@property (strong, nonatomic) UITextField *devicePassTextField;
@property (strong, nonatomic) UITextField *modelTextField;

@end

@implementation AddCarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *backgroundIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backgroundIV.image = [UIImage imageNamed:@"loginViewControllerBG@3x.png"];
    [self.view addSubview:backgroundIV];
    
    self.deviceIDTextField = [[UITextField alloc]initWithFrame:CGRectMake((self.view.frame.size.width-200)*1/2, 225, 200, 35)];
    self.deviceIDTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.deviceIDTextField.placeholder =@"设备ID";
    self.deviceIDTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.deviceIDTextField.returnKeyType = UIReturnKeyNext;
    self.deviceIDTextField.font = [UIFont systemFontOfSize:13.0f];
    self.deviceIDTextField.delegate = self;
    [self.view addSubview:self.deviceIDTextField];
    
    self.devicePassTextField = [[UITextField alloc]initWithFrame:CGRectMake((self.view.frame.size.width-200)*1/2, 270, 200, 35)];
    self.devicePassTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.devicePassTextField.secureTextEntry = YES;
    self.devicePassTextField.placeholder = @"设备密码";
    self.devicePassTextField.delegate = self;
    self.devicePassTextField.returnKeyType = UIReturnKeyDone;
    self.devicePassTextField.font = [UIFont systemFontOfSize:13.0f];
    [self.view addSubview:self.devicePassTextField];
    
    
    self.modelTextField = [[UITextField alloc]initWithFrame:CGRectMake((self.view.frame.size.width-200)*1/2, 180, 200, 35)];
    self.modelTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    self.modelTextField.font = [UIFont systemFontOfSize:13.0f];
    self.modelTextField.textColor = [UIColor blackColor];
    self.modelTextField.placeholder = @"车品牌";
    self.modelTextField.clearButtonMode = UITextFieldViewModeNever;
    self.modelTextField.secureTextEntry = NO;
    self.modelTextField.clearsOnBeginEditing = YES;
    self.modelTextField.textAlignment = NSTextAlignmentLeft;
    self.modelTextField.keyboardType = UIKeyboardTypeDefault;
    self.modelTextField.delegate = self;
    [self.view addSubview:self.modelTextField];
    
    CGRect frameOfNext  = CGRectMake(180, 325, 80, 35);
    UIButton *buttonOfNext = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    buttonOfNext.frame = frameOfNext;
    //下一步按钮
    UIImage *buttonImage = [UIImage imageNamed:@"bntsure@2x.png"];
    UIImage *stretchableButtonImage = [buttonImage  stretchableImageWithLeftCapWidth:12  topCapHeight:0];
    [buttonOfNext setBackgroundImage:stretchableButtonImage forState:UIControlStateNormal];
    [buttonOfNext addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonOfNext];
    
    //返回按钮
    CGRect frameOfBack = CGRectMake(60, 325, 80, 35);
    UIButton *buttonOfBack = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    buttonOfBack.frame = frameOfBack;
    UIImage *backImage = [UIImage imageNamed:@"bntsure@2x.png"];
    UIImage *stretchableButtonImage1 = [backImage  stretchableImageWithLeftCapWidth:12  topCapHeight:0];
    [buttonOfBack setBackgroundImage:stretchableButtonImage1 forState:UIControlStateNormal];
    [buttonOfBack addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonOfBack];

}
-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)done
{
    /**************************************************/
    //                  注册
    /**************************************************/
    ViewController *VC = [[ViewController alloc]init];
    [self presentViewController:VC animated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (![self.view isExclusiveTouch]) {
        [self.modelTextField resignFirstResponder];
        [self.deviceIDTextField resignFirstResponder];
        [self.devicePassTextField resignFirstResponder];
    }
}


@end
