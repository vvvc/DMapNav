//
//  MapNavigationManager.m
//  DMapNavDemo
//
//  Created by NK on 2020/8/18.
//  Copyright © 2018年 YAND. All rights reserved.
//

#import "MapNavigationManager.h"
#import "MoLocationManager.h"



typedef enum : NSUInteger {
    Apple = 0,
    Baidu,
    Google,
    Gaode,
    Tencent
} MapSelect;


static MapNavigationManager * MBManager = nil;

@interface MapNavigationManager ()<UIActionSheetDelegate>
{
    CGFloat longitude;//经度
    CGFloat latitude;//纬度

}

//@property (nonatomic, strong) NSString *longitude;
//@property (nonatomic, strong) NSString *latitude;


@property (strong, nonatomic) NSString * urlScheme;
@property (strong, nonatomic) NSString * appName;

@property (strong, nonatomic) NSString * start;
@property (strong, nonatomic) NSString * end;
@property (strong, nonatomic) NSString * city;

@property (assign, nonatomic) MapNavStyle style;

@property (assign, nonatomic) CLLocationCoordinate2D Coordinate2D;

@end

@implementation MapNavigationManager


+ (MapNavigationManager *)shardMBManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MBManager = [[MapNavigationManager alloc] init];
    });
    return MBManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //!!! 需要自己改，方便弹回来
        self.urlScheme = @"WKMapNavTest://";
        self.appName = @"WKMapNavTest";
    }
    return self;
}





- (void)showSheet {
    
    
    //只获取一次
    __block  BOOL isOnece = YES;
    [MoLocationManager getMoLocationWithSuccess:^(double lat, double lng){
        isOnece = NO;
        //只打印一次经纬度
        NSLog(@"lat lng (%6f, %6f)", lat, lng);
        longitude = lng;
        latitude = lat;
        if (!isOnece) {
            [MoLocationManager stop];
        }
    } Failure:^(NSError *error){
        isOnece = NO;
        NSLog(@"error = %@", error);
        if (!isOnece) {
            [MoLocationManager stop];
        }
    }];
    
    
    
    
    NSString * appleMap  = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com/"]] ? @"苹果地图" : nil;
    NSString * baiduMap  = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]] ? @"百度地图" : nil;
    NSString * gaodeMap  = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]] ? @"高德地图":nil;
    NSString * googleMap = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]] ? @"谷歌地图" :nil;//不能用，需翻墙
    NSString * tencentMap = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://map/"]] ? @"腾讯地图" : nil;//暂时不支持
    
    //UIAlertControllerStyleActionSheet
    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"请选择您已经安装的软件" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
  
    UIAlertAction *appleMapAction = [UIAlertAction actionWithTitle:appleMap style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSLog(@"%@",action);
        [self selectMapForTitle:action.title];
    }];
    [alertControl addAction:appleMapAction];
    if (baiduMap) {
        UIAlertAction *baiduMapAction = [UIAlertAction actionWithTitle:baiduMap style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            NSLog(@"%@",action);
            [self selectMapForTitle:action.title];
        }];
        [alertControl addAction:baiduMapAction];
    }
    if (gaodeMap) {
        UIAlertAction *gaodeMapAction = [UIAlertAction actionWithTitle:gaodeMap style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            NSLog(@"%@",action);
            [self selectMapForTitle:action.title];
        }];
        [alertControl addAction:gaodeMapAction];
    }
    if (googleMap) {
        UIAlertAction *googleMapAction = [UIAlertAction actionWithTitle:googleMap style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            NSLog(@"%@",action);
            [self selectMapForTitle:action.title];
        }];
        [alertControl addAction:googleMapAction];
    }
    if (tencentMap) {
        UIAlertAction *tencentMapAction = [UIAlertAction actionWithTitle:tencentMap style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            NSLog(@"%@",action);
            [self selectMapForTitle:action.title];
        }];
        [alertControl addAction:tencentMapAction];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        NSLog(@"%@",action);
    }];
    [alertControl addAction:cancelAction];//cancel
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertControl animated:YES completion:nil];
}

