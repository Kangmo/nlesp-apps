#include <VicKit/VKLocalPlayer.h>
#include "VKInternals.h"


TxString VKPlayerAuthenticationDidChangeNotificationName;

VKLocalPlayer & VKLocalPlayer::localPlayer() 
{
    static VKLocalPlayer * theLocalPlayer = NULL;
    if ( theLocalPlayer == NULL ) 
    {
        theLocalPlayer = new VKLocalPlayer();
    }
    return *theLocalPlayer;
}

VKLocalPlayer::VKLocalPlayer()
{
    // TODO : Implement Authentication
    authenticated_ = true;
}

VKLocalPlayer::~VKLocalPlayer()
{
    
}

void VKLocalPlayer::authenticate(AuthenticateCompletionHandler * handler)
{
    VK_ASSERT(handler);
    // TODO : Implement Authentication
    handler->onCompleteAuthenticate(NULL);
}

void VKLocalPlayer::loadFriends(LoadFriendsCompletionHandler * handler)
{
    VK_ASSERT(handler);
    
}
