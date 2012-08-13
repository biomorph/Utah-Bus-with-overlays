//
//  LocationAnnotation.m
//  Utah Bus
//
//  Created by Ravi Alla on 8/6/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import "LocationAnnotation.h"
#import "UtaFetcher.h"

@implementation LocationAnnotation
+ (LocationAnnotation *) annotationForVehicleOrStop: (NSDictionary *) vehicleInfo
{
    LocationAnnotation *annotation = [[LocationAnnotation alloc]init];
    annotation.vehicleInfo = vehicleInfo;
    return annotation;
}

- (NSString *) title
{
    if ([self.vehicleInfo objectForKey:PUBLISHED_LINE_NAME]){
        return [self.vehicleInfo objectForKey:PUBLISHED_LINE_NAME];
    }
    else return nil;
}

- (NSString *) subtitle
{
    if ([self.vehicleInfo objectForKey:DIRECTION_OF_VEHICLE]){
        return [self.vehicleInfo objectForKey:DIRECTION_OF_VEHICLE];
    }
    else return nil;
}

- (CLLocationCoordinate2D) coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.vehicleInfo objectForKey:LATITUDE] floatValue];
    coordinate.longitude = [[self.vehicleInfo objectForKey:LONGITUDE] floatValue];
    return  coordinate;
}

- (NSString *) progress
{
    if ([self.vehicleInfo objectForKey:PROGRESS_RATE]){
        return [self.vehicleInfo objectForKey:PROGRESS_RATE];
    }
    else return nil;
}
@end
