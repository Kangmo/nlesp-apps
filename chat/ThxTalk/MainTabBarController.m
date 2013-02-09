//
//  MainTabBarController.m
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 26..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import "MainTabBarController.h"
#import "AppDelegate.h"
#import "ChatListViewController.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

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
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate.gotoChatRoomMatchID)
    {
        //UINavigationController *navController = (UINavigationController *)[self.viewControllers objectAtIndex:1];
        //ChatListViewController *chatListVC = (ChatListViewController *)navController.topViewController;
        appDelegate.chatListViewController.gotoChatRoomMatchID = appDelegate.gotoChatRoomMatchID;
        [self setSelectedIndex:1];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
