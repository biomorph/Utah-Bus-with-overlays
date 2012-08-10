//
//  UtaFetcher.h
//  Utah Bus
//
//  Created by Ravi Alla on 8/3/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "UtaAPIKey.h"
#define PUBLISHED_LINE_NAME @"PublishedLineName"
#define VEHICLE_LOCATION @"VehicleLocation"
#define LATITUDE @"Latitude"
#define LONGITUDE @"Longitude"
#define PROGRESS_RATE @"ProgressRate"
#define DEPARTURE_TIME @"EstimatedDepartureTime"
#define DIRECTION_OF_VEHICLE @"DirectionRef"
//#define STOP_ID_ALONG_THE_WAY @"StopPointRef"
#define STOP_NAME @"StopPointName"

@interface UtaFetcher:NSObject <NSXMLParserDelegate>
@property (nonatomic, strong) NSMutableArray *vehicleInfoArray;
@property (nonatomic, strong) NSMutableArray *stopInfoArray;
- (NSArray *) executeUtaFetcher :(NSString *) forQuery;

@end
