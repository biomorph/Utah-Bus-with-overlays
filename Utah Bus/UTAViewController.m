//
//  ViewController.m
//  Utah Bus
//
//  Created by Ravi Alla on 8/3/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import "UTAViewController.h"
#import "UtaFetcher.h"
#import "MapViewController.h"
#import "LocationAnnotation.h"

@interface UTAViewController ()

@property (nonatomic, strong) NSString *onwardCalls;
@property (nonatomic, strong) NSArray *vehicleInfoArray;
@property (nonatomic, strong) UtaFetcher *utaFetcher;
@property (nonatomic, strong) LocationAnnotation *annotation;
@property (nonatomic, strong) NSMutableArray *shape_lt;
@property (nonatomic, strong) NSMutableArray *shape_lon;
@end

@implementation UTAViewController
@synthesize routeName = _routeName;
@synthesize onwardCalls = _onwardCalls;
@synthesize utaFetcher = _utaFetcher;
@synthesize vehicleInfoArray = _vehicleInfoArray;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize shape_lon = _shape_lon;
@synthesize shape_lt = _shape_lt;



- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext)_managedObjectContext = [[NSManagedObjectContext alloc]init];
    return _managedObjectContext;
}

- (NSMutableArray *) shape_lon
{
    if (!_shape_lon)_shape_lon = [[NSMutableArray alloc]init];
    return _shape_lon;
}

- (NSMutableArray *) shape_lt
{
    if (!_shape_lt)_shape_lt = [[NSMutableArray alloc]init];
    return _shape_lt;
}
- (UtaFetcher *) utaFetcher
{
    if (!_utaFetcher) _utaFetcher = [[UtaFetcher alloc] init];
    return _utaFetcher;
}

- (void)viewDidLoad
{
    [super viewDidLoad];


}

//This method dismisses the onscreen keyboard when touched away from text field
- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event {
    
    for (UIView* view in self.view.subviews) {
        
        if ([view isKindOfClass:[UITextField class]])
            
            [view resignFirstResponder];
        
    }
    
}

- (IBAction)showBuses:(id)sender {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    NSString *urlString = [NSString stringWithFormat:@"http://api.rideuta.com/SIRI/SIRI.svc/VehicleMonitor/ByRoute?route=%@&onwardcalls=true&usertoken=%@",self.routeName.text,UtaAPIKey];
    dispatch_queue_t xmlGetter = dispatch_queue_create("UTA xml getter", NULL);
    dispatch_async(xmlGetter, ^{
        self.vehicleInfoArray = [self.utaFetcher executeUtaFetcher:urlString];
        NSString *routeID = [NSString string];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Routes"
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        for (NSManagedObject *route in fetchedObjects){
            if ([[route valueForKey:@"route_short_name"] isEqualToString:self.routeName.text]){
                routeID = [route valueForKey:@"route_id"];
            }
        }
        NSString * shapeID = [NSString string];
        NSEntityDescription *tripsEntity = [NSEntityDescription entityForName:@"Trips"
                                                       inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:tripsEntity];
        NSArray *fetchedTrips = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        for (NSManagedObject *trip in fetchedTrips){
            if([[trip valueForKey:@"route_id"] isEqualToString:routeID]){
                shapeID = [trip valueForKey:@"shape_id"];
            }
        }

        NSEntityDescription *shapesEntity = [NSEntityDescription entityForName:@"Shapes"
                                                        inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:shapesEntity];
        NSArray *fetchedShapes = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        for (NSManagedObject *shape in fetchedShapes){
            if([[shape valueForKey:@"shape_id"] isEqualToString:shapeID]){
                [self.shape_lt addObject:[shape valueForKey:@"shape_pt_lat"]];
                [self.shape_lon addObject:[shape valueForKey:@"shape_pt_lon"]];
            }
        }
        [spinner stopAnimating];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"show on map" sender:sender];
    });
    });
    dispatch_release(xmlGetter);
   

}
- (NSArray *) mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.vehicleInfoArray count]];
    for(NSDictionary *vehicle in self.vehicleInfoArray){
        [annotations addObject:[LocationAnnotation annotationForVehicleOrStop:vehicle]];
        
    }
    return annotations;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show on map"]){
        [segue.destinationViewController setAnnotations:[self mapAnnotations]];
        [segue.destinationViewController setShape_lon:self.shape_lon];
        [segue.destinationViewController setShape_lt:self.shape_lt];
        self.shape_lon = nil;
        self.shape_lt = nil;
    }
}

- (void)viewDidUnload
{
    [self setRouteName:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
