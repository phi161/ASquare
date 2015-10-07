//
//  AppDelegate.m
//  ASquare
//
//  Created by phi on 9/30/15.
//  Copyright © 2015 Carmine Studios. All rights reserved.
//

@import GoogleMaps;
#import "AppDelegate.h"

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // This is just to avoid pushing sensitive key information on Github
    NSDictionary *keys = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"APIKeys" ofType:@"plist"]];
    NSString *googleAPIKey = keys[@"GoogleAPIKey"];

    [GMSServices provideAPIKey:googleAPIKey];

    return YES;
}


@end
