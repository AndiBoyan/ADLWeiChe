//
//  CarPointViewController.m
//  ADLWeiChe
//
//  Created by icePhoenix on 15/6/4.
//  Copyright (c) 2015年 aodelin. All rights reserved.
//

#import "CarPointViewController.h"
#import "CustomAnnotation.h"
#import <math.h>
#import "GpsPoint.h"
#import "UserDefaults.h"

@interface CarPointViewController ()
{
    MAPointAnnotation *pointAnnotation;
}
@end

@implementation CarPointViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 65)];
    
    //创建一个导航栏集合
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:nil];
    
    [navigationItem setTitle:@"爱车位置"];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    //把导航栏集合添加入导航栏中，设置动画关闭
    navigationItem.leftBarButtonItem = leftButton;
    navigationBar.tintColor = [UIColor colorWithRed:0.584f green:0.584f blue:0.584f alpha:1.0f];
    [navigationBar pushNavigationItem:navigationItem animated:NO];
    
    [self.view addSubview:navigationBar];
    [MAMapServices sharedServices].apiKey = @"d4713afc15d2a328b4242f24011dfdc8";
    
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 65, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-65)];
    _mapView.delegate = self;
    [_mapView setZoomLevel:16.1 animated:YES];;
    
    [self.view addSubview:_mapView];

}
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        MAAnnotationView *annotationView = (MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        
        if (annotationView == nil)
        {
            
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:reuseIndetifier];
        }
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:@"mucar.png"];
        annotationView.draggable = YES;
        return annotationView;
    }
    return nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    gpsTime = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(gpsPoint) userInfo:nil repeats:YES];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [gpsTime setFireDate:[NSDate distantFuture]];
}

-(void)gpsPoint
{
    [_mapView removeAnnotation:pointAnnotation];
    self.lat = [GpsPoint gpsPointInstance].latitude;
    self.lon = [GpsPoint gpsPointInstance].longitude;
    pointAnnotation = [[MAPointAnnotation alloc] init];
    if ((self.lat == 0) && (self.lon == 0)) {
        NSDictionary *dic = [UserDefaults readUserDefaults:@"lastGps"];
        if (dic != nil) {
            NSString *lat = [dic objectForKey:@"lat"];
            NSString *lon = [dic objectForKey:@"lon"];
            self.lat = lat.floatValue;
            self.lon = lon.floatValue;
        }
        else
        {
            self.lat = 23.398522;
            self.lon = 113.254947;
        }
    }
    NSLog(@"%f%f",self.lat,self.lon);
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(self.lat, self.lon);
    [_mapView setCenterCoordinate:pointAnnotation.coordinate animated:YES];
    pointAnnotation.title = @"我的爱车";
    [_mapView addAnnotation:pointAnnotation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
