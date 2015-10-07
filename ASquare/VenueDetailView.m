//
//  VenueDetailView.m
//  ASquare
//
//  Created by phi on 10/7/15.
//  Copyright © 2015 Carmine Studios. All rights reserved.
//

#import "VenueDetailView.h"
#import "Venue.h"
#import "UIColor+CASColorPalette.h"

@interface VenueDetailView ()

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *addressLabel;
@property (nonatomic, strong) IBOutlet UILabel *categoryNameLabel;
@property (nonatomic, strong) IBOutlet UIView *ratingView;
@property (nonatomic, strong) IBOutlet UILabel *ratingLabel;
@property (nonatomic, strong) IBOutlet UIImageView *venueImageView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *ratingViewWidthConstraint;

-(void)setupView;

@end


@implementation VenueDetailView

-(void)setupView
{
    UIView *nibView = [[[NSBundle mainBundle] loadNibNamed:@"VenueDetailView" owner:self options:nil] firstObject];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [nibView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:nibView];
    
    CGFloat inset = 0.0f;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:nibView attribute:NSLayoutAttributeTop multiplier:1.0f constant:-inset]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:nibView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:inset]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:nibView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:-inset]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:nibView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:inset]];

    // Label colors
    self.nameLabel.textColor = [UIColor cas_redRobinColor];
    self.addressLabel.textColor = [UIColor cas_redRobinColor];
    self.categoryNameLabel.textColor = [UIColor cas_contessaColor];
    
    // Rating View
    self.ratingView.backgroundColor = [UIColor cas_contessaColor];
    self.ratingView.layer.cornerRadius = 26.0f;
    self.ratingView.layer.borderColor = [UIColor cas_tonysPinkColor].CGColor;
    self.ratingView.layer.borderWidth = 4.0f;
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setupView];
    }

    return self;
}


-(id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];

    if (self)
    {
        [self setupView];
    }

    return self;
}


-(void)setVenue:(Venue *)venue
{
    if (venue != _venue)
    {
        _venue = venue;
        
        self.nameLabel.text = venue.name;
        self.addressLabel.text = venue.address;
        self.categoryNameLabel.text = venue.categoryName;
        
        // If we have a valid rating, show the rating view
        if (venue.rating)
        {
            self.ratingViewWidthConstraint.constant = 52.0f;
            self.ratingLabel.text = [venue ratingString];
        }
        else
        {
            self.ratingViewWidthConstraint.constant = 0.0f;
        }
        
        // Hide old image and download the new one
        self.venueImageView.image = [venue.iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.venueImageView.alpha = 0.0f;
        
        NSURLSessionDownloadTask *imageDownloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:[NSURL URLWithString:venue.imagePath] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (!error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.venueImageView.image = [UIImage imageWithData: [NSData dataWithContentsOfURL:location]];
                    [UIView animateWithDuration:0.2f animations:^{
                        self.venueImageView.alpha = 1.0f;
                    }];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.venueImageView.tintColor = [UIColor cas_redRobinColor];
                    [UIView animateWithDuration:0.2f animations:^{
                        self.venueImageView.alpha = 1.0f;
                    }];
                });
            }
        }];
        
        [imageDownloadTask resume];
    }
}


@end
