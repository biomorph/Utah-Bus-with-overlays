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
@property (strong, nonatomic) NSString *progress;

@end

@implementation MapViewController
@synthesize mapView = _mapView;

@synthesize annotations = _annotations;
@synthesize  vehicleInfo = _vehicleInfo;
@synthesize currentLocation = _currentLocation;
@synthesize locationManager = _locationManager;
@synthesize stops = _stops;
@synthesize progress = _progress;
@synthesize shape_lon = _shape_lon;
@synthesize shape_lt = _shape_lt;   

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// update method for when the annotations or mapview is updated
-(void) updateMapView
{
    if (self.mapView.annotations)[self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations)[self.mapView addAnnotations:self.annotations];
   
// Setting the initial zoom based on the highest and lowest values of the latitudes and longitudes of the buses' locations
    if ([self.annotations count]!= 0 && [self.shape_lon count]!=0){
        NSMutableArray *latitude = [NSMutableArray arrayWithArray:self.shape_lt];
    NSMutableArray *longitude = [NSMutableArray arrayWithArray:self.shape_lon];
        for (LocationAnnotation *annotation in self.annotations){
        self.vehicleInfo = [annotation vehicleInfo];
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

// protecting against a crash when utafetcher returns empty stuff for whatever reason
    else {
    MKCoordinateRegion zoomRegion;
    zoomRegion.center.latitude = 40.760779;
    zoomRegion.center.longitude = -111.891047;
    zoomRegion.span.latitudeDelta = 0.8;
    zoomRegion.span.longitudeDelta = 0.8;
    [self.mapView setRegion:zoomRegion animated:YES];
}
   
// This is where i am making an array of coordinates to make an MKPolyLine out of
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
// Making the mkpolyline with the coordinates array i made above
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberofSteps];
    [self.mapView addOverlay:polyLine];
}

//setting up the annotations and customizing the rightcalloutaccessory
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (![annotation isKindOfClass:[MKUserLocation class]]){
    MKAnnotationView *aView =[mapView dequeueReusableAnnotationViewWithIdentifier:@"Bus Coordinates"];
    if (!aView){
         aView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"Bus Coordinates"];
        aView.canShowCallout = YES;
    }
    aView.annotation = annotation;
    aView.leftCalloutAccessoryView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.typeDetailDisclosure = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    aView.rightCalloutAccessoryView = self.typeDetailDisclosure;
    return aView;
    }
    else return  nil;
}




// draw the polyline onto the map, setting line stroke width and color as well
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor redColor];
    polylineView.lineWidth = 2.0;
    
    return polylineView;
}

// add the current route to favorites
- (IBAction)addToFavorites:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [[defaults objectForKey:@"favorite.routes"] mutableCopy];
    NSArray *routeInfo = [NSArray arrayWithObjects:[self.vehicleInfo objectForKey:PUBLISHED_LINE_NAME],[self.vehicleInfo objectForKey:LINE_NAME],nil];
    if (!favorites) favorites = [NSMutableArray array];
    //add only if the routeInfo returns a short and long name, the route count is checking for that here
    if (favorites && ![favorites containsObject:routeInfo]&&[routeInfo count]!=0) [favorites addObject:routeInfo];
    [defaults setObject:favorites forKey:@"favorite.routes"];
    [defaults synchronize];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    self.vehicleInfo = [(LocationAnnotation *)view.annotation vehicleInfo];
    if (self.vehicleInfo){
        self.stops = [self.vehicleInfo objectForKey:STOP_POINT_REF];
        [self performSegueWithIdentifier:@"show closest stops" sender:view.rightCalloutAccessoryView];
    }
}

// assigning a colored dot based on the current progress of the bus
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    self.vehicleInfo = [(LocationAnnotation *)view.annotation vehicleInfo];
    NSString *progress = [self.vehicleInfo objectForKey:PROGRESS_RATE];
    CGRect progressRect = CGRectMake(0, 0, 20, 20);
    UIGraphicsBeginImageContext(progressRect.size);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextAddArc(UIGraphicsGetCurrentContext(), 10, 10, 2, 0, 2*M_PI, YES);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    if ([progress isEqualToString:@"0"]) [[UIColor blueColor]setStroke];
    if ([progress isEqualToString:@"1"]) [[UIColor greenColor]setStroke];
    if ([progress isEqualToString:@"2"]) [[UIColor orangeColor]setStroke];
    if ([progress isEqualToString:@"3"]) [[UIColor redColor]setStroke];
    if ([progress isEqualToString:@"4"]) [[UIColor lightGrayColor]setStroke];
    if ([progress isEqualToString:@"5"]) [[UIColor whiteColor]setStroke];

    CGContextStrokePath(UIGraphicsGetCurrentContext());
    UIImage *progressImage = UIGraphicsGetImageFromCurrentImageContext();
    [(UIImageView*)view.leftCalloutAccessoryView setImage:progressImage];
    
}

// seguing to a tableviewcontroller to show the stops that the selected bus makes
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show closest stops"]){
        [segue.destinationViewController setSelectedVehicle:self.vehicleInfo];
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
    [self updateMapView];
}

- (CLLocationManager *) locationManager
{
    if (!_locationManager){
        _locationManager = [[CLLocationManager alloc]init];
    }
    return _locationManager;
}

// In here I am getting the users current location
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
    if (self.shape_lon)self.shape_lon = nil;
    if (self.shape_lt) self.shape_lt = nil;
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
