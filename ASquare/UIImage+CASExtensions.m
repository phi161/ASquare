//
//  UIImage+CASExtensions.m
//  ASquare
//
//  Created by phi on 10/7/15.
//  Copyright © 2015 Carmine Studios. All rights reserved.
//

#import "UIImage+CASExtensions.h"

@implementation UIImage (CASExtensions)

-(UIImage *)cas_imageWithOverlay:(UIImage *)overlay atPosition:(CGPoint)position
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    [overlay drawInRect:CGRectMake(position.x, position.y, overlay.size.width / 2.0, overlay.size.height / 2.0)];
    UIImage *composedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return composedImage;
}


@end
