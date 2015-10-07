//
//  Venue.m
//  ASquare
//
//  Created by phi on 10/6/15.
//  Copyright © 2015 Carmine Studios. All rights reserved.
//

#import "Venue.h"

@implementation Venue

#pragma mark - Setup

-(id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];

    if (self)
    {
        _venueId = dictionary[@"id"];
        _name = dictionary[@"name"];
        _latitude = [dictionary valueForKeyPath:@"location.lat"];
        _longitude = [dictionary valueForKeyPath:@"location.lng"];
        _address = [dictionary valueForKeyPath:@"location.address"];

        NSArray *categories = dictionary[@"categories"];
        NSDictionary *category = [categories firstObject];

        if (category)
        {
            _categoryImagePath = [NSString stringWithFormat:@"%@64%@", [category valueForKeyPath:@"icon.prefix"], [category valueForKeyPath:@"icon.suffix"]];
            _categoryName = category[@"name"];
        }
    }

    return self;
}


-(NSString *)description
{
    return [NSString stringWithFormat:@"[%@] %@ - %@", self.venueId, self.name, self.categoryName];
}


@end
