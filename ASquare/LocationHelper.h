//
//  LocationHelper.h
//  ASquare
//
//  Created by phi on 9/30/15.
//  Copyright © 2015 Carmine Studios. All rights reserved.
//

@import CoreLocation;
@import Foundation;

typedef void (^LocationHelperCompletionBlock)(CLLocation *location, BOOL finished, NSError *error);

/**
   This class is responsible for handling authorization of location services and returning the user's location. When reaching the desired accuracy, the location updated are stopped in order to save battery.
   Creating an instance of the class does not instantiate `CLLocationManager`.
 */
@interface LocationHelper : NSObject

/**
   Starts location services and attempts to find the user's current location. If there is no authorization it will return an error, eitherwise it will call the completion block passing the location reported by `CLLocationManager`.
   @param completionBlock A block that runs when there is a location update or if there is an authorization error
 */
-(void)findMyLocationWithSucces:(LocationHelperCompletionBlock)completionBlock;

@end
