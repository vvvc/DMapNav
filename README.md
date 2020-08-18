# DMapNav

主要用在APP内未集成地图SDK的应用，通过经纬度或者地址跳转到已安装地图APP进行导航。

使用很简单

导入DMapNav文件夹导入头文件\#import "MapNavigationManager.h"

在点击事件调用

 //通过地址导航到目的地

  [MapNavigationManager showSheetWithCity:@"中国" start:@"我的位置" end:@"天津之眼"];

  //通过经纬度导航到目的地

  CGFloat longitude = 117.1864549441989;//经度

  CGFloat latitude = 39.153950838325464;//纬度

  CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(latitude, longitude);//纬度，经度

  [MapNavigationManager showSheetWithCoordinate2D:coords];

如果觉得有用点个Star！谢谢。