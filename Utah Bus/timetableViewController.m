//
//  timetableViewController.m
//  Utah Bus
//
//  Created by Ravi Alla on 8/24/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import "timetableViewController.h"

@interface timetableViewController ()

@end

@implementation timetableViewController

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
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit;
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [NSDate date];
    NSDateComponents *components = [gregorian components:units fromDate:date];
    NSUInteger weekDay = [components weekday];
    //NSLog(@"date is %@ and weekDay is %d",date, weekDay);
    if (weekDay == 1)self.day = @"3";
    else if (weekDay == 7)self.day = @"2";
    else self.day = @"4";
    NSString *directionString = @"0";
    NSString *timetableUrlString =[NSString stringWithFormat:@"http://www.rideuta.com/ridinguta/routes/schedule.aspx?abbreviation=%@&dir=%@&service=%@&signup=122",self.route, directionString, self.day];
    NSURL *timetableURL = [NSURL URLWithString:timetableUrlString];
    [self.timetableView loadRequest:[NSURLRequest requestWithURL:timetableURL]];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
