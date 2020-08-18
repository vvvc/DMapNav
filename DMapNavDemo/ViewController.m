//
//  ViewController.m
//  DMapNavDemo
//
//  Created by NK on 2020/8/18.
//  Copyright © 2020 YAND. All rights reserved.
//

#import "ViewController.h"
#import "MapNavigationManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(50, 100, [UIScreen mainScreen].bounds.size.width - 100, 100);
    [btn setBackgroundColor:UIColor.systemGroupedBackgroundColor];
    [btn setTitle:@"经纬度导航" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(mapNavCoordinateAction:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:btn];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(50, 260, [UIScreen mainScreen].bounds.size.width - 100, 100);
    [button setBackgroundColor:UIColor.systemGroupedBackgroundColor];
    [button setTitle:@"地址导航" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(mapNavAdressAction:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
    
}

- (void)mapNavAdressAction:(UIButton *)button {
    //通过地址导航到目的地
    [MapNavigationManager showSheetWithCity:@"中国" start:@"我的位置" end:@"天津之眼"];
}

- (void)mapNavCoordinateAction:(UIButton *)button {
    //通过经纬度导航到目的地
    //WGS84坐标系    117.1801241851917,39.15287816623711
    //GCJ02坐标系    117.1864549441989,39.153950838325464
    //BD09坐标系    117.193044,39.159655
    CGFloat longitude = 117.1864549441989;//经度
    CGFloat latitude = 39.153950838325464;//纬度
    NSLog(@"驾车路线终点坐标====%f,%f",longitude,latitude);
    CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(latitude, longitude);//纬度，经度
    [MapNavigationManager showSheetWithCoordinate2D:coords];
}

@end
