//
//  StopViewController.m
//  Utah Bus
//
//  Created by Ravi Alla on 8/7/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import "StopViewController.h"
#import "UtaFetcher.h"

@interface StopViewController ()
@property (nonatomic, strong) NSMutableArray *uniqueStops;
@property (nonatomic, strong) NSArray *stopInfoArray;
@property (nonatomic, strong) UtaFetcher *utaFetcher;
@end


@implementation StopViewController

@synthesize selectedVehicle = _selectedVehicle;
@synthesize uniqueStops = _uniqueStops;
@synthesize stopInfoArray = _stopInfoArray;

- (UtaFetcher *) utaFetcher
{
    if (!_utaFetcher)_utaFetcher = [[UtaFetcher alloc]init];
    return _utaFetcher;
}
- (NSMutableArray *)uniqueStops
{
    if (!_uniqueStops) _uniqueStops = [[NSMutableArray alloc]init];
    return _uniqueStops;
}
- (void) setSelectedVehicle:(NSDictionary *)selectedVehicle
{
    _selectedVehicle = selectedVehicle;
    [self.tableView reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
   double latitude = [[self.selectedVehicle objectForKey:LATITUDE]doubleValue];
    double longitude = [[self.selectedVehicle objectForKey:LONGITUDE]doubleValue];
    NSString *closestStopUrl = [NSString stringWithFormat:@"http://api.rideuta.com/SIRI/SIRI.svc/CloseStopmonitor?latitude=%f&longitude=%f&route=%@&numberToReturn=5&usertoken=%@",latitude,longitude, [self.selectedVehicle objectForKey:LINE_NAME],UtaAPIKey];
    dispatch_queue_t xmlGetter = dispatch_queue_create("UTA xml getter", NULL);
    dispatch_async(xmlGetter, ^{
        self.stopInfoArray = [self.utaFetcher executeFetcher:closestStopUrl];
        NSString *stopUrl = [NSString stringWithFormat:@"http://api.rideuta.com/SIRI/SIRI.svc/StopMonitor?stopid=%@&minutesout=30&onwardcalls=false&filterroute=%@&usertoken=%@",[self.stopInfoArray objectAtIndex:<#(NSUInteger)#>],[self.selectedVehicle objectForKey:LINE_NAME],UtaAPIKey];
        [spinner stopAnimating];
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    });
    dispatch_release(xmlGetter);
    

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.uniqueStops count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"stop name cells";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [self.uniqueStops objectAtIndex:indexPath.row];
    
    return cell;

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

// makes all rows not selectable
- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)path
{
    // Determine if row is selectable based on the NSIndexPath.
    BOOL rowIsSelectable = NO;
    if (rowIsSelectable)
    {
        return path;
    }
    
    return nil;
}

@end
