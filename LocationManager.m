//
//  Location.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 23/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "LocationManager.h"
#import "CMLNetworkManager.h"
#import "HorseBuzzConfig.h"
#import "HorseBuzzDataManager.h"
@implementation LocationManager
@synthesize locationManager;
@synthesize longitude,latitude,currentLocation;
+ (LocationManager*)sharedInstance{
    static LocationManager *sharedSingleton;
    if(!sharedSingleton) {
        @synchronized(sharedSingleton) {
            sharedSingleton = [LocationManager new];
        }
    }
    
    return sharedSingleton;
}
- (id)init {
    self = [super init];
    
    if(self) {
        if ([CLLocationManager locationServicesEnabled]) {
            self.locationManager = [CLLocationManager new];
            [self.locationManager setDelegate:self];
            [self.locationManager setDistanceFilter:200.0f];
            [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
            [self.locationManager setHeadingFilter:kCLHeadingFilterNone];
            [self.locationManager startUpdatingLocation];
            self.latitude = [NSString stringWithFormat:@"%f",[self.locationManager location].coordinate.latitude];
            self.longitude = [NSString stringWithFormat:@"%f",[self.locationManager location].coordinate.longitude];
            
        }
    }
    
    return self;
}
-(void)StopUpdatingLocation{
     [self.locationManager stopUpdatingLocation];
}
-(void)StartUpdatingLocation{
    [self.locationManager startUpdatingLocation];
}
-(BOOL)CheckLocation{
    if (self.latitude && self.longitude) {
        return YES;
    }
    return NO;
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //handle your location updates here
    self.latitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    self.longitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
    
    
    CLLocation *newLocations = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(newLocation.coordinate.latitude,newLocation.coordinate.longitude)
                                                             altitude:0
                                                   horizontalAccuracy:0
                                                     verticalAccuracy:0
                                                            timestamp:[NSDate date]];
    [geocoder reverseGeocodeLocation:newLocations completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            self.currentLocation = [NSString stringWithFormat:@"%@ %@ %@ %@",
                             placemark.thoroughfare,placemark.locality,placemark.administrativeArea,placemark.postalCode
                             ];
           
        } else {
           
        }
    } ];
    
    //store in db.
   
        if([[CMLNetworkManager sharedInstance] hasConnectivity]){
            if ([HorseBuzzDataManager sharedInstance].userId) {
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setObject:self.latitude forKey:@"latitude"];
            [dictionary setObject:self.longitude forKey:@"longitude"];
                if (self.currentLocation)
            [dictionary setObject:self.currentLocation forKey:@"location"];
            [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
            HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
            request.delegate=self;
            [request initwithurl:BASE_URL requestStr:UPDATELOCATION requestType:POST input:YES inputValues:dictionary];
        }
        }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    //handle your heading updates here- I would suggest only handling the nth update, because they
    //come in fast and furious and it takes a lot of processing power to handle all of them
}

#pragma mark - HTTP request delegate methods
-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
    
}
-(void)getResponsedata:(NSDictionary *)data{
     BOOL status = [[data objectForKey:SUCCESS]boolValue];
    NSString * code = [data objectForKey:@"code"];
    if (status) {
        
    }else if ([code intValue] == 2){
      
    }
    
    
}
@end
