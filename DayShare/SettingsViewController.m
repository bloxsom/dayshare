//
//  SettingsViewController.m
//  DayShare
//
//  Created by Fiona E. Campbell on 11/11/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "SettingsViewController.h"
#import "DaySelectViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UITextField appearance] setFont:[UIFont fontWithName:@"Menlo" size:14.0]];
    
    //Set background color
    UIColor *background = [UIColor colorWithRed:32/255.0f green:187/255.0f blue:233/255.0f alpha:1.0f];
    self.view.backgroundColor = background;
    
    //Set up title & back button.
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Menlo-Bold" size:20.0],
                                                                     NSFontAttributeName, nil]];
    
    
    self.navigationItem.title = @"SETTINGS";
    
    UIBarButtonItem *back_button = [[UIBarButtonItem alloc]initWithTitle:@"BACK" style:UIBarButtonItemStylePlain target:self action:@selector(back_to_dayselect)];
    
    [back_button setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIFont fontWithName:@"Menlo" size:10.0], NSFontAttributeName,
                                             [UIColor blackColor], NSForegroundColorAttributeName,
                                             nil]
                                   forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = back_button;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    //Declare datepicker
    datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeTime;
    datePicker.minuteInterval = 15;
    
    datePicker2 = [[UIDatePicker alloc] init];
    datePicker2.datePickerMode = UIDatePickerModeTime;
    datePicker2.minuteInterval = 15;
    
    _startText.inputView = datePicker;
    _endText.inputView = datePicker2;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mma"];
    
    NSString *defaultStart = @"08:00 am";
    NSString *defaultEnd = @"08:00 pm";
    
    NSString *defaultBuffer = @"0 minutes";
    _bufferTime.text = defaultBuffer;
    
    NSDate *defaultStartTime = [formatter dateFromString:defaultStart];
    NSDate *defaultEndTime = [formatter dateFromString:defaultEnd];
    
    datePicker.date = defaultStartTime;
    datePicker2.date = defaultEndTime;
    
    _startText.text = [formatter stringFromDate:datePicker.date];
    _endText.text = [formatter stringFromDate:datePicker2.date];
    
    //Declare picker for buffer time
    
    bufferValues = [[UIPickerView alloc] init];
    _bufferTime.inputView = bufferValues;
    
    _buffer_times = [[NSMutableArray alloc] init];
    [_buffer_times addObject:@"0 minutes"];
    [_buffer_times addObject:@"5 minutes"];
    [_buffer_times addObject:@"10 minutes"];
    [_buffer_times addObject:@"15 minutes"];
    [_buffer_times addObject:@"30 minutes"];
    [_buffer_times addObject:@"1 hour"];
    
    bufferValues.delegate = self;
    bufferValues.dataSource = self;
    
//    [self reloadAllComponents];
    
//    NSLog(@"selected component is: %@", [bufferValues selectedRowInComponent:0]);

}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)bufferValues {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)bufferValues numberOfRowsInComponent:(NSInteger)component {
    return [_buffer_times count];
}

- (NSString *)pickerView:(UIPickerView *)bufferValues titleForRow:(NSInteger)row forComponent:(NSInteger)component { // This method asks for what the title or label of each row will be.
    return [_buffer_times objectAtIndex:row];
}

-(void)reloadAllComponents {
    [bufferValues reloadAllComponents];
}

-(void)dismissKeyboard{
    [_startText resignFirstResponder];
    [_endText resignFirstResponder];
    [_bufferTime resignFirstResponder];
    [self dateUpdated:(datePicker) endPicker:(datePicker2)];
    [self bufferUpdated];
}

- (void) dateUpdated:(UIDatePicker *)datePicker endPicker:(UIDatePicker *)datePicker2 {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mma"];
    _startText.text = [formatter stringFromDate:datePicker.date];
    _endText.text = [formatter stringFromDate:datePicker2.date];
}

-(void)bufferUpdated {
    NSInteger x = [bufferValues selectedRowInComponent:0];
    NSLog(@"selected component is: %d", x);
    NSString *time = [_buffer_times objectAtIndex:x];
    _bufferTime.text = time;
}

-(void)back_to_dayselect
{
    [self performSegueWithIdentifier:@"back" sender:nil];
}

-(void)set_ints_from_string {
    NSString *time = _startText.text;
    NSString *hour = [time substringToIndex:2];
    NSString *minute = [time substringWithRange:(NSMakeRange(3, 2))];
    int hr = [hour intValue];
    int min = [minute intValue];
    
    _free_hour_start = hr;
    _free_minute_start = min;
    
    time = _endText.text;
    hour = [time substringToIndex:2];
    minute = [time substringWithRange:(NSMakeRange(3, 2))];
    hr = [hour intValue];
    min = [minute intValue];
    
    _free_hour_end = hr + 12;
    _free_minute_end = min;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    [self set_ints_from_string];
    
    DaySelectViewController *controller = (DaySelectViewController *)segue.destinationViewController;
    
    controller.free_hour_start = _free_hour_start;
    controller.free_minute_start = _free_minute_start;
    controller.free_hour_end = _free_hour_end;
    controller.free_minute_end = _free_minute_end;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
