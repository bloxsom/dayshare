#import <UIKit/UIKit.h>
#import "GADGoogleOAuth.h"

@interface DaySelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, GoogleOAuthDelegate>
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *profileButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revokeAccessButton;

@property (nonatomic, strong) NSMutableArray *arrDays;
@property (nonatomic, strong) NSMutableArray *arrDayNameLabels;
@property (nonatomic, strong) NSMutableArray *arrDayFullNameLabels;

@property (nonatomic, strong) NSMutableArray *arrCalendarIds;

@property (nonatomic, strong) GADGoogleOAuth *googleOAuth;

@property(nonatomic) NSString *calendarID;
@property(nonatomic) NSString *timeStart;
@property(nonatomic) NSString *timeEnd;
@property(nonatomic) NSString *timeZone;

- (void)calculateFreeTime:(NSMutableArray *)startDates end:(NSMutableArray *)endDates;

- (void)copyToClipboard:(NSString *)str;

@end
