#include <VicKit/VKMatchmaker.h>
#include "VKInternals.h"

VKMatchmaker & VKMatchmaker::sharedMatchmaker()
{
    static VKMatchmaker * theMatchmaker = NULL;
    
    if ( theMatchmaker == NULL ) 
    {
        theMatchmaker = new VKMatchmaker();
    }
    return *theMatchmaker;    
}

void VKMatchmaker::findMatch(const VKMatchRequest & request, FindMatchCompletionHandler * handler)
{
    VK_ASSERT(handler);
    
}

void VKMatchmaker::findPlayersForHostedMatchRequest(const VKMatchRequest & request, FindPlayersCompletionHandler * handler)
{
    VK_ASSERT(handler);
}

void VKMatchmaker::addPlayers(VKMatch * match, const VKMatchRequest & matchRequest, AddPlayersCompletionHandler * handler)
{
    VK_ASSERT(handler);
}

void VKMatchmaker::cancel()
{
    
}

void VKMatchmaker::queryPlayerGroupActivity(unsigned int playerGroup, QueryPlayerGroupActivityCompletionHandler * handler)
{
    VK_ASSERT(handler);
}

void VKMatchmaker::queryActivity(QueryActivityCompletionHandler * handler)
{
    VK_ASSERT(handler);
}
