//
//  InitialViewController.m
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 11..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import "InitialViewController.h"
#import "AppDelegate.h"
#import "VKLocalPlayer.h"
#import "LocalPlayerHandlers.h"
#import "ViewControllerUtil.h"
#import "NotificationNames.h"

@interface InitialViewController ()
{
    ViewControllerUtil *util;
}
@end

@implementation InitialViewController

@synthesize createUserButton, logInButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // setup util
    util = [[ViewControllerUtil alloc] init];
    [self.view addSubview:util.indicator];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserID"];
    if (userID)
    {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        appDelegate.myUserID = userID;
        
        VKLocalPlayer * localPlayer = VKLocalPlayer::localPlayer();
        if (localPlayer->isAuthenticated())
        {
            [self performSegueWithIdentifier:@"ShowMain" sender:nil];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAuthenticate:) name:VKLocalPlayerDidOnAuthenticateCalledNotification object:nil];
            
            LocalPlayerHandlers *handler = LocalPlayerHandlers::sharedInstance();
            NSString *email = [[NSUserDefaults standardUserDefaults] valueForKey:@"Email"];
            NSString *pw = [[NSUserDefaults standardUserDefaults] valueForKey:@"Password"];
            localPlayer->authenticate(email.UTF8String, pw.UTF8String, handler);
            
            [util showIndicator];
            createUserButton.hidden = YES;
            logInButton.hidden = YES;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - server response

- (void)onAuthenticate:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VKLocalPlayerDidOnAuthenticateCalledNotification object:nil];
    [self performSelectorOnMainThread:@selector(hideIndicator) withObject:nil waitUntilDone:NO];
    
    // check error
    NSString *error = [[aNotification userInfo] objectForKey:@"Error"];
    if (error != nil)
    {
        NSLog(@"%@:%@ error = %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);
    }
    else
    {
        NSLog(@"%@:%@ sucessfully authenticated", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        [self performSelectorOnMainThread:@selector(showMain) withObject:nil waitUntilDone:NO];
    }
}

- (void)hideIndicator
{
    [util hideIndicator];
}

- (void)showMain
{
    [self performSegueWithIdentifier:@"ShowMain" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    createUserButton.hidden = YES;
    logInButton.hidden = YES;
}

@end
