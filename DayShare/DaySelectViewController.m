//
//  DaySelectViewController.m
//  DayShare
//
//  Created by Brandon Bloxsom on 10/13/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "DaySelectViewController.h"
#import "CWStatusBarNotification.h"
#import "SettingsViewController.h"

@interface DaySelectViewController ()

@end

@implementation DaySelectViewController

int const NUM_DAYS_FOR_SELECT = 14;
//int free_hour_start;
//NSInteger *free_hour_start;
//int free_hour_end = 20;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Menlo-Bold" size:20.0],
                                    NSFontAttributeName, nil]];
    
    //Hides back button that shows up when you come back from the segue
    self.navigationItem.hidesBackButton = YES;
    
    //Sets up title & settings button with correct fonts, etc.
    //Should this code even go here? Or do you declare buttons and stuff in the .h file?????
    self.navigationItem.title = @"SELECT A DAY";
    
    UIBarButtonItem *settings_button = [[UIBarButtonItem alloc]initWithTitle:@"SETTINGS" style:UIBarButtonItemStylePlain target:self action:@selector(go_to_settings)];
    
    [settings_button setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont fontWithName:@"Menlo" size:10.0], NSFontAttributeName,
                                     [UIColor blackColor], NSForegroundColorAttributeName,
                                     nil]
                           forState:UIControlStateNormal];

    
    self.navigationItem.rightBarButtonItem = settings_button;
    
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    
    _arrDayNameLabels = [[NSMutableArray alloc] init];
    _arrDayFullNameLabels = [[NSMutableArray alloc] init];
    _arrDays = [[NSMutableArray alloc] init];
    _arrCalendarIds = [[NSMutableArray alloc] init];
    
    _notification = [CWStatusBarNotification new];
    _notification.notificationLabelBackgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    
    //If user has not updated settings, set defaults
    if (_free_hour_start == NULL){
        _free_hour_start = 8;
        _free_hour_end = 20;
    }
    
    EKEventStore *store = [[EKEventStore alloc] init];
    // This prompts users for access to their calendars
    // TODO: Add handling for declination
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        
    }];

    [self setupDates];
}

-(void)go_to_settings
{
    [self performSegueWithIdentifier:@"settings" sender:nil];
}

-(NSArray*)fetchEventsForDate:(NSDate*)date {
    EKEventStore *store = [[EKEventStore alloc] init];
    // This prompts users for access to their calendars
    // TODO: Add handling for declination
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        
    }];
    
    // Get the appropriate calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *beginDate = [calendar dateBySettingHour:0 minute:0 second:0 ofDate:date options:0];
    NSDate *endDate = [calendar dateBySettingHour:23 minute:59 second:59 ofDate:date options:0];
    
    // Create the predicate from the event store's instance method
    NSPredicate *predicate = [store predicateForEventsWithStartDate:beginDate
                                                            endDate:endDate
                                                          calendars:nil];
    
    // Fetch all events that match the predicate
    NSArray *events = [store eventsMatchingPredicate:predicate];
    return events;
}

