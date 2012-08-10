//
//  MapViewController.m
//  Utah Bus
//
//  Created by Ravi Alla on 8/6/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import "MapViewController.h"
#import "LocationAnnotation.h"
#import "UtaFetcher.h"
#import "StopTableViewController.h"

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) UIButton *typeDetailDisclosure;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *stops;
@property (strong, nonatomic) NSMutableArray *shape_lt;
@property (strong, nonatomic) NSMutableArray *shape_lon;

@end

@implementation MapViewController
@synthesize mapView = _mapView;

@synthesize annotations = _annotations;
@synthesize  vehicleInfo = _vehicleInfo;
@synthesize currentLocation = _currentLocation;
@synthesize locationManager = _locationManager;
@synthesize stops = _stops;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) updateMapView
{
    if (self.mapView.annotations)[self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations)[self.mapView addAnnotations:self.annotations];
    if ([self.annotations count]!= 0){
    NSMutableArray *latitude = [NSMutableArray arrayWithCapacity:[self.annotations count]];
    NSMutableArray *longitude = [NSMutableArray arrayWithCapacity:[self.annotations count]];
    for (LocationAnnotation *annotation in self.annotations){
        [latitude addObject:[[annotation vehicleInfo] objectForKey:LATITUDE]];
        [longitude addObject:[[annotation vehicleInfo]objectForKey:LONGITUDE]];
    }
    NSArray* sortedlatitude = [latitude sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return ([obj1 doubleValue] < [obj2 doubleValue]);
    }];
    
    NSArray* sortedlongitude = [longitude sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return ([obj1 doubleValue] < [obj2 doubleValue]);
    }];
    MKCoordinateRegion zoomRegion;
    zoomRegion.center.latitude = ([[sortedlatitude objectAtIndex:0] doubleValue]+[[sortedlatitude lastObject]doubleValue])/2;
    zoomRegion.center.longitude = ([[sortedlongitude objectAtIndex:0]doubleValue]+[[sortedlongitude lastObject]doubleValue])/2;
    double latitudeDelta = [[sortedlatitude lastObject]doubleValue]-[[sortedlatitude objectAtIndex:0]doubleValue];
    double longitudeDelta = [[sortedlongitude lastObject]doubleValue]-[[sortedlongitude objectAtIndex:0]doubleValue];
    if (latitudeDelta < 0) latitudeDelta = -1*latitudeDelta;
    if (longitudeDelta <0) longitudeDelta = -1*longitudeDelta;
    zoomRegion.span.latitudeDelta = latitudeDelta;
    zoomRegion.span.longitudeDelta = longitudeDelta;
    if (zoomRegion.span.latitudeDelta==0) zoomRegion.span.latitudeDelta = 0.2;
    if (zoomRegion.span.longitudeDelta == 0) zoomRegion.span.longitudeDelta = 0.2;
    [self.mapView setRegion:zoomRegion animated:YES];
    }
else {
    MKCoordinateRegion zoomRegion;
    zoomRegion.center.latitude = 40.760779;
    zoomRegion.center.longitude = -111.891047;
    zoomRegion.span.latitudeDelta = 0.8;
    zoomRegion.span.longitudeDelta = 0.8;
    [self.mapView setRegion:zoomRegion animated:YES];
}
    NSInteger numberofSteps = [self.shape_lt count];
    CLLocationCoordinate2D coordinates [numberofSteps];
    for (NSInteger index = 0; index <numberofSteps; index++){
        float latitude = [[self.shape_lt objectAtIndex:index]floatValue];
        float longitude = [[self.shape_lon objectAtIndex:index]floatValue];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = latitude;
        coordinate.longitude = longitude;
        coordinates[index] = coordinate;
    }
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberofSteps];
    [self.mapView addOverlay:polyLine];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (![annotation isKindOfClass:[MKUserLocation class]]){
    MKAnnotationView *aView =[mapView dequeueReusableAnnotationViewWithIdentifier:@"Bus Coordinates"];
    if (!aView){
         aView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"Bus Coordinates"];
        aView.canShowCallout = YES;
    }
    aView.annotation = annotation;
    self.typeDetailDisclosure = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    aView.rightCalloutAccessoryView = self.typeDetailDisclosure;
    return aView;
    }
    else return  nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor redColor];
    polylineView.lineWidth = 2.0;
    
    return polylineView;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    self.vehicleInfo = [(LocationAnnotation *)view.annotation vehicleInfo];
    if (self.vehicleInfo){
        self.stops = [self.vehicleInfo objectForKey:STOP_NAME];
        [self performSegueWithIdentifier:@"show stops" sender:view.rightCalloutAccessoryView];
    }
}



- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show stops"]){
        [segue.destinationViewController setStops:self.stops];
    }
}
- (void) setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void) setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
}

- (CLLocationManager *) locationManager
{
    if (!_locationManager){
        _locationManager = [[CLLocationManager alloc]init];
    }
    return _locationManager;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 10 m
    [self.locationManager startUpdatingLocation];
    [self.mapView setShowsUserLocation:YES];
    LocationAnnotation *la = (LocationAnnotation *) [self.annotations lastObject];
    NSString *title= la.title;
    self.navigationItem.title = title;
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setAnnotations:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
