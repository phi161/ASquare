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

@property (nonatomic, strong) IBOutlet UILabel *venueInfoLabel;
@property (nonatomic, strong) IBOutlet UIView *ratingView;
@property (nonatomic, strong) IBOutlet UILabel *ratingLabel;
@property (nonatomic, strong) IBOutlet UIImageView *venueImageView;

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
        
        self.venueInfoLabel.text = venue.name;
        self.ratingLabel.text = [venue ratingString];
        self.venueImageView.image = venue.iconImage;
    }
}


@end
