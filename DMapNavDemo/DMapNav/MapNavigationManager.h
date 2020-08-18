//
//  MapNavigationManager.h
//  DMapNavDemo
//
//  Created by NK on 2020/8/18.
//  Copyright © 2018年 YAND. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import CoreLocation;
@import MapKit;
typedef enum : NSUInteger {
    Address = 0,
    Coordinates
} MapNavStyle;

@interface MapNavigationManager : NSObject

+ (void)showSheetWithCity:(NSString *)city start:(NSString *)start end:(NSString *)end;
+ (void)showSheetWithCoordinate2D:(CLLocationCoordinate2D)Coordinate2D;

@end
