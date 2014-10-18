//
//  DaySelectViewController.m
//  DayShare
//
//  Created by Brandon Bloxsom on 10/13/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "DaySelectViewController.h"
#import "CWStatusBarNotification.h"

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
//    UIEdgeInsets contentInset = _tableView.contentInset;
//    contentInset.bottom = _toolBar.bounds.size.height;
//    [_tableView setContentInset:contentInset];
    _arrDayNameLabels = [[NSMutableArray alloc] init];
    _arrDayFullNameLabels = [[NSMutableArray alloc] init];
    _arrDays = [[NSMutableArray alloc] init];
    _arrCalendarIds = [[NSMutableArray alloc] init];
    
    _notification = [CWStatusBarNotification new];
    _notification.notificationLabelBackgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    
    _googleOAuth = [[GADGoogleOAuth alloc] initWithFrame:self.view.frame];
    [_googleOAuth setGOAuthDelegate:self];

    [self setupDates];
    [self authorize];
}

- (void)setupDates {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *now = [NSDate date];
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
    
    NSDateFormatter *dayNameFormatter = [[NSDateFormatter alloc] init];
    [dayNameFormatter setDateFormat:@"EEEE"];
    NSDateFormatter *fullDayNameFormatter = [[NSDateFormatter alloc] init];
    [fullDayNameFormatter setDateFormat:@"MMMM d"];
    
    [_arrDayNameLabels addObject: @"Today"];
    [_arrDayFullNameLabels addObject: [fullDayNameFormatter stringFromDate:date]];
    
    [_arrDays addObject: [NSArray arrayWithObjects:today, tomorrow, nil]];
    
    for (int i = 0; i < 7; i++) {
        NSDate *current = [[NSCalendar currentCalendar] dateFromComponents:comps];
        comps.day = comps.day + 1;
        NSDate *next = [[NSCalendar currentCalendar] dateFromComponents:comps];
        NSString *dayName = [dayNameFormatter stringFromDate:current];
        NSString *currentString = [dateFormatter stringFromDate:current];
        NSString *nextString = [dateFormatter stringFromDate:next];
        [_arrDays addObject: [NSArray arrayWithObjects:currentString, nextString, nil]];
        [_arrDayNameLabels addObject:dayName];
        [_arrDayFullNameLabels addObject: [fullDayNameFormatter stringFromDate:current]];
    }
    
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
    return [_arrDayNameLabels count];
}

- (void) authorize {
    [_googleOAuth authorizeUserWithClienID:@"878770239271-p5cul9k5egrfn9t14rdtd1rtstb1cknn.apps.googleusercontent.com"
                           andClientSecret:@"8nwUU5LwKQClq444o7Rbkjg7"
                             andParentView:self.view
                                 andScopes:[NSArray arrayWithObjects:@"https://www.googleapis.com/auth/calendar.readonly", nil]
     ];
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *)path {
    NSInteger row = (NSInteger)path.row;
    _timeStart = [_arrDays objectAtIndex:row][0];
    _timeEnd = [_arrDays objectAtIndex:row][1];
    [tableView deselectRowAtIndexPath:path animated:true];
    [self authorize];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        [[cell textLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:24.0]];
        [[cell textLabel] setShadowOffset:CGSizeMake(1.0, 1.0)];
        [[cell textLabel] setShadowColor:[UIColor whiteColor]];
        
        [[cell detailTextLabel] setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0]];
        [[cell detailTextLabel] setTextColor:[UIColor grayColor]];
    }
    
    [[cell textLabel] setText:[_arrDayNameLabels objectAtIndex:[indexPath row]]];
    [[cell detailTextLabel] setText:[_arrDayFullNameLabels objectAtIndex:[indexPath row]]];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 74.0;
}

- (IBAction)revokeAccess:(id)sender {
    [_googleOAuth revokeAccessToken];
}

-(void)fetchCalendarIDs {
    [_googleOAuth callAPI:@"https://www.googleapis.com/calendar/v3/users/me/calendarList"
           withHttpMethod:httpMethod_GET
       postParameterNames:nil postParameterValues:nil];
}

-(void)fetchFreeBusy {
    //How to get this to integrate with phone timezone?
    NSString *timeZone = @"America/Detroit";
    
    NSMutableString *calIds = [[NSMutableString alloc] init];
    [calIds appendString:@"["];
    for (int i = 0; i < [_arrCalendarIds count]; i++) {
        NSString *curr = [NSString stringWithFormat: @"{\"id\":\"%@\"}", [_arrCalendarIds objectAtIndex:i]];
        if (i > 0) {
            [calIds appendString:@","];
        }
        [calIds appendString:curr];
    }
    [calIds appendString:@"]"];
    
    
    NSArray *values = [NSArray arrayWithObjects:calIds, _timeStart, _timeEnd, timeZone, nil];
    NSArray *params = [NSArray arrayWithObjects:@"items", @"timeMin", @"timeMax", @"timeZone", nil];
    [_googleOAuth callAPI:@"https://www.googleapis.com/calendar/v3/freeBusy"
           withHttpMethod:httpMethod_POST
       postParameterNames:params postParameterValues: values];
}

