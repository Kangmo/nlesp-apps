//
//  ShowUserViewController.m
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 20..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import "ShowUserViewController.h"
#import "AppDelegate.h"
#import "VKLocalPlayer.h"
#import "LocalPlayerHandlers.h"
#import "NotificationNames.h"
#import "ViewControllerUtil.h"

@interface ShowUserViewController ()
{
    ViewControllerUtil *util;
}
@end

@implementation ShowUserViewController

@synthesize user;
@synthesize imageView, nameLabel, statusLabel, button;

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
    imageView.image = user.photo;
    nameLabel.text = user.name;
    statusLabel.text = user.status;
    self.title = user.email;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    User *myProfile = appDelegate.myProfile;
    if ([myProfile.userID isEqualToString:user.userID])
    {
        [button setTitle:@"본인입니다." forState:UIControlStateNormal];
        button.enabled = NO;
    }
    else if ([self isMyFriend])
    {
        [button setTitle:@"이미 등록된 친구입니다." forState:UIControlStateNormal];
        button.enabled = NO;
    }

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

- (BOOL)isMyFriend
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    User *aUser = [appDelegate getFriend:user.userID];
    return aUser? YES : NO;
}

- (IBAction)addButtonPressed:(id)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRequestFriend:) name:VKLocalPlayerDidOnRequestFriendCalledNotification object:nil];
    
    VKLocalPlayer * localPlayer = VKLocalPlayer::localPlayer();
    LocalPlayerHandlers *handler = LocalPlayerHandlers::sharedInstance();
    
    localPlayer->requestFriend(user.userID.UTF8String, handler);
    [util showIndicator];
}

- (void)onRequestFriend:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VKLocalPlayerDidOnRequestFriendCalledNotification object:nil];
    [self performSelectorOnMainThread:@selector(hideIndicator) withObject:nil waitUntilDone:NO];
    
    // check error
    NSString *error = [[aNotification userInfo] objectForKey:@"Error"];
    if (error != nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"친구 추가 실패" message:error delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
        [self performSelectorOnMainThread:@selector(showAlert:) withObject:alert waitUntilDone:NO];
    }
    else
    {
        User *addedUser = [[aNotification userInfo] objectForKey:@"User"];
        NSMutableArray *friendList = ((AppDelegate *)[UIApplication sharedApplication].delegate).friendList;
        [friendList addObject:addedUser];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"친구가 추가되었습니다." delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
        [self performSelectorOnMainThread:@selector(showAlert:) withObject:alert waitUntilDone:NO];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)hideIndicator
{
    [util hideIndicator];
}

- (void)showAlert:(UIAlertView *)alert
{
    [alert show];
}

@end
