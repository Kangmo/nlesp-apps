//
//  LocalPlayerHandlers.cpp
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 12..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#include "LocalPlayerHandlers.h"
#include "NotificationNames.h"
#include "ConvertUtils.h"

LocalPlayerHandlers * LocalPlayerHandlers::sharedInstance()
{
    static LocalPlayerHandlers *instance = NULL;
    if (instance == NULL)
    {
        instance = new LocalPlayerHandlers();
    }
    return instance;
}

// handlers

void LocalPlayerHandlers::onAuthenticate(VKError * error)
{
    @autoreleasepool {
        NSDictionary *dic;
        
        if (error != NULL) {
            dic = [[NSDictionary alloc] initWithObjectsAndKeys:convertTxStringToNSString(error->errorMessage()), @"Error", nil];
        }
        else
        {
            dic = [[NSDictionary alloc] init];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VKLocalPlayerDidOnAuthenticateCalledNotification object:nil userInfo:dic];
    }
}


void LocalPlayerHandlers::onCreateUserProfile(const TxString & uid, VKError * error)
{
    @autoreleasepool{
        NSDictionary *dic;
        
        if (error != NULL) {
            dic = [[NSDictionary alloc] initWithObjectsAndKeys:convertTxStringToNSString(error->errorMessage()), @"Error", nil];
        }
        else
        {
            NSString *userID = convertTxStringToNSString(uid);
            NSLog(@"onCreateUserProfile: %@", userID);
            dic = [[NSDictionary alloc] initWithObjectsAndKeys:userID, @"UserID", nil];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VKLocalPlayerDidOnCreateUserProfileCalledNotification object:nil userInfo:dic];
    }
}

void LocalPlayerHandlers::onLoadUserProfile(const VKLocalPlayer::TxUserProfile & userProfile, VKError * error)
{
    @autoreleasepool{
        NSDictionary *dic;
        
        if (error != NULL)
        {
            dic = [[NSDictionary alloc] initWithObjectsAndKeys:convertTxStringToNSString(error->errorMessage()), @"Error", nil];
        }
        else
        {
            User *user = convertTxUserProfileToUser(userProfile);
            dic = [[NSDictionary alloc] initWithObjectsAndKeys:user, @"UserProfile", nil];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VKLocalPlayerDidOnLoadUserProfileCalledNotification object:nil userInfo:dic];
    }
}

void LocalPlayerHandlers::onLoadFriendProfiles(const std::vector<VKLocalPlayer::TxUserProfile> friendProfiles, VKError * error)
{
    @autoreleasepool{
        NSDictionary *dic;
        if (error != NULL)
        {
            dic = [[NSDictionary alloc] initWithObjectsAndKeys:convertTxStringToNSString(error->errorMessage()), @"Error", nil];
        }
        else
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 0; i < friendProfiles.size(); i++)
            {
                VKLocalPlayer::TxUserProfile userProfile = friendProfiles[i];
                User *user = convertTxUserProfileToUser(userProfile);
                [array addObject:user];
            }
            
            dic = [[NSDictionary alloc] initWithObjectsAndKeys:array, @"FriendProfiles", nil];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VKLocalPlayerDidOnLoadFriendProfilesCalledNotification object:nil userInfo:dic];
    }
}

void LocalPlayerHandlers::onUpdateUserProfile(VKError * error)
{
    @autoreleasepool{
        NSDictionary *dic;
        if (error != NULL)
        {
            dic = [[NSDictionary alloc] initWithObjectsAndKeys:convertTxStringToNSString(error->errorMessage()), @"Error", nil];
        }
        else
        {
            dic = [[NSDictionary alloc] init];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VKLocalPlayerDidOnUpdateUserProfileCalledNotification object:nil userInfo:dic];
    }
}

void LocalPlayerHandlers::onSearchUser(const std::vector<VKLocalPlayer::TxUserProfile> & userProfiles, VKError * error)
{
    @autoreleasepool{
        NSDictionary *dic;
        if (error != NULL)
        {
            dic = [[NSDictionary alloc] initWithObjectsAndKeys:convertTxStringToNSString(error->errorMessage()), @"Error", nil];
        }
        else
        {
            if (userProfiles.size() > 0)
            {
                VKLocalPlayer::TxUserProfile userProfile = userProfiles[0];
                User *user = convertTxUserProfileToUser(userProfile);
                dic = [[NSDictionary alloc] initWithObjectsAndKeys:user, @"User", nil];
            }
            else
            {
                dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"입력하신 아이디로 등록한 회원이 없거나 검색이 허용되지 않는 회원입니다.", @"Error", nil];
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VKLocalPlayerDidOnSearchUserCalledNotification object:nil userInfo:dic];
        
    }}

void LocalPlayerHandlers::onRequestFriend(const VKLocalPlayer::TxUserProfile & userProfile, VKError * error)
{
    @autoreleasepool{
        NSDictionary *dic;
        if (error != NULL)
        {
            dic = [[NSDictionary alloc] initWithObjectsAndKeys:convertTxStringToNSString(error->errorMessage()), @"Error", nil];
        }
        else
        {
            User *user = convertTxUserProfileToUser(userProfile);
            dic = [[NSDictionary alloc] initWithObjectsAndKeys:user, @"User", nil];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VKLocalPlayerDidOnRequestFriendCalledNotification object:nil userInfo:dic];
    }
}

void LocalPlayerHandlers::onCancelFriend(const TxString & uid, VKError * error)
{
    @autoreleasepool{
        NSDictionary *dic;
        if (error != NULL)
        {
            dic = [[NSDictionary alloc] initWithObjectsAndKeys:convertTxStringToNSString(error->errorMessage()), @"Error", nil];
        }
        else
        {
            NSString *userID = convertTxStringToNSString(uid);
            dic = [[NSDictionary alloc] initWithObjectsAndKeys:userID, @"UserID", nil];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VKLocalPlayerDidOnCancelFriendCalledNotification object:nil userInfo:dic];
    }
}

