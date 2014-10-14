//
//  DaySelectViewController.m
//  DayShare
//
//  Created by Brandon Bloxsom on 10/13/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "DaySelectViewController.h"

@interface DaySelectViewController ()

@end

@implementation DaySelectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.title = @"Select a Day";
    
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    UIEdgeInsets contentInset = _tableView.contentInset;
    contentInset.bottom = _toolBar.bounds.size.height;
    [_tableView setContentInset:contentInset];
    _arrProfileInfo = [[NSMutableArray alloc] init];
    _arrProfileInfoLabel = [[NSMutableArray alloc] init];
    _calendarsArray = [[NSMutableArray alloc] init];
    
    
    _googleOAuth = [[GADGoogleOAuth alloc] initWithFrame:self.view.frame];
    [_googleOAuth setGOAuthDelegate:self];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *now = [NSDate date];
    NSString *nowString = [dateFormatter stringFromDate:now];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    NSDate *date = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:now]];
    NSString *today = [dateFormatter stringFromDate:date];
    
    // Decompose the date corresponding to "now" into Year+Month+Day components
    NSUInteger units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:units fromDate:[NSDate date]];
    // Add one day
    comps.day = comps.day + 1; // no worries: even if it is the end of the month it will wrap to the next month, see doc
    // Recompose a new date, without any time information (so this will be at midnight)
    NSDate *tomorrowMidnight = [[NSCalendar currentCalendar] dateFromComponents:comps];
    
    NSString *tomorrow = [dateFormatter stringFromDate:tomorrowMidnight];
    
    _timeStart = today;
    _timeEnd = tomorrow;
    
    [self authorize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_arrProfileInfo count];
}

- (void) authorize {
    [_googleOAuth authorizeUserWithClienID:@"878770239271-p5cul9k5egrfn9t14rdtd1rtstb1cknn.apps.googleusercontent.com"
                           andClientSecret:@"8nwUU5LwKQClq444o7Rbkjg7"
                             andParentView:self.view
                                 andScopes:[NSArray arrayWithObjects:@"https://www.googleapis.com/auth/calendar.readonly", nil]
     ];
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *)path {
    //    NSLog(@"%i", path.row);
    NSInteger row = (NSInteger)path.row;
    //    NSLog(@"%s", _calendarsArray[row]);
    NSString *cal_id = [_calendarsArray[row] valueForKey:@"etag"];
    NSLog(@"%@", cal_id);
    [tableView deselectRowAtIndexPath:path animated:true];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        [[cell textLabel] setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
        [[cell textLabel] setShadowOffset:CGSizeMake(1.0, 1.0)];
        [[cell textLabel] setShadowColor:[UIColor whiteColor]];
        
        [[cell detailTextLabel] setFont:[UIFont fontWithName:@"Helvetica Neue" size:13.0]];
        [[cell detailTextLabel] setTextColor:[UIColor grayColor]];
    }
    
    [[cell textLabel] setText:[_arrProfileInfo objectAtIndex:[indexPath row]]];
    //    [[cell detailTextLabel] setText:[_arrProfileInfoLabel objectAtIndex:[indexPath row]]];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}


- (IBAction)revokeAccess:(id)sender {
    [_googleOAuth revokeAccessToken];
}

-(void)authorizationWasSuccessful{
    NSString *cal_ids = [NSString stringWithFormat: @"[{\"id\":\"%@\"}]", _calendarID];
    NSArray *values = [NSArray arrayWithObjects:cal_ids, _timeStart, _timeEnd, nil];
    NSArray *params = [NSArray arrayWithObjects:@"items", @"timeMin", @"timeMax", nil];
    [_googleOAuth callAPI:@"https://www.googleapis.com/calendar/v3/freeBusy"
           withHttpMethod:httpMethod_POST
       postParameterNames:params postParameterValues: values];
}

-(void)accessTokenWasRevoked{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Your access was revoked!"
                                                   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    
    [_arrProfileInfo removeAllObjects];
    [_arrProfileInfoLabel removeAllObjects];
    
    [_tableView reloadData];
}

-(void)errorOccuredWithShortDescription:(NSString *)errorShortDescription andErrorDetails:(NSString *)errorDetails{
    NSLog(@"%@", errorShortDescription);
    NSLog(@"%@", errorDetails);
}


-(void)errorInResponseWithBody:(NSString *)errorMessage{
    NSLog(@"%@", errorMessage);
}

-(void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData{
    NSLog(@"");
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseJSONAsData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:nil];
    
    NSLog(@"%@", responseJSONAsString);
    _calendarsArray = [dict valueForKey:@"items"];
    _arrProfileInfo = [[NSMutableArray alloc] init];
    
    [_tableView reloadData];
}

@end

