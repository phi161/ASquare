//
//  VenueDetailView.h
//  ASquare
//
//  Created by phi on 10/7/15.
//  Copyright © 2015 Carmine Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Venue;

/**
   A view that displays details for a venue
   Supports an image, the venue name and address, the category name and the rating.
   If the rating is not available, the text will expand all the way to the right and the rating view will be hidden.
 */
@interface VenueDetailView : UIView

/**
   The backing model object for populating the view
 */
@property (nonatomic, strong) Venue *venue;

@end
