//
//  Location.h
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 23/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "HTTPURLRequest.h"
@interface LocationManager : NSObject<CLLocationManagerDelegate,HTTPURLRequestDelegate>
{
    CLGeocoder *geocoder;
    CLPlacemark *placemark;

}
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) NSString *latitude ;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *currentLocation;

+ (LocationManager*)sharedInstance;
-(void)StopUpdatingLocation;
-(void)StartUpdatingLocation;
-(BOOL)CheckLocation;


@end