- (void)setupDates {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    NSDate *date = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:now]];
    
    // Decompose the date corresponding to "now" into Year+Month+Day components
    NSUInteger units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:units fromDate:[NSDate date]];
    // Add one day
    comps.day = comps.day + 1; // no worries: even if it is the end of the month it will wrap to the next month, see doc
    
    NSDateFormatter *dayNameFormatter = [[NSDateFormatter alloc] init];
    [dayNameFormatter setDateFormat:@"EEEE"];
    NSDateFormatter *fullDayNameFormatter = [[NSDateFormatter alloc] init];
    [fullDayNameFormatter setDateFormat:@"MMM d"];
    
    [_arrDayNameLabels addObject: @"TODAY"];
    
    NSString *date1 = [fullDayNameFormatter stringFromDate:date];
    NSString *dateName = [date1 uppercaseString];
    [_arrDayFullNameLabels addObject:dateName];
    
    [_arrDays addObject: date];
    
    for (int i = 0; i < NUM_DAYS_FOR_SELECT; i++) {
        NSDate *current = [[NSCalendar currentCalendar] dateFromComponents:comps];
        comps.day = comps.day + 1;
        NSString *day = [dayNameFormatter stringFromDate:current];
        NSString *dayName = [day uppercaseString];
        NSString *date = [fullDayNameFormatter stringFromDate:current];
        NSString *dateName = [date uppercaseString];
        
        [_arrDays addObject: current];
        [_arrDayNameLabels addObject:dayName];
        [_arrDayFullNameLabels addObject:dateName];
        
        
        //        [_arrDayFullNameLabels addObject: [fullDayNameFormatter stringFromDate:current]];
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


- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *)path {
    [tableView deselectRowAtIndexPath:path animated:true];
    NSInteger row = (NSInteger)path.row;
    NSDate *date = [_arrDays objectAtIndex:row];
    [self calculateFreeTimeForDate:date];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        [[cell textLabel] setFont:[UIFont fontWithName:@"Menlo-Bold" size:24.0]];
        [[cell textLabel] setTextColor:[UIColor whiteColor]];
        
    }
    
    NSString *day = [_arrDayNameLabels objectAtIndex:[indexPath row]];
    NSString *date = [_arrDayFullNameLabels objectAtIndex:[indexPath row]];
    
    NSString *text = [NSString stringWithFormat:@"%@ %@", day, date];
    
    [[cell textLabel] setText:text];
    
    
    //    pretty colors!
    NSArray *colors = [[NSArray alloc] initWithObjects:
                       [UIColor colorWithRed:28/255.0f green:249/255.0f blue:212/255.0f alpha:1.0f],
                       [UIColor colorWithRed:29/255.0f green:228/255.0f blue:219/255.0f alpha:1.0f],
                       [UIColor colorWithRed:31/255.0f green:208/255.0f blue:226/255.0f alpha:1.0f],
                       [UIColor colorWithRed:32/255.0f green:187/255.0f blue:233/255.0f alpha:1.0f],
                       [UIColor colorWithRed:34/255.0f green:167/255.0f blue:240/255.0f alpha:1.0f],
                       [UIColor colorWithRed:35/255.0f green:146/255.0f blue:247/255.0f alpha:1.0f],
                       [UIColor colorWithRed:79/255.0f green:135/255.0f blue:220/255.0f alpha:1.0f],
                       [UIColor colorWithRed:114/255.0f green:126/255.0f blue:199/255.0f alpha:1.0f],
                       [UIColor colorWithRed:149/255.0f green:117/255.0f blue:178/255.0f alpha:1.0f],
                       [UIColor colorWithRed:220/255.0f green:99/255.0f blue:135/255.0f alpha:1.0f],
                       [UIColor colorWithRed:255/255.0f green:90/255.0f blue:114/255.0f alpha:1.0f],
                       [UIColor colorWithRed:255/255.0f green:106/255.0f blue:98/255.0f alpha:1.0f],
                       [UIColor colorWithRed:255/255.0f green:100/255.0f blue:84/255.0f alpha:1.0f],
                       [UIColor colorWithRed:255/255.0f green:77/255.0f blue:77/255.0f alpha:1.0f],
                       [UIColor colorWithRed:255/255.0f green:51/255.0f blue:51/255.0f alpha:1.0f], nil];
    
    cell.backgroundColor = [colors objectAtIndex:indexPath.row];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 74.0;
}


-(void)handleCalendarResponse:(NSMutableDictionary*)response {
    NSMutableArray *calendarsArray = [response valueForKey:@"items"];
    
    for (int i = 0; i < [calendarsArray count]; i++) {
        [_arrCalendarIds addObject:[[calendarsArray objectAtIndex:i] valueForKey:@"id"]];
    }
}

