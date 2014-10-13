//
//  GADViewController.m
//  GoogleAuthDemo
//
//  Created by Honghao on 7/20/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "GADViewController.h"

@interface GADViewController ()

@end

@implementation GADViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.title = @"DayShare";
    
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    UIEdgeInsets contentInset = _tableView.contentInset;
    contentInset.bottom = _toolBar.bounds.size.height;
    [_tableView setContentInset:contentInset];
    _arrProfileInfo = [[NSMutableArray alloc] init];
    _arrProfileInfoLabel = [[NSMutableArray alloc] init];
    
    _googleOAuth = [[GADGoogleOAuth alloc] initWithFrame:self.view.frame];
    [_googleOAuth setGOAuthDelegate:self];
    
    [self showProfile:nil];
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


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        [[cell textLabel] setFont:[UIFont fontWithName:@"Helvetica" size:15.0]];
        [[cell textLabel] setShadowOffset:CGSizeMake(1.0, 1.0)];
        [[cell textLabel] setShadowColor:[UIColor whiteColor]];
        
        [[cell detailTextLabel] setFont:[UIFont fontWithName:@"Helvetica" size:13.0]];
        [[cell detailTextLabel] setTextColor:[UIColor grayColor]];
    }
    
    [[cell textLabel] setText:[_arrProfileInfo objectAtIndex:[indexPath row]]];
//    [[cell detailTextLabel] setText:[_arrProfileInfoLabel objectAtIndex:[indexPath row]]];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}



- (IBAction)showProfile:(id)sender {
    [_googleOAuth authorizeUserWithClienID:@"878770239271-p5cul9k5egrfn9t14rdtd1rtstb1cknn.apps.googleusercontent.com"
                           andClientSecret:@"8nwUU5LwKQClq444o7Rbkjg7"
                             andParentView:self.view
                                 andScopes:[NSArray arrayWithObjects:@"https://www.googleapis.com/auth/calendar.readonly", nil]
     ];
}

- (IBAction)revokeAccess:(id)sender {
    [_googleOAuth revokeAccessToken];
}

-(void)authorizationWasSuccessful{
    [_googleOAuth callAPI:@"https://www.googleapis.com/calendar/v3/users/me/calendarList"
           withHttpMethod:httpMethod_GET
       postParameterNames:nil postParameterValues:nil];
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
    NSMutableArray *arr = [dict valueForKey:@"items"];
    _arrProfileInfo = [[NSMutableArray alloc] init];
    for (int i=0; i<[arr count]; i++) {
        [_arrProfileInfo addObject:[[arr objectAtIndex:i] valueForKey:@"summary" ]];
    }

    [_tableView reloadData];
    self.navigationItem.title = @"Select a calendar";
}

@end