//
//  MatchDelegate.mm
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 17..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#include "MatchDelegate.h"
#include "ChatItem.h"
#include "NotificationNames.h"
#include "Message.h"

MatchDelegate * MatchDelegate::sharedInstance()
{
    static MatchDelegate *instance = NULL;
    if (instance == NULL)
    {
        instance = new MatchDelegate();
    }
    return instance;
}

void MatchDelegate::onReceiveData( VKMatch * match, const TxData & data, const TxString & playerID )
{
    @autoreleasepool{
        TxString string((const char *)data.bytes(), data.length());
        Message *message = [[Message alloc] init];
        message.text = [NSString stringWithUTF8String:string.c_str()];
        NSTimeInterval interval = (NSTimeInterval)data.timestamp()/1000;
        //NSLog(@"time interval = %f", interval);
        message.date = [NSDate dateWithTimeIntervalSince1970:interval];
        message.userID = [NSString stringWithUTF8String:playerID.c_str()];
        NSString *matchID = [NSString stringWithFormat:@"%lli", match->matchId()];
        
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                             message, @"Message",
                             matchID, @"MatchID",
                             nil];
        
        NSLog(@"MatchDelegate::onReceiveData message = %@", message);
        [[NSNotificationCenter defaultCenter] postNotificationName:VKMatchDelegateDidOnReceiveDataCalledNotification object:nil userInfo:dic];
    }
}
