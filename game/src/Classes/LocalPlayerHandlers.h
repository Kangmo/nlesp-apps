//
//  LocalPlayerHandlers.h
//  Tilemap
//
//  Created by 민경 장 on 12. 10. 19..
//
//

#ifndef Tilemap_LocalPlayerHandlers_h
#define Tilemap_LocalPlayerHandlers_h

#include "VKLocalPlayer.h"

class LocalPlayerHandlers :
public VKLocalPlayer::CreateUserProfileHandler
{
public:
    LocalPlayerHandlers() {};
    virtual ~LocalPlayerHandlers() {};
    
    virtual void onCreateUserProfile(const TxString & uid, VKError *error);
    
}

#endif
