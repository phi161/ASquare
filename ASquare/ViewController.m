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

@interface ViewController ()

@property (nonatomic, strong) IBOutlet GMSMapView *map;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UILabel *addressLabel;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (nonatomic, strong) GMSMarker *myLocationMarker;
@property (nonatomic, strong) LocationHelper *locationHelper;

-(void)closeButtonTapped:(id)sender;
-(void)homeButtonTapped:(id)sender;
-(void)reset;

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
        //
    }

    return self;
}


-(void)viewDidLoad
{
    [super viewDidLoad];

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
    //
}


#pragma mark - Logic

-(void)requestLocation
{
    self.statusLabel.text = NSLocalizedString(@"GETTING_LOCATION", @"Status text while requesting the curent location");

    _locationHelper = [[LocationHelper alloc] init];

    [self.locationHelper findMyLocationWithSucces: ^(CLLocation *myLocation, BOOL finished, NSError *error) {
        if (error)
        {
            [self handleLocationAuthorizationError];
        }
        else
        {
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
            // NSLog(@"Failed to fetch address: %@", [error description]);
        }
    }];
}


-(void)reset
{
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


@end
