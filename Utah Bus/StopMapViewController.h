//
//  StopMapViewController.h
//  Utah Bus
//
//  Created by Ravi Alla on 8/13/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import "MapViewController.h"
#import "Reachability.h"


@interface StopMapViewController : MapViewController
@property (nonatomic, strong) NSDictionary *stopInfo;
@property (strong, nonatomic) Reachability *internetReachable;
-(void) checkNetworkStatus:(NSNotification *)notice;
@end
