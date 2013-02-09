//
//  ChatListItem.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 27..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "VKMatch.h"

@interface ChatListItem : NSObject
{
    long long matchID;
    VKMatch *match;
    User *user;
    int newChatNum;
    NSMutableArray *messages;
    NSString *lastMessage;
    NSDate *lastMessageDate;
    NSString *userID;
}

@property long long matchID;
@property VKMatch *match;
@property (strong, nonatomic) User *user;
@property int newChatNum;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSString *lastMessage;
@property (strong, nonatomic) NSDate *lastMessageDate;
@property (strong, nonatomic) NSString *userID;

@end
