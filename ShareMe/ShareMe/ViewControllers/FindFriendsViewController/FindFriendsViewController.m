//
//  FindFriendsViewController.m
//  ShareMe
//
//  Created by Nguyen Xuan Thanh on 10/14/16.
//  Copyright © 2016 Framgia. All rights reserved.
//

#import "FindFriendsViewController.h"
@import GoogleMaps;

@interface FindFriendsViewController () {
    CLLocationManager *_locationManager;
    CLLocation *_location;
    GMSMapView *_mapView;
}

@end

@implementation FindFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager startUpdatingLocation];
    _location = _locationManager.location;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_location.coordinate.latitude
        longitude:_location.coordinate.longitude zoom:10];
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = camera.target;
    marker.snippet = @"Current location";
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = _mapView;
    self.view = _mapView;
    GMSCircle *circle = [GMSCircle circleWithPosition:_location.coordinate radius:20000];
    circle.fillColor = [UIColor colorWithRed:0.25 green:0 blue:0 alpha:0.05];
    circle.strokeColor = [UIColor redColor];
    circle.strokeWidth = 1;
    circle.map = _mapView;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    _location = [locations lastObject];
    NSTimeInterval timeDiff = [_location.timestamp timeIntervalSinceNow];
    if (fabs(timeDiff) < 15.0) {
        GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate setTarget:_location.coordinate];
        [_mapView animateWithCameraUpdate:cameraUpdate];
    }
}

@end