- (void)selectMapForTitle:(NSString *)str {
    //和枚举对应
    NSArray <NSString *> * mapArray = @[@"苹果地图",@"百度地图",@"谷歌地图",@"高德地图",@"腾讯地图"];
    NSUInteger i = 0 ;
    for (; i < mapArray.count; i ++) {
        if ([str isEqualToString:mapArray[i]]) {
            break;
        }
    }
    [self startNavigation:i];
}

- (void)startNavigation:(MapSelect)index {
    NSString * urlString = [self getUrlStr:index];
    if (urlString != nil) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    } else if(_style == Coordinates) {
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:self.Coordinate2D addressDictionary:nil]];
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
    }
}

- (NSString *)getUrlStr:(MapSelect)index
{
    NSString * urlStr = nil;
    if (index == Apple && _style == Coordinates) {
        return urlStr;
    }
    switch (_style) {
        case Coordinates:
            urlStr = [self getUrlStrWithCoordinates:index];
            break;
        case Address:
            urlStr = [self getUrlStrWithAddress:index];
            break;
        default:
            break;
    }
    return urlStr;
}

- (NSString *)getUrlStrWithCoordinates:(MapSelect)index
{
    NSString * urlString = nil;
    MapNavigationManager * mb = [MapNavigationManager shardMBManager];

    NSString * baiduUrlStr = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02",mb.Coordinate2D.latitude, mb.Coordinate2D.longitude] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString * goooleUrlStr = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving",_appName,_urlScheme,mb.Coordinate2D.latitude, mb.Coordinate2D.longitude] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString * gaodeUrlStr= [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&t=0",_appName,_urlScheme,mb.Coordinate2D.latitude, mb.Coordinate2D.longitude] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *qqUrlStr = [NSString stringWithFormat:@"qqmap://map/routeplan?type=drive&fromcoord=%6f,%6f&tocoord=%f,%f&referer=OB4BZ-D4W3U-B7VVO-4PJWW-6TKDJ-WPB77",latitude,longitude,mb.Coordinate2D.latitude,mb.Coordinate2D.longitude];
//   qqmap://map/routeplan?type=drive&from=天安门&fromcoord=39.994745,116.247282&to=天津之眼&tocoord=39.867192,116.493187&referer=OB4BZ-D4W3U-B7VVO-4PJWW-6TKDJ-WPB77

    switch (index) {

        case Baidu:
            urlString = baiduUrlStr;
            break;
        case Google:
            urlString = goooleUrlStr;
            break;
        case Gaode:
            urlString = gaodeUrlStr;
            break;
        case Tencent:
            urlString = qqUrlStr;
            break;


        default:
            break;
    }
    return urlString;
}