-(void)authorizationWasSuccessful{
    if ([_arrCalendarIds count] == 0) {
        [self fetchCalendarIDs];
    } else {
        [self fetchFreeBusy];
    }
}

-(void)accessTokenWasRevoked{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Your access was revoked!"
                                                   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    
    [_tableView reloadData];
}

-(void)errorOccuredWithShortDescription:(NSString *)errorShortDescription andErrorDetails:(NSString *)errorDetails{
    NSLog(@"%@", errorShortDescription);
    NSLog(@"%@", errorDetails);
}


-(void)errorInResponseWithBody:(NSString *)errorMessage{
    NSLog(@"%@", errorMessage);
}

-(void)handleFreeBusyResponse:(NSMutableDictionary*)response {
    //Dictionary containing calendar object
    NSMutableDictionary *calendars = [response valueForKey:@"calendars"];
    
    //Collect the busy start/end pairs
    NSMutableArray *busyTimes = [[NSMutableArray alloc] init];
    for (id calendarKey in calendars) {
        NSMutableDictionary *calendar = [calendars objectForKey:calendarKey];
        NSMutableArray *pairs = [calendar objectForKey:@"busy"];
        for (NSMutableDictionary *pair in pairs) {
            [busyTimes addObject: pair];
        }
        
    }
    
    NSDateFormatter *dateFormatter0 = [[NSDateFormatter alloc] init];
    [dateFormatter0 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    //Arrays of NSDates
    NSMutableArray *startDates = [[NSMutableArray alloc] init];
    NSMutableArray *endDates = [[NSMutableArray alloc] init];
    
    for (int i=0; i<[busyTimes count]; i++) {
        NSString *startString = [[busyTimes objectAtIndex:i] valueForKey:@"start"];
        NSString *endString = [[busyTimes objectAtIndex:i] valueForKey:@"end"];
        NSDate *timeStart = [dateFormatter0 dateFromString:startString];
        NSDate *timeEnd = [dateFormatter0 dateFromString:endString];
        
        [startDates addObject: timeStart];
        [endDates addObject: timeEnd];
    }
    
    [self calculateFreeTime:startDates end:endDates];
}

-(void)handleCalendarResponse:(NSMutableDictionary*)response {
    NSMutableArray *calendarsArray = [response valueForKey:@"items"];
    
    for (int i = 0; i < [calendarsArray count]; i++) {
        [_arrCalendarIds addObject:[[calendarsArray objectAtIndex:i] valueForKey:@"id"]];
    }
}

-(void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData{
    
    //Dictionary containing calendar obj, kind (calendar#freeBusy), timeMax, timeMin
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseJSONAsData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:nil];
    if ([[dict valueForKey:@"kind"] isEqual:@"calendar#calendarList"]) {
        [self handleCalendarResponse:dict];
        if (_timeStart && _timeEnd) {
            [self fetchFreeBusy];
        }
    } else if ([[dict valueForKey:@"kind"] isEqual:@"calendar#freeBusy"]) {
        [self handleFreeBusyResponse:dict];
    }

}

- (void)calculateFreeTime:(NSMutableArray *)startDates end:(NSMutableArray *)endDates {
    
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"HH:mm"];
    
    //Default free times are from 8am to 10pm, change this later.
    NSString *minTime = @"08:00";
    NSString *maxTime = @"22:00";
    
    NSString *freeTimes = @"I am free from ";
    freeTimes = [freeTimes stringByAppendingString:minTime];

    
    for (int i=0; i<[startDates count]; i++) {
        
        NSString *formattedStart = [dateFormatter1 stringFromDate:[startDates objectAtIndex:i]];
        NSString *formattedEnd = [dateFormatter1 stringFromDate:[endDates objectAtIndex:i]];
        
        freeTimes = [freeTimes stringByAppendingString:[NSString stringWithFormat:@" to %@ and from %@",
                                                        formattedStart, formattedEnd]];
    }
    
    freeTimes = [freeTimes stringByAppendingString:@" to "];
    freeTimes = [freeTimes stringByAppendingString:maxTime];
    
    //To do: account for case where the end time goes later than the maxTime
    //Figure out NSDateFormatter
    //Option where users can choose when their default minTime & maxTimes are
    //Integrate more than one calendar
    
    [self copyToClipboard:freeTimes];
}

- (void)copyToClipboard:(NSString *)str {
    [_notification displayNotificationWithMessage:@"Copied availability to clipboard!" forDuration:1.5f];
    NSLog(@"%@", str);
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = str;

}

@end

