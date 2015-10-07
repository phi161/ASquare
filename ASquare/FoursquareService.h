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
typedef void (^VenueDetailsCompletionBlock)(Venue *venue, NSError *error);

/**
   This class is resposible for communicating with the Foursquare API.
   The JSON results (if successful) are being parsed and return as instances of the `Venue` class,
   otherwise an error that can either be caused from a network or parsing issue is generated.
 */
@interface FoursquareService : NSObject

/**
   Asks Foursquare for a list of venues, given a certain latitude and longitude.
   @param latitute The latitude of the location to query
   @param longitude The longitude of the location to query
   @param completion A block that runs when the operation is finished. It contains an array of Venue instances if successful, or an error describing the underlying reason
 */

-(void)venuesForLocationWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude completion:(VenueSearchCompletionBlock)completion;

/**
   Asks Foursquare for details about a venue with a provided id
   @param venueId The Foursquare venue id
   @param completion A block that runs when the operation is finished. It contains a Venue object or an error object describing the underlying reason
 */
-(void)venueForId:(NSString *)venueId completion:(VenueDetailsCompletionBlock)completion;

@end
