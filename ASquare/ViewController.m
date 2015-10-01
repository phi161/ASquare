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
@property (nonatomic, strong) GMSMarker *myLocationMarker;
@property (nonatomic, strong) LocationHelper *locationHelper;

-(void)closeButtonTapped:(id)sender;
-(void)homeButtonTapped:(id)sender;

@end


@implementation ViewController

#pragma mark - Setup

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self)
    {
        _locationHelper = [[LocationHelper alloc] init];
    }

    return self;
}


-(void)viewDidLoad
{
    [super viewDidLoad];

    // Title View
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo"]];

    // Home Button
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ico-home"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(homeButtonTapped:)];

    [self.navigationItem setLeftBarButtonItem:homeButton];

    // Close button
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ico-close"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonTapped:)];

    [self.navigationItem setRightBarButtonItem:closeButton];

//    UIEdgeInsets mapInsets = UIEdgeInsetsMake(0.0, 0.0, 40.0, 0.0);
//    self.map.padding = mapInsets;
}


#pragma mark - Authorization Handling

-(void)handleLocationAuthorizationError
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LOCATION_AUTH_ERROR_TITLE", @"") message:NSLocalizedString(@"LOCATION_AUTH_ERROR_MESSAGE", @"") preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"LOCATION_AUTH_SETTINGS", @"")
                                              style:UIAlertActionStyleDefault
                                            handler: ^(UIAlertAction *_Nonnull action) {
        [self openApplicationSettings];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"LOCATION_AUTH_CANCEL", @"")
                                              style:UIAlertActionStyleCancel
                                            handler: ^(UIAlertAction *_Nonnull action) {
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
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
    [self.locationHelper
     findMyLocationWithSucces: ^(CLLocation *myLocation, NSError *error) {
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
                [self.map
                 animateToLocation:myLocation.coordinate];
                [self.map
                 animateToZoom:16];

                self.myLocationMarker = [GMSMarker markerWithPosition:myLocation.coordinate];
                self.myLocationMarker.map = self.map;
            }
        }
    }];
}


-(void)closeButtonTapped:(id)sender
{
    //
}


@end
