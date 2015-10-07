//
//  FoursquareService.m
//  ASquare
//
//  Created by phi on 10/7/15.
//  Copyright © 2015 Carmine Studios. All rights reserved.
//

#import "FoursquareService.h"
#import "Venue.h"

@interface FoursquareService ()

@property (nonatomic, copy) VenueSearchCompletionBlock completionBlock;
@property (nonatomic, copy) NSString *clientId;
@property (nonatomic, copy) NSString *clientSecret;
@property (nonatomic, copy) NSString *baseURLString;
@property (nonatomic, copy) NSString *apiVersion;

@end


@implementation FoursquareService

#pragma mark - Setup

-(instancetype)init
{
    self = [super init];
    
    if (self)
    {
        // This is just to avoid pushing sensitive key information on Github
        NSDictionary *keys = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"APIKeys" ofType:@"plist"]];
        _clientId = keys[@"FoursquareClientId"];
        _clientSecret = keys[@"FoursquareClientSecret"];
        
        _baseURLString = @"https://api.foursquare.com/v2/venues/search";
        _apiVersion = @"20150319"; // Just a recent date
    }
    
    return self;
}


-(void)venuesForLocationWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude completion:(VenueSearchCompletionBlock)completion
{
    self.completionBlock = [completion copy];
    
    NSURLComponents *components = [NSURLComponents componentsWithString:self.baseURLString];
    NSURLQueryItem *clientId = [NSURLQueryItem queryItemWithName:@"client_id" value:self.clientId];
    NSURLQueryItem *clientSecret = [NSURLQueryItem queryItemWithName:@"client_secret" value:self.clientSecret];
    NSURLQueryItem *version = [NSURLQueryItem queryItemWithName:@"v" value:self.apiVersion];
    NSString *coordinates = [NSString stringWithFormat:@"%f,%f", latitude, longitude];
    NSURLQueryItem *location = [NSURLQueryItem queryItemWithName:@"ll" value:coordinates];
    components.queryItems = @[clientId, clientSecret, version, location];

    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:components.URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error)
        {
            self.completionBlock(nil, error);
        }
        else
        {
            NSError *jsonError = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
            if (jsonError)
            {
                self.completionBlock(nil, jsonError);
            }
            else
            {
                NSMutableArray *mutableVenuesArray = [NSMutableArray array];
                NSArray *venuesArray = result[@"response"][@"venues"];
                [venuesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    Venue *venue = [[Venue alloc] initWithDictionary:obj];
                    [mutableVenuesArray addObject:venue];
                }];
                
                self.completionBlock([mutableVenuesArray copy], nil);
            }
        }
    }];
    
    [dataTask resume];
}


@end
