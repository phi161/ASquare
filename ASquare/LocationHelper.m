//
//  LocationHelper.m
//  ASquare
//
//  Created by phi on 9/30/15.
//  Copyright © 2015 Carmine Studios. All rights reserved.
//

#import "LocationHelper.h"

@interface LocationHelper () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) LocationHelperCompletionBlock block;
@property (nonatomic, strong) CLLocation *optimalLocation;

@end


@implementation LocationHelper

#pragma mark - Setup

-(instancetype)init
{
    self = [super init];

    if (self)
    {
        _optimalLocation = nil;
    }

    return self;
}


#pragma mark - Public

-(void)findMyLocationWithSucces:(LocationHelperCompletionBlock)completionBlock
{
    self.block = completionBlock;

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
}


#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray <CLLocation *> *)locations
{
    CLLocation *lastLocation = [locations lastObject];

    // Discard locations that are too old
    if (-[lastLocation.timestamp timeIntervalSinceNow] > 10.0f)
    {
        return;
    }

    // Discard locations that are invalid
    if (lastLocation.horizontalAccuracy < 0)
    {
        return;
    }

    // If the last location has better accuracy set it as the optimal and stop updating when we reach the manager's desired value
    if (self.optimalLocation == nil || lastLocation.horizontalAccuracy < self.optimalLocation.horizontalAccuracy)
    {
        self.optimalLocation = lastLocation;

        if (lastLocation.horizontalAccuracy <= manager.desiredAccuracy)
        {
            [self.locationManager stopUpdatingLocation];
        }
    }

    if (self.block)
    {
        self.block(self.optimalLocation, nil);
    }
}


-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch ([CLLocationManager authorizationStatus])
    {
        case kCLAuthorizationStatusNotDetermined: // Popup the iOS alert
            [self.locationManager requestWhenInUseAuthorization];
            break;

        case kCLAuthorizationStatusAuthorizedWhenInUse: // All is good, start location updates
            self.optimalLocation = nil; // Reset optimal location just in case user disabled location services
            [self.locationManager startUpdatingLocation];
            break;

        case kCLAuthorizationStatusDenied: // Pass an error
            if (self.block)
            {
                self.block(nil, [NSError errorWithDomain:@"LocationHelperError" code:kCLAuthorizationStatusDenied userInfo:nil]);
            }
            break;

        case kCLAuthorizationStatusRestricted: // Pass an error
            if (self.block)
            {
                self.block(nil, [NSError errorWithDomain:@"LocationHelperError" code:kCLAuthorizationStatusRestricted userInfo:nil]);
            }
            break;

        default:
            break;
    }
}


@end
