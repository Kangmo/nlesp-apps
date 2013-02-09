//
//  FindFriendViewController.m
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 20..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import "FindFriendViewController.h"
#import "User.h"
#import "ShowUserViewController.h"
#import "AppDelegate.h"
#import "VKLocalPlayer.h"
#import "LocalPlayerHandlers.h"
#import "NotificationNames.h"
#import "ViewControllerUtil.h"

@interface FindFriendViewController ()
{
    ViewControllerUtil *util;
}
@end

@implementation FindFriendViewController

@synthesize searchButton, textField;

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
	// Do any additional setup after loading the view.
    
    [textField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];

    // setup util
    util = [[ViewControllerUtil alloc] init];
    [self.view addSubview:util.indicator];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)textFieldChanged:(id)sender
{
    if (textField.text.length > 0)
    {
        searchButton.enabled = YES;
    }
    else
    {
        searchButton.enabled = NO;
    }
}

- (IBAction)searchButtonPressed:(id)sender
{
    [textField resignFirstResponder];
    
    [self searchUser:textField.text];
}

- (void)searchUser:(NSString *)text
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSearchUser:) name:VKLocalPlayerDidOnSearchUserCalledNotification object:nil];
    
    VKLocalPlayer * localPlayer = VKLocalPlayer::localPlayer();
    LocalPlayerHandlers *handler = LocalPlayerHandlers::sharedInstance();
    
    localPlayer->searchUserByEmail(text.UTF8String, handler);
    [util showIndicator];
}

- (void)onSearchUser:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VKLocalPlayerDidOnSearchUserCalledNotification object:nil];
    [self performSelectorOnMainThread:@selector(hideIndicator) withObject:nil waitUntilDone:NO];
    
    // check error
    NSString *error = [[aNotification userInfo] objectForKey:@"Error"];
    if (error != nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"사용자 검색 실패" message:error delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
        [self performSelectorOnMainThread:@selector(showAlert:) withObject:alert waitUntilDone:NO];
    }
    else
    {
        User *user = [[aNotification userInfo] objectForKey:@"User"];
        [self performSelectorOnMainThread:@selector(pushViewController:) withObject:user waitUntilDone:NO];
    }
}

- (void)hideIndicator
{
    [util hideIndicator];
}

- (void)showAlert:(UIAlertView *)alert
{
    [alert show];
}

- (void)pushViewController:(User *)user
{
    UIStoryboard *storyboard = self.navigationController.storyboard;
    ShowUserViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ShowUserViewController"];
    viewController.user = user;
    [self.navigationController pushViewController:viewController animated:YES];    
}

@end
