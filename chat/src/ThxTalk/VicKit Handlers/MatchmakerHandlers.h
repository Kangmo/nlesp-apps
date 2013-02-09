//
//  MatchmakerHandlers.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 12..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#ifndef ThxTalk_MatchmakerHandlers_h
#define ThxTalk_MatchmakerHandlers_h

#include "VKMatchmaker.h"

class MatchmakerHandlers :
public VKMatchmaker::FindMatchHandler,
public VKMatchmaker::InviteHandler,
public VKMatchmaker::MatchForInviteHandler
{
public:
    static MatchmakerHandlers * sharedInstance();
    MatchmakerHandlers() {};
    virtual ~MatchmakerHandlers() {};
    
    virtual void onFindMatch(VKMatch * match, VKError * error);
    virtual void onInvite(VKInvite * acceptedInvite, TxStringArray * playersToInvite);
    virtual void onMatchForInvite(VKMatch * match, VKError * error);
};

#endif
