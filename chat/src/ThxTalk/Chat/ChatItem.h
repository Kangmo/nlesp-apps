//
//  ChatItem.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 27..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

typedef enum
{
    ChatItemType_date,
    ChatItemType_fromMe,
    ChatItemType_fromFriend
} ChatItemType;

@interface ChatItem : NSObject
{
    ChatItemType type;
    NSString *dateStr;
    User *user;
    NSString *content;
    NSString *timeStr;
}

@property ChatItemType type;
@property (strong, nonatomic) NSString *dateStr;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *timeStr;

@end
