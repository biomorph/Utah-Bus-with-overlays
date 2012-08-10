//
//  UtaFetcher.m
//  Utah Bus
//
//  Created by Ravi Alla on 8/3/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import "UtaFetcher.h"
#import "UTAViewController.h"
@interface UtaFetcher()//<UTAXMLFetcherDelegate>
@property (nonatomic, strong) NSString *publishedLineName;
@property (nonatomic, strong) NSString *vehicleLatitude;
@property (nonatomic, strong) NSString *vehicleLongitude;
@property (nonatomic, strong) NSString *progressRate;
@property (nonatomic, strong) NSString *departureTime;
@property (nonatomic, strong) NSString *directionOfVehicle;
@property (nonatomic, strong) NSMutableArray *stopIdsAlongTheWay;
@property (nonatomic, strong) NSMutableString *currentNode;
@property (nonatomic, strong) NSDictionary *vehicleInfo;
@end


@implementation UtaFetcher

@synthesize vehicleInfoArray = _vehicleInfoArray;
@synthesize vehicleInfo = _vehicleInfo;
@synthesize publishedLineName = _publishedLineName;
@synthesize vehicleLatitude = _vehicleLatitude;
@synthesize vehicleLongitude = _vehicleLongitude;
@synthesize progressRate = _progressRate;
@synthesize departureTime = _departureTime;
@synthesize directionOfVehicle = _directionOfVehicle;
@synthesize stopIdsAlongTheWay = _stopIdsAlongTheWay;
@synthesize currentNode = _currentNode;




// Get the xml data from UTA website and send it to an NSXMLParser instance
- (NSArray *) executeUtaFetcher :(NSString *) forQuery
{
    BOOL success;
    NSXMLParser *xmlParser;
    NSString *query = [forQuery stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *xmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:query]];
    xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
    [xmlParser setDelegate:self];
    [xmlParser setShouldResolveExternalEntities:YES];
     success = [xmlParser parse];
    NSArray *vehicleInfoArray = [NSArray arrayWithArray:self.vehicleInfoArray];
    [self.vehicleInfoArray removeAllObjects];
    return vehicleInfoArray;
    
}

//Lazily instantiate the vehicle info dictionary and other mutable arrays used for holding the parsed data

- (NSMutableArray *) vehicleInfoArray {
    if (!_vehicleInfoArray) {
        _vehicleInfoArray = [[NSMutableArray alloc]init];
    }
    return _vehicleInfoArray;
}

- (NSDictionary *) vehicleInfo {
    if (!_vehicleInfo) {
        _vehicleInfo = [[NSMutableDictionary alloc] init];
    }
    return _vehicleInfo;
}

- (NSString *) publishedLineName {
    if (!_publishedLineName){
        _publishedLineName = [[NSString alloc]init];
    }
    return _publishedLineName;
}
- (NSString *) vehicleLatitude {
    if (!_vehicleLatitude){
        _vehicleLatitude = [[NSString alloc]init];
    }
    return _vehicleLatitude;
}
- (NSString *) vehicleLongitude {
    if (!_vehicleLongitude){
        _vehicleLongitude = [[NSString alloc]init];
    }
    return _vehicleLongitude;
}
- (NSString *) progressRate {
    if (!_progressRate){
        _progressRate = [[NSString alloc]init];
    }
    return _progressRate;
}
- (NSString *) departureTime {
    if (!_departureTime){
        _departureTime = [[NSString alloc]init];
    }
    return _departureTime;
}
- (NSString *) directionOfVehicle {
    if (!_directionOfVehicle){
        _directionOfVehicle = [[NSString alloc]init];
    }
    return _directionOfVehicle;
}

- (NSMutableArray *) stopIdsAlongTheWay {
    if (!_stopIdsAlongTheWay){
        _stopIdsAlongTheWay = [[NSMutableArray alloc]init];
    }
    return _stopIdsAlongTheWay;
}
- (NSMutableString *) currentNode {
    if (!_currentNode){
        _currentNode = [[NSMutableString alloc]init];
    }
    return _currentNode;
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    
}

// NSXMLParser delegate method,that creates a string by concatenating the characters into currentNode when characters are found in elements 
- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [self.currentNode appendString:string];
}

// NSXMLParser delegate method, that assigns the currentNode string to different strings depending on element name, when an element ends 
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:PUBLISHED_LINE_NAME]) {
        self.publishedLineName = self.currentNode;
    }
    if ([elementName isEqualToString:LATITUDE]) {
        self.vehicleLatitude = self.currentNode;
    }
    if ([elementName isEqualToString:LONGITUDE]) {
        self.vehicleLongitude =self.currentNode;
    }
    if ([elementName isEqualToString:PROGRESS_RATE]) {
        self.progressRate=self.currentNode;
    }
    if ([elementName isEqualToString:DEPARTURE_TIME]){
        self.departureTime=self.currentNode;
    }
    if ([elementName isEqualToString:DIRECTION_OF_VEHICLE]){
        self.directionOfVehicle=self.currentNode;
    }
    if ([elementName isEqualToString:STOP_NAME]){
        [self.stopIdsAlongTheWay addObject:self.currentNode];
    }
    if ([elementName isEqualToString:@"MonitoredVehicleJourney"]) {
        self.vehicleInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.publishedLineName,PUBLISHED_LINE_NAME,self.vehicleLatitude,LATITUDE,self.vehicleLongitude,LONGITUDE,self.progressRate,PROGRESS_RATE,self.departureTime,DEPARTURE_TIME,self.directionOfVehicle,DIRECTION_OF_VEHICLE,self.stopIdsAlongTheWay,STOP_NAME, nil];
    [self.vehicleInfoArray addObject:self.vehicleInfo];
    }
    self.currentNode = nil;
}

// NSXMLParser delegate method, that sets the contents of the mutable arrays to nil;
- (void) parserDidEndDocument:(NSXMLParser *)parser
{
    //NSLog(@"vehicles %@",self.vehicleInfoArray);
    self.publishedLineName = nil;
    self.vehicleLatitude = nil;
    self.vehicleLongitude = nil;
    self.progressRate = nil;
    self.departureTime = nil;
    self.directionOfVehicle = nil;
    self.stopIdsAlongTheWay =nil;
}

@end