- (NSString *)getUrlStrWithAddress:(MapSelect)index
{
    NSString * urlString = nil;
    MapNavigationManager * mb = [MapNavigationManager shardMBManager];
    //地址系列
    //腾讯
    NSString * tencentAddressUrl = [[NSString stringWithFormat:@"qqmap://map/routeplan?type=walk&from=%@&to=%@&policy=1&referer=%@",mb.start, mb.end,_appName] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //苹果
    NSString *appleAddressUrl = [[NSString stringWithFormat:@"http://maps.apple.com/?saddr=%@&daddr=%@&dirflg=w",_start, mb.end] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //百度
    NSString *baiduAddressUrl = [[NSString stringWithFormat:@"baidumap://map/direction?origin=%@&destination=%@&mode=walking&region=%@&src=%@",mb.start, mb.end,_city,_appName] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //高德
    NSString *gaodeAddressUrl = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&sid=BGVIS1&sname=%@&did=BGVIS2&dname=%@&dev=0&m=2&t=0",_appName,mb.start,mb.end] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //谷歌
    NSString *googleAddressUrl = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=%@&daddr=%@&directionsmode=bicycling",_appName,_urlScheme,mb.start, mb.end] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    switch (index) {
        case Apple:
            urlString = appleAddressUrl;
            break;
        case Baidu:
            urlString = baiduAddressUrl;
            break;
        case Google:
            urlString = googleAddressUrl;
            break;
        case Gaode:
            urlString = gaodeAddressUrl;
            break;
        case Tencent:
            urlString = tencentAddressUrl;
            break;
        default:
            break;
    }
    
    return urlString;
}


+ (void)showSheetWithCity:(NSString *)city start:(NSString *)start end:(NSString *)end
{
    MapNavigationManager * mb = [self shardMBManager];
    mb.city = city;
    mb.start = start;
    mb.end = end;
    mb.style = Address;
    [mb showSheet];
    
    
}

+ (void)showSheetWithCoordinate2D:(CLLocationCoordinate2D)Coordinate2D
{
    MapNavigationManager * mb = [self shardMBManager];
    mb.style = Coordinates;
    mb.Coordinate2D = Coordinate2D;
    [mb showSheet];
    
}

//#pragma mark - 定位方法
//- (void)startLocaition {
//    //判断用户定位服务是否开启
//    if ([CLLocationManager locationServicesEnabled]) {
//        // 开始定位
//        [self.locationManager requestAlwaysAuthorization];//这句话ios8以上版本使用。
//        [self.locationManager startUpdatingLocation];
//    } else {
//        //不能定位用户的位置
//        //1.提醒用户检查当前的网络状况
//        //2.提醒用户打开定位开关
//        //        NSLog(@"定位失败，请打开定位");
//
//    }
//}


//#pragma mark - 定位失败
//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//    //    NSLog(@"定位失败----%@", error);
//    [self stopLocation];
//}
//
//#pragma mark - 定位懒加载
//- (CLLocationManager *)locationManager {
//    if (_locationManager == nil) {
//        //1.创建位置管理器（定位用户的位置）
//        self.locationManager = [[CLLocationManager alloc]init];
//        //2.设置代理
//        self.locationManager.delegate = self;
//        // 设置定位精确度到米
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        //每隔多少米定位一次（这里的设置为任何的移动）
//        self.locationManager.distanceFilter = kCLDistanceFilterNone;
//        //设置定位的精准度，一般精准度越高，越耗电（这里设置为精准度最高的，适用于导航应用）
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//        // 设置过滤器为无
//        //    self.locationManager.distanceFilter = 1.0;
//    }
//    return _locationManager;
//}
//
//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
//    //    NSLog(@"%@",locations);
//    //    "<+40.04104531,+116.43421232> +/- 1414.00m (speed -1.00 mps / course -1.00) @ 2018/4/12, 13:27:47 China Standard Time"
//    //locations数组里边存放的是CLLocation对象，一个CLLocation对象就代表着一个位置
//    CLLocation *loc = [locations firstObject];
//    //    NSLog(@"纬度=%f，经度=%f",loc.coordinate.latitude,loc.coordinate.longitude);
//    //    NSLog(@"%ld",locations.count);
//    //将经度显示到label上
//    self.longitude = [NSString stringWithFormat:@"%6f", loc.coordinate.longitude];
//    //将纬度现实到label上
//    self.latitude = [NSString stringWithFormat:@"%6f", loc.coordinate.latitude];
//    //    NSLog(@"经度：%@",self.longitude);
//    //    NSLog(@"纬度：%@",self.latitude);
//    self.locationStr = [NSString stringWithFormat:@"%@;%@",self.longitude,self.latitude];
//    //    NSLog(@"经纬度：%@",self.locationStr);
//    [self.locationManager stopUpdatingLocation];
//    CLGeocoder *geocoder = [CLGeocoder new];
//    [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
//        NSString * str = [NSString string];
//        for (CLPlacemark *place in placemarks) {
//            //            NSLog(@"name,%@",place.name);                      // 位置名
//            //            NSLog(@"thoroughfare,%@",place.thoroughfare);      // 街道
//            //            NSLog(@"subThoroughfare,%@",place.subThoroughfare);// 子街道
//            //            NSLog(@"locality,%@",place.locality);              // 市
//            //            NSLog(@"subLocality,%@",place.subLocality);        // 区
//            //            NSLog(@"country,%@",place.country);                // 国家
//            str = [NSString stringWithFormat:@"%@",place.locality];
//        }
//    }];
//}
//
//
//-(void)stopLocation {
//    self.locationManager = nil;
//}



@end

