//
//  UIImage+CASExtensions.h
//  ASquare
//
//  Created by phi on 10/7/15.
//  Copyright © 2015 Carmine Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CASExtensions)

/**
   Composes two images at the given position
   @param overlayh The image to compose on top of the receiver
   @param position The position of the overlay image
 */
-(UIImage *)cas_imageWithOverlay:(UIImage *)overlay atPosition:(CGPoint)position;

@end
