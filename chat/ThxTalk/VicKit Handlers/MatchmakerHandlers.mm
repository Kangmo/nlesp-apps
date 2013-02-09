
//  MatchmakerHandlers.mm
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 12..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#include "MatchmakerHandlers.h"
#include "NotificationNames.h"
#include "VKMatchWrapper.h"
#include "MatchDelegate.h"
#include "ConvertUtils.h"
#include "VKInviteWrapper.h"

MatchmakerHandlers * MatchmakerHandlers::sharedInstance()
{
    static MatchmakerHandlers *instance = NULL;
    if (instance == NULL)
    {
        instance = new MatchmakerHandlers();
    }
    return instance;
}

// handlers

void MatchmakerHandlers::onFindMatch(VKMatch * match, VKError * error)
{
    @autoreleasepool{
        NSDictionary *dic;
        if (error != NULL)
        {
            dic = [[NSDictionary alloc] initWithObjectsAndKeys:convertTxStringToNSString(error->errorMessage()), @"Error", nil];
        }
        else
        {
            VKMatchWrapper *matchWrapper = [[VKMatchWrapper alloc] init];
            MatchDelegate *delegate = MatchDelegate::sharedInstance();
            match->delegate(delegate);
            matchWrapper.match = match;
            
            NSLog(@"MatchmakerHandlers::onFindMatch matchID=%lli", match->matchId());
            
            dic = [[NSDictionary alloc] initWithObjectsAndKeys:matchWrapper, @"Match", nil];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VKMatchmakerDidOnFindMatchCalledNotification object:nil userInfo:dic];
    }
}

void MatchmakerHandlers::onInvite(VKInvite * acceptedInvite, TxStringArray * playersToInvite)
{
    @autoreleasepool{
        NSLog(@"MatchmakerHandlers::onInvite");
        if (acceptedInvite)
        {
            NSLog(@"MatchmakerHandlers::onInvite inviter=%@, matchid=%lli", [NSString stringWithUTF8String:acceptedInvite->inviter().c_str()],acceptedInvite->matchId());
            VKInviteWrapper *inviteWrapper = [[VKInviteWrapper alloc] init];
            inviteWrapper.invite = acceptedInvite;
            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:inviteWrapper, @"Invite", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:VKMatchmakerDidOnInviteCalledNotification object:nil userInfo:dic];
        }
    }
}

void MatchmakerHandlers::onMatchForInvite(VKMatch * match, VKError * error)
{
    @autoreleasepool{
        NSDictionary *dic;
        if (error != NULL)
        {
            dic = [[NSDictionary alloc] initWithObjectsAndKeys:convertTxStringToNSString(error->errorMessage()), @"Error", nil];
        }
        else
        {
            VKMatchWrapper *matchWrapper = [[VKMatchWrapper alloc] init];
            MatchDelegate *delegate = MatchDelegate::sharedInstance();
            match->delegate(delegate);
            matchWrapper.match = match;
            
            dic = [[NSDictionary alloc] initWithObjectsAndKeys:matchWrapper, @"Match", nil];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VKMatchmakerDidOnMatchForInviteCalledNotification object:nil userInfo:dic];
    }
}

