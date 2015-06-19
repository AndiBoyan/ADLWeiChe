//
//  ViewController.h
//  ADLWeiChe
//
//  Created by icePhoenix on 15/6/3.
//  Copyright (c) 2015年 aodelin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TentacleView.h"
#import "GesturePasswordView.h"
#import "GCDAsyncSocket.h"

@interface ViewController : UIViewController<VerificationDelegate,ResetDelegate,GesturePasswordDelegate>
{
    UIView *toolView;
    
    GCDAsyncSocket *scoket;//定义TCPIP通信Scoket
    NSString *IPAddress;//主机IP地址以及端口
    NSString *port;
    
    //提醒设置
    BOOL typeOfTemp;
    BOOL typeOfOil;
    
    NSTimer *connectTime;
    
    //记录上一次的经纬度数据
    float lastLat;
    float lastlon;
}

- (void)clear;

- (BOOL)exist;

@end

