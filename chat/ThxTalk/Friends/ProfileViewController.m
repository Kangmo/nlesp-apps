//
//  ProfileViewController.m
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 21..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import "ProfileViewController.h"
#import "FriendListViewController.h"
#import "ChatListViewController.h"
#import "AppDelegate.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

@synthesize user;
@synthesize isMyProfile;
@synthesize imageView, nameLabel, statusLabel;
@synthesize button;
@synthesize transparentView;

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
    if (isMyProfile)
    {
        [button setTitle:@"내 프로필 편집" forState:UIControlStateNormal];
    }
    else
    {
        [button setTitle:@"1:1 채팅" forState:UIControlStateNormal];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
    UIView *view = [self.view.subviews objectAtIndex:0];
    view.hidden = NO;
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [transparentView addGestureRecognizer:singleFingerTap];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dismissViewController
{
    UIView *view = [self.view.subviews objectAtIndex:0];
    view.hidden = YES;
    [self dismissModalViewControllerAnimated:YES];    
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    [self dismissViewController];
}

- (IBAction)buttonPressed:(id)sender
{
    if (isMyProfile)
    {
        FriendListViewController *viewController = (FriendListViewController *)((UINavigationController *)((UITabBarController *)self.presentingViewController).selectedViewController).topViewController;
        viewController.showEditProfile = YES;
        [self performSelectorOnMainThread:@selector(dismissViewController) withObject:nil waitUntilDone:NO];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(dismissViewController) withObject:nil waitUntilDone:NO];
        UITabBarController *tabBarController = (UITabBarController *)(self.presentingViewController);
        //UINavigationController *navController = (UINavigationController *)[tabBarController.viewControllers objectAtIndex:1];
        //ChatListViewController *chatListVC = (ChatListViewController *)navController.topViewController;
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        ChatListViewController *chatListVC = appDelegate.chatListViewController;
        chatListVC.gotoChatRoomUserID = user.userID;
        [tabBarController setSelectedIndex:1];
    }
}

@end
