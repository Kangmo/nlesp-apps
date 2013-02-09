//
//  AppDelegate.m
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 19..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import "AppDelegate.h"
#import "VKLocalPlayer.h"
#import "LocalPlayerHandlers.h"
#import "NotificationNames.h"
#import "VicKit.h"

@interface AppDelegate()
{
    BOOL profileDataReceived;
    BOOL friendsDataReceived;
    NSMutableArray *userList;
}
@end

@implementation AppDelegate

@synthesize myProfile;
@synthesize friendList;
@synthesize myUserID;
@synthesize gotoChatRoomMatchID;
@synthesize chatListViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    // register remote notification
    UIRemoteNotificationType myTypes = (UIRemoteNotificationType)(UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge);
    [application registerForRemoteNotificationTypes:myTypes];
    
    // if the app is opened by notification
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo)
    {
        NSString *matchID = @"";
        gotoChatRoomMatchID = matchID;
    }
    else
    {
        gotoChatRoomMatchID = nil;
    }
    userList = [[NSMutableArray alloc] init];
    
    // initialize VicKitSystem
    VicKitSystem::initialize();

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - remote notification

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // send device token to server
    NSLog(@"%@ token = %@", NSStringFromSelector(_cmd), [deviceToken description]);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@ with error = %@", NSStringFromSelector(_cmd), error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"%@ with payload = %@", NSStringFromSelector(_cmd), userInfo);
}

- (User *)getFriend:(NSString *)userID
{
    User *result = nil;
    
    for (User *user in friendList)
    {
        if ([userID isEqualToString:user.userID])
        {
            result = user;
            break;
        }
    }
    
    return result;
}

- (void)addUser:(User *)user
{
    [userList addObject:user];
}

- (User *)getUser:(NSString *)userID
{
    User * result = [self getFriend:userID];
    if (!result)
    {
        for (User *aUser in userList)
        {
            if ([userID isEqualToString:aUser.userID])
            {
                result = aUser;
                break;
            }
        }
    }
    return result;
}

#pragma mark - server request

- (void)requestData
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoadUserProfile:) name:VKLocalPlayerDidOnLoadUserProfileCalledNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoadFriendProfiles:) name:VKLocalPlayerDidOnLoadFriendProfilesCalledNotification object:nil];
    
    VKLocalPlayer * localPlayer = VKLocalPlayer::localPlayer();
    LocalPlayerHandlers *handler = LocalPlayerHandlers::sharedInstance();
    
    // get my profile
    localPlayer->loadUserProfile(myUserID.UTF8String, handler);
    
    // get friend profiles
    localPlayer->loadFriendProfiles(myUserID.UTF8String, handler);
    
    profileDataReceived = NO;
    friendsDataReceived = NO;
}

#pragma mark - server response

- (void)onLoadUserProfile:(NSNotification *)aNotification
{
    NSLog(@"%@:%@ called", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    // check error
    NSString *error = [[aNotification userInfo] objectForKey:@"Error"];
    if (error != nil)
    {
        NSLog(@"%@:%@ error = %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);
        [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateRequestDataFinishedNotification object:nil userInfo:aNotification.userInfo];
    }
    else
    {
        User *aUser = [[aNotification userInfo] objectForKey:@"UserProfile"];
        if ([aUser.userID isEqualToString:myUserID])
        {
            myProfile = aUser;
            NSLog(@"myProfile: %@", myProfile);
            profileDataReceived = YES;
        }
    
        if (profileDataReceived && friendsDataReceived)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateRequestDataFinishedNotification object:nil userInfo:aNotification.userInfo];
        }
    }
}

- (void)onLoadFriendProfiles:(NSNotification *)aNotification
{
    NSLog(@"%@:%@ called", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    [[NSNotificationCenter defaultCenter] removeObserver:self name:VKLocalPlayerDidOnLoadFriendProfilesCalledNotification object:nil];
    
    // check error
    NSString *error = [[aNotification userInfo] objectForKey:@"Error"];
    if (error != nil)
    {
        NSLog(@"%@:%@ error = %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);

        [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateRequestDataFinishedNotification object:nil userInfo:aNotification.userInfo];
    }
    else
    {
        friendList = [[aNotification userInfo] objectForKey:@"FriendProfiles"];
    
        friendsDataReceived = YES;
        if (profileDataReceived && friendsDataReceived)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateRequestDataFinishedNotification object:nil userInfo:aNotification.userInfo];
        }
    }
}

@end
