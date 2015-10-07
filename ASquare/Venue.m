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

        if (dictionary[@"bestPhoto"])
        {
            _imagePath = [NSString stringWithFormat:@"%@200x200%@", [dictionary valueForKeyPath:@"bestPhoto.prefix"], [dictionary valueForKeyPath:@"bestPhoto.suffix"]];
        }

        _rating = dictionary[@"rating"];
    }

    return self;
}


-(NSString *)description
{
    return [NSString stringWithFormat:@"[%@]\t%@\n[%.01f]\t%@", self.venueId, self.name, [self.rating floatValue], self.imagePath];
}


-(NSString *)ratingString
{
    if (self.rating)
    {
        return [NSString stringWithFormat:@"%.01f", [self.rating doubleValue]];
    }
    
    return @"-";
}


@end
