//
//  UTAStopMonitoringViewController.m
//  Utah Bus
//
//  Created by Ravi Alla on 8/13/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import "UTAStopMonitoringViewController.h"
#import "UtaFetcher.h"
#import "MapViewController.h"
#import "LocationAnnotation.h"
#import "FavoritesTableViewController.h"

@interface UTAStopMonitoringViewController ()<CLLocationManagerDelegate,UITableViewDelegate,UITextFieldDelegate,NSFetchedResultsControllerDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITextField *routeFilter;
@property (nonatomic, strong)  CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *stopInfoArray;
@property (nonatomic, strong) UtaFetcher *utaFetcher;
@property (nonatomic, strong) UITableView *autocompleteTableView;
@property (nonatomic, strong) NSMutableArray *autoCompleteRouteNames;
@property (nonatomic, strong) NSMutableArray *routeNames;
@property (nonatomic, strong) NSMutableArray *shape_lt;
@property (nonatomic, strong) NSMutableArray *shape_lon;


@end

@implementation UTAStopMonitoringViewController
@synthesize routeFilter = _routeFilter;
@synthesize locationManager = _locationManager;
@synthesize stopInfoArray = _stopInfoArray;
@synthesize utaFetcher = _utaFetcher;
@synthesize autoCompleteRouteNames = _autoCompleteRouteNames;
@synthesize autocompleteTableView = _autocompleteTableView;
@synthesize routeNames = _routeNames;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext)_managedObjectContext = [[NSManagedObjectContext alloc]init];
    return _managedObjectContext;
}

- (NSMutableArray *) autoCompleteRouteNames
{
    if (!_autoCompleteRouteNames) _autoCompleteRouteNames = [[NSMutableArray alloc]init];
    return _autoCompleteRouteNames;
}

- (NSMutableArray *) routeNames
{
    if (!_routeNames)_routeNames = [[NSMutableArray alloc]init];
    return _routeNames;
}
- (UtaFetcher *) utaFetcher
{
    if (!_utaFetcher)_utaFetcher = [[UtaFetcher alloc]init];
    return _utaFetcher;
}

- (NSArray *) stopInfoArray
{
    if (!_stopInfoArray)_stopInfoArray = [[NSArray alloc]init];
    return _stopInfoArray;
}

- (CLLocationManager *) locationManager
{
    if (!_locationManager){
        _locationManager = [[CLLocationManager alloc]init];
    }
    return _locationManager;
}
- (IBAction)findStops:(id)sender {
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    double latitude = self.locationManager.location.coordinate.latitude;
    double longitude = self.locationManager.location.coordinate.longitude;
    NSString *urlString = [NSString stringWithFormat:@"http://api.rideuta.com/SIRI/SIRI.svc/CloseStopmonitor?latitude=%f&longitude=%f&route=%@&numberToReturn=10&usertoken=%@",latitude,longitude, self.routeFilter.text,UtaAPIKey];
    dispatch_queue_t xmlGetter = dispatch_queue_create("UTA xml getter", NULL);
    dispatch_async(xmlGetter, ^{
        self.stopInfoArray = [self.utaFetcher executeFetcher:urlString];
        [spinner stopAnimating];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.stopInfoArray)[self performSegueWithIdentifier:@"show stops on map" sender:self];
        });
    });
    dispatch_release(xmlGetter);
    
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.autocompleteTableView.hidden = NO;
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    [self searchAutocompleteEntriesWithSubstring:substring];
    return YES;
}

// presents autofil options in a tableview based on the typed string
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    // Put anything that starts with this substring into the autocompleteUrls array
    // The items in this array is what will show up in the table view
    for(NSString *curString in self.routeNames) {
        NSRange substringRange = [curString rangeOfString:substring];
        if (substringRange.location == 0) {
            [self.autoCompleteRouteNames addObject:curString];
        }
        [self.autocompleteTableView reloadData];
    }
}

//tableview methods for autofil tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    //if ([self.autoCompleteRouteNames count]==1)self.autocompleteTableView.hidden = YES;
    
    return [self.autoCompleteRouteNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.routeFilter.text.length == 0) {
        self.autoCompleteRouteNames = nil;
        self.autocompleteTableView.hidden = YES;
    }
    UITableViewCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
    
    if ([self.autoCompleteRouteNames count] >0)cell.textLabel.text = [self.autoCompleteRouteNames objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    self.routeFilter.text = selectedCell.textLabel.text;
    self.autocompleteTableView.hidden = YES;
    
}



- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event {
    for (UIView* view in self.view.subviews) {
        if ([view isKindOfClass:[UITextField class]])
            [view resignFirstResponder];
        }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 10 m
    [self.locationManager startUpdatingLocation];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"utabus.availableroutes"]){
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Routes"
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        for (NSManagedObject *route in fetchedObjects){
            [self.routeNames addObject:[route valueForKey:@"route_short_name"]];
        }
        
        [defaults setObject:self.routeNames forKey:@"utabus.availableroutes"];
        [defaults synchronize];
    }
    else {
        self.routeNames = [defaults objectForKey:@"utabus.availableroutes"];
    }
    self.autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 180, 320, 105) style:UITableViewStylePlain];
    self.autocompleteTableView.delegate = self;
    self.autocompleteTableView.dataSource =self;
    self.autocompleteTableView.scrollEnabled = YES;
    self.autocompleteTableView.hidden = YES;
    [self.view addSubview:self.autocompleteTableView];
    self.routeFilter.delegate = self;
	// Do any additional setup after loading the view.
}
- (NSArray *) mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.stopInfoArray count]];
    for(NSDictionary *vehicle in self.stopInfoArray){
        [annotations addObject:[LocationAnnotation annotationForVehicleOrStop:vehicle]];
        
    }
    return annotations;
}

- (void) showFavorite:(NSString *)favorite : (FavoritesTableViewController *)sender
{
    self.routeFilter.text = favorite;
    //[self.navigationController popToViewController:self animated:YES];
    //[self.tabBarController setSelectedIndex:0];
    [self findStops:sender];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show stops on map"]){
        [segue.destinationViewController setAnnotations:[self mapAnnotations]];
        [segue.destinationViewController setShape_lon:self.shape_lon];
        [segue.destinationViewController setShape_lt:self.shape_lt];
        self.shape_lon = nil;
        self.shape_lt = nil;
    }
}

- (void)viewDidUnload
{
    [self setRouteFilter:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
