#include <VicKit/VKMatch.h>

VKMatch::VKMatch()
{
    
}
VKMatch::~VKMatch()
{
}

// Asynchronously send data to one or more players. Returns YES if delivery started, NO if unable to start sending and error will be set.
bool VKMatch::sendData( const TxData & data, const TxStringArray & playerIDs, VKMatchSendDataMode dataMode, TxError ** error)
{
    return true;
}

// Asynchronously broadcasts data to all players. Returns YES if delivery started, NO if unable to start sending and error will be set.
bool VKMatch::sendDataToAllPlayers( const TxData & data, VKMatchSendDataMode dataMode, TxError ** error)
{
    return true;
}

// Disconnect the match. This will show all other players in the match that the local player has disconnected. This should be called before releasing the match instance.
void VKMatch::disconnect()
{
    
}
