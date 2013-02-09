//
//  LocalPlayerHandlers.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 12..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#ifndef ThxTalk_LocalPlayerHandlers_h
#define ThxTalk_LocalPlayerHandlers_h

#include "VKLocalPlayer.h"

class LocalPlayerHandlers :
public VKLocalPlayer::AuthenticateHandler,
public VKLocalPlayer::CreateUserProfileHandler,
public VKLocalPlayer::LoadUserProfileHandler,
public VKLocalPlayer::LoadFriendProfilesHandler,
public VKLocalPlayer::UpdateUserProfileHandler,
public VKLocalPlayer::SearchUserHandler,
public VKLocalPlayer::RequestFriendHandler,
public VKLocalPlayer::CancelFriendHandler
{
public:
    static LocalPlayerHandlers * sharedInstance();
    LocalPlayerHandlers() {};
    virtual ~LocalPlayerHandlers() {};
    
    virtual void onAuthenticate( VKError * error );
    virtual void onCreateUserProfile(const TxString & uid, VKError * error);
    virtual void onLoadUserProfile(const VKLocalPlayer::TxUserProfile & userProfile, VKError * error);
    virtual void onLoadFriendProfiles(const std::vector<VKLocalPlayer::TxUserProfile> friendProfiles, VKError * error);
    virtual void onUpdateUserProfile(VKError * error);
    virtual void onSearchUser(const std::vector<VKLocalPlayer::TxUserProfile> & userProfiles, VKError * error);
    virtual void onRequestFriend(const VKLocalPlayer::TxUserProfile & uid, VKError * error);
    virtual void onCancelFriend(const TxString & uid, VKError * error);
};

#endif
