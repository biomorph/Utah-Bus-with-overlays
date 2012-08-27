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
@property (nonatomic, strong) NSString *route;
@end

@implementation StopInfoTableViewController

@synthesize stopDescriptionForTable = _stopDescriptionForTable;
@synthesize route = _route;



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
    NSString *sectionTitle = [NSString stringWithFormat:@"%@",[dictionary objectForKey:LINE_NAME]];
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
   if (indexPath.row == 2) cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    }
        if ([dictValues count]>0){
            if (indexPath.row == 2){
                cell.textLabel.text = @"Timetable";
                cell.detailTextLabel.text = nil;
            }
            else {
                cell.textLabel.text = [[dictValues objectAtIndex:indexPath.row] objectAtIndex:0];
                cell.detailTextLabel.text = [[dictValues objectAtIndex:indexPath.row] objectAtIndex:1];
            }
        }
    }
return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *stop = [self.stopDescriptionForTable objectAtIndex:indexPath.section];
    self.route = [stop objectForKey:LINE_NAME];
    if (self.route)[self performSegueWithIdentifier:@"show timetable" sender:self.tableView];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)path
{
    // Determine if row is selectable based on the NSIndexPath.
    if (path.row == 2)
    {
        return path;
    }
    else
    return nil;
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show timetable"])
        [segue.destinationViewController setRoute:self.route];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
