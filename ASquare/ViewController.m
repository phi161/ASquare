//
//  ViewController.m
//  ASquare
//
//  Created by phi on 9/30/15.
//  Copyright © 2015 Carmine Studios. All rights reserved.
//

@import GoogleMaps;
#import "ViewController.h"
#import "LocationHelper.h"
#import "Venue.h"
#import "FoursquareService.h"
#import "UIImage+CASExtensions.h"
#import "VenueDetailView.h"

@interface ViewController () <GMSMapViewDelegate>

@property (nonatomic, strong) IBOutlet GMSMapView *map;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UILabel *addressLabel;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (nonatomic, strong) IBOutlet UIView *venueDetailContainer;
@property (nonatomic, strong) VenueDetailView *venueDetailView;

@property (nonatomic, strong) GMSMarker *myLocationMarker;
@property (nonatomic, strong) LocationHelper *locationHelper;
@property (nonatomic, strong) FoursquareService *foursquareService;
@property (nonatomic, strong) UIImage *venueMarkerImage;
@property (nonatomic, strong) UIImage *venueMarkerSelectedImage;
@property (nonatomic, strong) GMSMarker *selectedMarker;

-(void)closeButtonTapped:(id)sender;
-(void)homeButtonTapped:(id)sender;
-(void)reset;
-(void)setupDetailView;

@end


@implementation ViewController

#pragma mark - Setup

-(void)dealloc
{
    // NSLog(@"%s", __PRETTY_FUNCTION__);
}


-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self)
    {
        _venueMarkerImage = [UIImage imageNamed:@"ico-venue"];
        _venueMarkerSelectedImage = [UIImage imageNamed:@"ico-venue-selected"];
        _foursquareService = [FoursquareService new];
    }

    return self;
}


-(void)loadView
{
    [super loadView];
    
    _map.delegate = self;
}


-(void)viewDidLoad
{
    [super viewDidLoad];

    self.venueDetailContainer.layer.cornerRadius = 5.0f;

    self.statusLabel.text = @"";

    // Title View
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo"]];

    // Home Button
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ico-home"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(homeButtonTapped:)];

    [self.navigationItem setLeftBarButtonItem:homeButton];

    // Close button
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ico-close"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonTapped:)];

    [self.navigationItem setRightBarButtonItem:closeButton];

    // Do not hide the Google logo
    UIEdgeInsets mapInsets = UIEdgeInsetsMake(0.0, 0.0, CGRectGetHeight(self.statusLabel.superview.bounds), 0.0);
    self.map.padding = mapInsets;

    // Start looking for the location and address
    [self requestLocation];

    [self setupDetailView];
}


-(void)setupDetailView
{
    self.venueDetailView = [[VenueDetailView alloc] initWithFrame:CGRectZero];
    [self.venueDetailContainer addSubview:self.venueDetailView];
    
    CGFloat inset = 6.0f;
    [self.venueDetailContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.venueDetailView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.venueDetailContainer attribute:NSLayoutAttributeTop multiplier:1.0f constant:inset]];
    [self.venueDetailContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.venueDetailView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.venueDetailContainer attribute:NSLayoutAttributeLeading multiplier:1.0f constant:inset]];
    [self.venueDetailContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.venueDetailView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.venueDetailContainer attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-inset]];
    [self.venueDetailContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.venueDetailView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.venueDetailContainer attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-inset]];
    
    self.venueDetailContainer.alpha = 0.0f;
}


#pragma mark - Authorization Handling

-(void)handleLocationAuthorizationError
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LOCATION_AUTH_ERROR_TITLE", @"Alert title when the location services are not available") message:NSLocalizedString(@"LOCATION_AUTH_ERROR_MESSAGE", @"Alert message when the location services are not available") preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"LOCATION_AUTH_SETTINGS", @"Alert button that opens the application settings")
                                              style:UIAlertActionStyleDefault
                                            handler: ^(UIAlertAction *_Nonnull action) {
        [self openApplicationSettings];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"LOCATION_AUTH_CANCEL", @"Alert cancel button")
                                              style:UIAlertActionStyleCancel
                                            handler: ^(UIAlertAction *_Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}


-(void)openApplicationSettings
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}


#pragma mark - Actions

