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
    
    //Set background color
    UIColor *background = [UIColor colorWithRed:32/255.0f green:187/255.0f blue:233/255.0f alpha:1.0f];
    self.view.backgroundColor = background;
    
    //Set up title & back button.
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Menlo-Bold" size:20.0],
                                                                     NSFontAttributeName, nil]];
    
    
    self.navigationItem.title = @"SETTINGS";
    
    UIBarButtonItem *back_button = [[UIBarButtonItem alloc]initWithTitle:@"BACK" style:UIBarButtonItemStylePlain target:self action:@selector(back_to_dayselect)];
    
    [back_button setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIFont fontWithName:@"Menlo-Bold" size:10.0], NSFontAttributeName,
                                             [UIColor blackColor], NSForegroundColorAttributeName,
                                             nil]
                                   forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = back_button;
    
    //Declare datepicker
    datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeTime;
    datePicker.minuteInterval = 15;
//    [self.view addSubview:datePicker];
    
    _startText.inputView = datePicker;

}

-(void)back_to_dayselect
{
    [self performSegueWithIdentifier:@"back" sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//        DaySelectViewController *controller = (DaySelectViewController *)segue.destinationViewController;
//        For passing parameters---
//        controller.dayStart = _
//        controller.dayEnd = _

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
