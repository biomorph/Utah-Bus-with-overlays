//
//  StopMapViewController.m
//  Utah Bus
//
//  Created by Ravi Alla on 8/13/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import "StopMapViewController.h"
#import "LocationAnnotation.h"
#import "UtaFetcher.h"
#import "StopInfoTableViewController.h"

@interface StopMapViewController ()<MKMapViewDelegate>
@property (nonatomic, strong) UIButton *typeDetailDisclosure;
@property (nonatomic, strong) NSArray *stopDescription;
@property (nonatomic, strong) NSArray *vehicleInfoArray;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) UtaFetcher *utaFetcher;
@property BOOL internetActive;


@end

@implementation StopMapViewController

@synthesize typeDetailDisclosure = _typeDetailDisclosure;
@synthesize stopInfo = _stopInfo;
@synthesize mapView = _mapView;
@synthesize utaFetcher = _utaFetcher;
@synthesize vehicleInfoArray = _vehicleInfoArray;

- (NSArray *) vehicleInfoArray
{
    if (!_vehicleInfoArray)_vehicleInfoArray = [[NSArray alloc]init];
    return _vehicleInfoArray;
}
- (UtaFetcher *) utaFetcher
{
    if (!_utaFetcher) _utaFetcher = [[UtaFetcher alloc] init];
    return _utaFetcher;
}
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
    
    // Setting the initial zoom based on the highest and lowest values of the latitudes and longitudes of the buses' locations
    if ([self.annotations count]!= 0){
        NSMutableArray *latitude = [NSMutableArray arrayWithCapacity:[self.annotations count]];
        NSMutableArray *longitude = [NSMutableArray arrayWithCapacity:[self.annotations count]];
        for (LocationAnnotation *annotation in self.annotations){
            [latitude addObject:[[annotation vehicleInfo] objectForKey:LATITUDE]];
            [longitude addObject:[[annotation vehicleInfo]objectForKey:LONGITUDE]];
        }

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
    else {
        MKCoordinateRegion zoomRegion;
        zoomRegion.center.latitude = 40.760779;
        zoomRegion.center.longitude = -111.891047;
        zoomRegion.span.latitudeDelta = 0.8;
        zoomRegion.span.longitudeDelta = 0.8;
        [self.mapView setRegion:zoomRegion animated:YES];
    }
   
}
- (void) setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Stops Close By";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    self.internetReachable = [Reachability reachabilityForInternetConnection];
    [self.internetReachable startNotifier];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (![annotation isKindOfClass:[MKUserLocation class]]){
    MKAnnotationView *aView =[mapView dequeueReusableAnnotationViewWithIdentifier:@"Stop Coordinates"];
    if (!aView){
        aView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"Stop Coordinates"];
        aView.canShowCallout = YES;
    }
    aView.annotation = annotation;
        aView.leftCalloutAccessoryView = nil;
        self.typeDetailDisclosure = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        aView.rightCalloutAccessoryView = self.typeDetailDisclosure;
    return aView;
}
else return  nil;
}
-(void) checkNetworkStatus:(NSNotification *)notice
{
    self.internetActive = YES;
    NetworkStatus internetStatus = [self.internetReachable currentReachabilityStatus];
    if (internetStatus == NotReachable){
        //NSLog(@"The internet is down.");
        self.internetActive = NO;
    }
    
}
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    self.stopInfo = [(LocationAnnotation *)view.annotation vehicleInfo];
    if (self.stopInfo){
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

        NSString *stopID = [self.stopInfo objectForKey:STOP_ID];
        NSString *url = [NSString stringWithFormat:@"http://api.rideuta.com/SIRI/SIRI.svc/StopMonitor?stopid=%@&minutesout=30&onwardcalls=true&filterroute=&usertoken=%@",stopID,UtaAPIKey];
        //NSLog(@"url is %@",url);
        dispatch_queue_t xmlGetter = dispatch_queue_create("UTA xml getter", NULL);
        dispatch_async(xmlGetter, ^{
            Reachability *reachability = [Reachability reachabilityForInternetConnection];
            NetworkStatus internetStatus = [reachability currentReachabilityStatus];
            if (internetStatus != NotReachable) {
            NSArray *vehicleInfoArray =  [NSArray arrayWithArray:[self.utaFetcher executeStopFetcher:url]];
            self.vehicleInfoArray = vehicleInfoArray;
            [spinner stopAnimating];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please Check Your Internet Connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
                [spinner stopAnimating];
                self.vehicleInfoArray = nil;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                 [self performSegueWithIdentifier:@"show stop info" sender:view.rightCalloutAccessoryView];
            });
        });
        dispatch_release(xmlGetter);

    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show stop info"]){
        [segue.destinationViewController setStopDescriptionForTable:self.vehicleInfoArray];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
