//
//  FoursquareService.h
//  ASquare
//
//  Created by phi on 10/7/15.
//  Copyright © 2015 Carmine Studios. All rights reserved.
//

@import CoreLocation;
@import Foundation;
@class Venue;

typedef void (^VenueSearchCompletionBlock)(NSArray *venues, NSError *error);

@interface FoursquareService : NSObject

-(void)venuesForLocationWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude completion:(VenueSearchCompletionBlock)completion;

@end
