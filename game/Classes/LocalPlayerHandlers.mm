//
//  LocalPlayerHandlers.mm
//  Tilemap
//
//  Created by 민경 장 on 12. 10. 19..
//
//

#include "LocalPlayerHandlers.h"
#include "NotificationNames.h"

void LocalPlayerHandlers::onCreateUserProfile(const TxString & uid, VKError * error)
{
    NSDictionary *dic;
    
    if (error != NULL) {
        NSString *errorStr = [NSString stringWithUTF8String:error->errorMessage().c_str()];
        dic = [[NSDictionary alloc] initWithObjectsAndKeys:errorStr, @"Error", nil];
    }
    else
    {
        NSString *userID = [NSString stringWithUTF8String:uid.c_str()];
        NSLog(@"onCreateUserProfile: %@", userID);
        dic = [[NSDictionary alloc] initWithObjectsAndKeys:userID, @"UserID", nil];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VKLocalPlayerDidOnCreateUserProfileCalledNotification object:nil userInfo:dic];
}