-(void)homeButtonTapped:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset to initial state?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    [alert addAction:[UIAlertAction actionWithTitle:@"Reset"
                                              style:UIAlertActionStyleDestructive
                                            handler: ^(UIAlertAction *_Nonnull action) {
        [self reset];
        [self requestLocation];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler: ^(UIAlertAction *_Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}


-(void)closeButtonTapped:(id)sender
{
    // Hide the detail view
    [UIView animateWithDuration:0.2f animations:^{
        self.venueDetailContainer.alpha = 0.0f;
    }];
    
    // Reset the selected marker
    if (self.selectedMarker)
    {
        Venue *previouslySelectedVenue = (Venue *)self.selectedMarker.userData;
        self.selectedMarker.icon = [self.venueMarkerImage cas_imageWithOverlay:previouslySelectedVenue.iconImage atPosition:CGPointMake(-1, -1)];
    }
    
    self.selectedMarker = nil;
}


#pragma mark - Logic

-(void)requestLocation
{
    _locationHelper = [[LocationHelper alloc] init];

    [self.locationHelper findMyLocationWithSucces: ^(CLLocation *myLocation, BOOL finished, NSError *error) {
        if (error)
        {
            self.statusLabel.text = NSLocalizedString(@"GETTING_LOCATION_FAILURE", @"Status text when the location cannot be fetched");
            [self handleLocationAuthorizationError];
        }
        else
        {
            self.statusLabel.text = NSLocalizedString(@"GETTING_LOCATION", @"Status text while requesting the curent location");
            if (self.myLocationMarker)
            {
                self.myLocationMarker.position = myLocation.coordinate;
            }
            else
            {
                [self.map animateToLocation:myLocation.coordinate];
                [self.map animateToZoom:16];

                self.myLocationMarker = [GMSMarker markerWithPosition:myLocation.coordinate];
                [self.myLocationMarker setIcon:[UIImage imageNamed:@"ico-mylocation-pin"]];
                self.myLocationMarker.map = self.map;
                
                [self requestAddress];
            }

            if (finished)
            {
                [self requestAddress];
            }
        }
    }];
}


-(void)requestAddress
{
    self.statusLabel.text = NSLocalizedString(@"GETTING_ADDRESS", @"Status text while waiting for reverse geocoding");

    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:self.myLocationMarker.position
                                   completionHandler: ^(GMSReverseGeocodeResponse *response, NSError *error) {
        NSMutableString *addressString = [NSMutableString string];
        GMSAddress *addressObject = response.firstResult;

        if (addressObject && !error)
        {
            if (addressObject.thoroughfare)
            {
                [addressString appendString:addressObject.thoroughfare];
            }

            // Update the GUI
            dispatch_async(dispatch_get_main_queue(), ^{
                self.statusLabel.text = NSLocalizedString(@"CURRENT_LOCATION", @"The text to display when the current location is found");
                self.addressLabel.text = addressString;

                // Do not hide the Google logo
                UIEdgeInsets mapInsets = UIEdgeInsetsMake(0.0, 0.0, CGRectGetHeight(self.addressLabel.superview.bounds) + CGRectGetHeight(self.statusLabel.superview.bounds), 0.0);

                self.bottomConstraint.constant = 0.0f;
                [UIView animateWithDuration:0.5 animations: ^{
                    self.map.padding = mapInsets;
                    [self.view layoutIfNeeded];
                }];
            });
        }
        else
        {
            self.statusLabel.text = NSLocalizedString(@"GETTING_ADDRESS_FAILURE", @"Status text when reverse geocoding fails");
        }
    }];
}


-(void)reset
{
    self.venueDetailContainer.alpha = 0.0f;

    self.statusLabel.text = @"";

    self.myLocationMarker = nil;

    [self.map clear];

    CGFloat addressBarHeight = CGRectGetHeight(self.addressLabel.superview.bounds);

    UIEdgeInsets mapInsets = UIEdgeInsetsMake(0.0, 0.0, addressBarHeight, 0.0);

    self.bottomConstraint.constant = -addressBarHeight;
    [UIView animateWithDuration:0.5 animations: ^{
        self.map.padding = mapInsets;
        [self.view layoutIfNeeded];
    }];

    self.locationHelper = nil;
}


#pragma mark - GMSMapViewDelegate

-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    // Clear map but keep showing "my location"
    [mapView clear];
    self.myLocationMarker.map = self.map;
    
    // Hide the detail view
    [UIView animateWithDuration:0.2f animations:^{
        self.venueDetailContainer.alpha = 0.0f;
    }];

    
    [self.foursquareService venuesForLocationWithLatitude:position.target.latitude longitude:position.target.longitude completion:^(NSArray *venues, NSError *error) {
        if (error)
        {
            //TODO: Handle error
            NSLog(@"%@", error);
        }
        else // Enumerate all venues and fetch the category image, used as a marker's icon
        {
            [venues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                Venue *venue = (Venue *)obj;
                if (venue)
                {
                    NSURLSessionDownloadTask *imageDownloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:[NSURL URLWithString:venue.categoryImagePath] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        venue.iconImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:location]];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake([venue.latitude doubleValue], [venue.longitude doubleValue])];
                            marker.userData = venue;
                            marker.icon = [self.venueMarkerImage cas_imageWithOverlay:venue.iconImage atPosition:CGPointMake(-1, -1)]; // The icon is 32p but the marker 30p so offset 1p
                            marker.map = self.map;
                        });
                        
                    }];
                    
                    [imageDownloadTask resume];
                }
            }];
        }
    }];
}


-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    // Ignore if "my location" is tapped
    if (marker == self.myLocationMarker)
    {
        return NO;
    }
    
    // Restore the icon for the previously selected marker
    if (self.selectedMarker)
    {
        Venue *previouslySelectedVenue = (Venue *)self.selectedMarker.userData;
        self.selectedMarker.icon = [self.venueMarkerImage cas_imageWithOverlay:previouslySelectedVenue.iconImage atPosition:CGPointMake(-1, -1)];
    }
    
    self.selectedMarker = marker;
    
    Venue *selectedVenue = (Venue *)marker.userData;
    
    marker.icon = [self.venueMarkerSelectedImage cas_imageWithOverlay:selectedVenue.iconImage atPosition:CGPointMake(-1, -1)];
    
    NSString *venueId = [selectedVenue venueId];
    [self.foursquareService venueForId:venueId completion:^(Venue *venue, NSError *error) {
        // The selected venue is missing information about the rating & best image so add it
        selectedVenue.imagePath = venue.imagePath;
        selectedVenue.rating = venue.rating;

        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2f animations:^{
                self.venueDetailContainer.alpha = 0.0f;
            } completion:^(BOOL finished) {
                self.venueDetailView.venue = selectedVenue;
                [UIView animateWithDuration:0.2f animations:^{
                    self.venueDetailContainer.alpha = 1.0f;
                }];
            }];
        });
    }];

    return YES;
}


@end
