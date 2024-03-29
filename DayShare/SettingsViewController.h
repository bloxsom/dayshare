//
//  SettingsViewController.h
//  DayShare
//
//  Created by Fiona E. Campbell on 11/11/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *startText;
@property (weak, nonatomic) IBOutlet UITextField *endText;
@property (weak, nonatomic) IBOutlet UITextField *bufferTime;

@property(nonatomic) NSInteger *free_hour_start;
@property(nonatomic) NSInteger *free_minute_start;
@property(nonatomic) NSInteger *free_hour_end;
@property(nonatomic) NSInteger *free_minute_end;
@property(nonatomic) NSMutableArray *buffer_times;

@property(nonatomic) NSInteger *buffer_time;

@end

UIDatePicker *datePicker;
UIDatePicker *datePicker2;

UIPickerView *bufferValues;

