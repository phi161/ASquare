//
//  LocationHelper.h
//  ASquare
//
//  Created by phi on 9/30/15.
//  Copyright © 2015 Carmine Studios. All rights reserved.
//

@import CoreLocation;
@import Foundation;

typedef void (^LocationHelperCompletionBlock)(CLLocation *, NSError *);

@interface LocationHelper : NSObject

-(void)findMyLocationWithSucces:(LocationHelperCompletionBlock)completionBlock;

@end