-(void) calculateFreeTimeForDate:(NSDate*)date {
    NSArray *events = [self fetchEventsForDate:date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startDate = [calendar dateBySettingHour:_free_hour_start minute:_free_minute_start second:0 ofDate:date options:0];
    NSDate *endDate = [calendar dateBySettingHour:_free_hour_end minute:_free_minute_end second:0 ofDate:date options:0];
    NSDate *methodStart = [NSDate date];
    NSMutableArray *freeTimes = [self findFreeTimesFromDate:startDate toDate:endDate withEvents:events];
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    NSLog(@"executionTime = %f", executionTime);
    [self printFreeTimes:freeTimes];
}

- (NSMutableArray*)findFreeTimesFromDate:(NSDate*)startDate toDate:(NSDate*)endDate withEvents:(NSArray*)events {
    NSMutableArray *freeTimes = [[NSMutableArray alloc] init];
    NSDate *freeEnd, *freeStart;
    freeEnd = [startDate dateByAddingTimeInterval:0];
    
    do {
        freeStart = [self findNextFreeTimeFromDate:freeEnd toDate:endDate withEvents:events];
        if (freeStart == nil) {
            break;
        }
        freeEnd = [self findNextBusyTimeFromDate:freeStart toDate:endDate withEvents:events];
        if (freeEnd == nil) {
            freeEnd = [endDate dateByAddingTimeInterval:0];
            [freeTimes addObject:[NSDictionary dictionaryWithObjectsAndKeys:freeStart, @"freeStart", freeEnd, @"freeEnd", nil]];
            break;
        }
        [freeTimes addObject:[NSDictionary dictionaryWithObjectsAndKeys:freeStart, @"freeStart", freeEnd, @"freeEnd", nil]];
    } while (true);
    return freeTimes;
}


- (NSDate*)findNextFreeTimeFromDate:(NSDate*)startDate toDate:(NSDate*)endDate withEvents:(NSArray*)events {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSHourCalendarUnit+NSMinuteCalendarUnit fromDate:startDate];
    for (NSInteger i = [components hour]; i < 23; i++) {
        for (NSInteger j = (i == [components hour]) ? [components minute] : 0; j < 59; j += 15) {
            NSDate *current = [calendar dateBySettingHour:i minute:j second:1 ofDate:startDate options:0];
            bool noBusy = true;
            // If we pass the endDate return nil because there are no more free times
            // The caller of this function should handle nils accordingly
            if (![self date:current isBetweenDate:startDate andDate:endDate]) {
                return nil;
            }
            for (int k = 0; k < [events count]; k++) {
                EKEvent *event = [events objectAtIndex:k];
                if (!event.allDay && event.availability == EKEventAvailabilityBusy && [self date:current isBetweenDate:[event startDate] andDate:[event endDate]]) {
                    noBusy = false;
                }
            }
            if (noBusy) {
                return current;
            }
        }
    }
    return nil;
}

- (NSDate*)findNextBusyTimeFromDate:(NSDate*)startDate toDate:(NSDate*)endDate withEvents:(NSArray*)events {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSHourCalendarUnit+NSMinuteCalendarUnit fromDate:startDate];
    for (NSInteger i = [components hour]; i < 23; i++) {
        for (NSInteger j = (i == [components hour]) ? [components minute] : 0; j < 59; j += 15) {
            NSDate *current = [calendar dateBySettingHour:i minute:j second:1 ofDate:startDate options:0];
            // If we pass the endDate return nil because there are no more busy times in the given interval
            // The caller of this function should handle nils accordingly
            if (![self date:current isBetweenDate:startDate andDate:endDate]) {
                return nil;
            }
            for (int k = 0; k < [events count]; k++) {
                EKEvent *event = [events objectAtIndex:k];
                if (!event.allDay && event.availability == EKEventAvailabilityBusy && [self date:current isBetweenDate:[event startDate] andDate:[event endDate]]) {
                    return current;
                }
            }
        }
    }
    return nil;
}

- (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate {
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    return YES;
}

- (void)printFreeTimes:(NSMutableArray *)freeTimes {
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mma"];
    NSString *freeString = @"Free between";
    for (int i = 0; i < [freeTimes count]; i++) {
        NSString *formattedStart = [dateFormatter stringFromDate:[[freeTimes objectAtIndex:i] valueForKey:@"freeStart"]];
        NSString *formattedEnd = [dateFormatter stringFromDate:[[freeTimes objectAtIndex:i] valueForKey:@"freeEnd"]];
        freeString = [freeString stringByAppendingString:[NSString stringWithFormat:@" %@ and %@", formattedStart, formattedEnd]];
        if (i < [freeTimes count] - 1) {
            freeString = [freeString stringByAppendingString:@","];
        }
    }
    [self copyToClipboard:freeString];
}

- (void)copyToClipboard:(NSString *)str {
    [_notification displayNotificationWithMessage:@"Copied availability to clipboard!" forDuration:1.5f];
    NSLog(@"%@", str);
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = str;
}

@end

