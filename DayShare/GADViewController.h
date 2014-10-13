//
//  GADViewController.h
//  GoogleAuthDemo
//
//  Created by Honghao on 7/20/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

// This demo app is made by following the tutorial http://code.tutsplus.com/tutorials/accessing-google-services-using-the-oauth-20-protocol--mobile-18394

#import <UIKit/UIKit.h>
#import "GADGoogleOAuth.h"

@interface GADViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, GoogleOAuthDelegate>
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *profileButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revokeAccessButton;

@property (nonatomic, strong) NSMutableArray *arrProfileInfo;
@property (nonatomic, strong) NSMutableArray *arrProfileInfoLabel;
@property (nonatomic, strong) GADGoogleOAuth *googleOAuth;

- (IBAction)showProfile:(id)sender;
- (IBAction)revokeAccess:(id)sender;
@end
