#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "CWStatusBarNotification.h"

@interface DaySelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) CWStatusBarNotification *notification;
@property (nonatomic, strong) NSMutableArray *arrDays;
@property (nonatomic, strong) NSMutableArray *arrDayNameLabels;
@property (nonatomic, strong) NSMutableArray *arrDayFullNameLabels;

@property (nonatomic, strong) NSMutableArray *arrCalendarIds;

@property(nonatomic) NSString *calendarID;
@property(nonatomic) NSString *timeStart;
@property(nonatomic) NSString *timeEnd;
@property(nonatomic) NSString *timeZone;

@property(nonatomic) NSInteger *free_hour_start;
@property(nonatomic) NSInteger *free_minute_start;
@property(nonatomic) NSInteger *free_hour_end;
@property(nonatomic) NSInteger *free_minute_end;

@property(nonatomic) NSInteger *buffer_time;

- (void)copyToClipboard:(NSString *)str;

@end

