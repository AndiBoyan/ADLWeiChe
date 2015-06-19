//
//  AppDelegate.m
//  ADLWeiChe
//
//  Created by icePhoenix on 15/6/3.
//  Copyright (c) 2015年 aodelin. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "CoreNewFeatureVC.h"
#import "CALayer+Transition.h"
#import "UserDefaults.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize isLogin;
@synthesize isLoginOff;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.isLoginOff = NO;
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
   
    //定义引导页
    BOOL isFristUserApp = NO;//判断程序是否首次使用
    NSDictionary *dic = [UserDefaults readUserDefaults:@"fristUseApp"];
    if (dic == nil) {
        isFristUserApp = YES;
    }
    if (isFristUserApp) {
        
        NewFeatureModel *m1 = [NewFeatureModel model:[UIImage imageNamed:@"f1.jpg"]];
        
        NewFeatureModel *m2 = [NewFeatureModel model:[UIImage imageNamed:@"f2.jpg"]];
        
        NewFeatureModel *m3 = [NewFeatureModel model:[UIImage imageNamed:@"f3.jpg"]];
        
        self.window.rootViewController = [CoreNewFeatureVC newFeatureVCWithModels:@[m1,m2,m3] enterBlock:^{
            
        [self enter];
            
        }];
    }
    else
    {
        [self enter];
    }
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)enter
{
    ViewController *vc = [[ViewController alloc] init];
    self.window.rootViewController = vc;
    [self.window.layer transitionWithAnimType:TransitionAnimTypeRamdom subType:TransitionSubtypesFromRamdom curve:TransitionCurveRamdom duration:2.0f];
    NSDictionary *used = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"YES", nil]forKeys:[NSArray arrayWithObjects:@"used", nil]];
    [UserDefaults saveUserDefaults:used :@"fristUseApp"];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
