#include <VicKit/VKPlayer.h>
#include "VKInternals.h"

TxString VKPlayerDidChangeNotificationName;


void VKPlayer::loadPlayers(const TxStringArray & identifiers, LoadPlayersCompletionHandler * handler)
{
    VK_ASSERT(handler);
}

void VKPlayer::loadPhoto(VKPhotoSize size, LoadPhotoCompletionHandler * handler)
{
    VK_ASSERT(handler);
}
