//
//  StopInfoTableViewController.m
//  Utah Bus
//
//  Created by Ravi Alla on 8/14/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import "StopInfoTableViewController.h"
#import "UtaFetcher.h"
#import "StopViewController.h"

@interface StopInfoTableViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataDisplayArray;
@property (nonatomic,strong) NSArray *stops;
@end

@implementation StopInfoTableViewController

@synthesize stopDescriptionForTable = _stopDescriptionForTable;
@synthesize  stops = _stops;



- (NSMutableArray *) dataDisplayArray
{
    if (!_dataDisplayArray)_dataDisplayArray = [[NSMutableArray alloc]init];
    return _dataDisplayArray;
}
- (NSArray *) stopDescriptionForTable
{
    if (!_stopDescriptionForTable)_stopDescriptionForTable = [[NSArray alloc]init];
    return _stopDescriptionForTable;
}

- (void) setStopDescriptionForTable:(NSArray *)stopDescriptionForTable
{
    _stopDescriptionForTable = stopDescriptionForTable;
    [self.tableView reloadData];
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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.stopDescriptionForTable count]==0)return 1;
    else return [self.stopDescriptionForTable count];
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.stopDescriptionForTable count]!=0)return 3;
    else return 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.stopDescriptionForTable count]!=0){
    NSDictionary *dictionary = [self.stopDescriptionForTable objectAtIndex:section];
    NSString *sectionTitle = [NSString stringWithFormat:@"%@-%@",[dictionary objectForKey:LINE_NAME],[dictionary objectForKey:PUBLISHED_LINE_NAME]];
     return sectionTitle;
    }
    else return @"UTA RETURNED NOTHING";
   
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"stop info cells";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSMutableArray *dictValues = [NSMutableArray arrayWithCapacity:3];
    if ([self.stopDescriptionForTable count]!=0){
    NSDictionary *dictionary = [self.stopDescriptionForTable objectAtIndex:indexPath.section];
   if (indexPath.row == 1) cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
   else cell.accessoryType = UITableViewCellAccessoryNone;
    for (NSString *key in dictionary){
        if ([key isEqualToString:DIRECTION_OF_VEHICLE]){
            NSArray *keyValuePairs = [NSArray arrayWithObjects:@"Direction Of Vehicle",[dictionary valueForKey:key], nil];
            [dictValues addObject:keyValuePairs];
        }
        else if ([key isEqualToString:DEPARTURE_TIME]){
            NSArray *keyValuePairs = [NSArray arrayWithObjects:@"Arrival Time",[NSString stringWithFormat:@"%d minutes",[[dictionary valueForKey:key]intValue]/60], nil];
            [dictValues addObject:keyValuePairs];
        }
        else if ([key isEqualToString:STOP_POINT_REF]){
            NSArray *keyValuePairs = [NSArray arrayWithObjects:@"Stops This Vehicle Makes",[dictionary valueForKey:key], nil];
            [dictValues addObject:keyValuePairs];
        }
    }
        cell.textLabel.text = [[dictValues objectAtIndex:indexPath.row] objectAtIndex:0];
    if ([[[dictValues objectAtIndex:indexPath.row] objectAtIndex:1] isKindOfClass:[NSString class]])
    cell.detailTextLabel.text = [[dictValues objectAtIndex:indexPath.row] objectAtIndex:1];
    else cell.detailTextLabel.text = nil;
    }
        return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *stop = [self.stopDescriptionForTable objectAtIndex:indexPath.section];
    NSArray *busStops = [stop objectForKey:STOP_POINT_REF];
    self.stops = busStops;
    if (busStops)[self performSegueWithIdentifier:@"show stops" sender:self.tableView];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)path
{
    // Determine if row is selectable based on the NSIndexPath.
    if (path.row == 1)
    {
        return path;
    }
    else
    return nil;
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show stops"])
        [segue.destinationViewController setStops:self.stops];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
