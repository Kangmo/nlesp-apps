//
//  AppDelegate.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 19..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "ChatListViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    User *myProfile;
    NSMutableArray *friendList;
    NSString *myUserID;

    /*
     When this app is opened by remote notification,
     This variable is set to the match ID
     to open the chat room immediately.
     */
    NSString *gotoChatRoomMatchID;
    
    ChatListViewController *chatListViewController;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) User *myProfile;
@property (strong, nonatomic) NSMutableArray *friendList;
@property (strong, nonatomic) NSString *myUserID;
@property (strong, nonatomic) NSString *gotoChatRoomMatchID;
@property (strong, nonatomic) ChatListViewController *chatListViewController;

/*
 This function returns a user object of the specified id if exist in friend list. 
 Otherwise, it returns nil.
 */
- (User *)getFriend:(NSString *)userID;

/*
 This function saves a user info who is not my friend.
 */
- (void)addUser:(User *)user;

/*
 This function returns a user object if it is exist in friend list or user list.
 */
- (User *)getUser:(NSString *)userID;

/*
 This function sends request to server to get my profile and friends data.
 */
- (void)requestData;

@end
