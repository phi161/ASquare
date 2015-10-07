//
//  Venue.h
//  ASquare
//
//  Created by phi on 10/6/15.
//  Copyright © 2015 Carmine Studios. All rights reserved.
//

@import UIKit;
@import Foundation;

@interface Venue : NSObject

@property (nonatomic, copy) NSString *venueId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, copy) NSString *imagePath;
@property (nonatomic, copy) NSString *categoryImagePath;
@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, strong) UIImage *iconImage;

-(id)initWithDictionary:(NSDictionary *)dictionary;

-(NSString *)ratingString;

@end
