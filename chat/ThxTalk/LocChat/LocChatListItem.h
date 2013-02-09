//
//  LocChatListItem.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 11..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "VKMatch.h"

@interface LocChatListItem : NSObject
{
    long long matchID;
    VKMatch *match;
    CLLocation *location;
    NSString *locName;
    NSString *locNickname;
    NSMutableArray *messages;
    int newChatNum;
    CLLocationDistance distance;
}

@property long long matchID;
@property VKMatch *match;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSString *locName;
@property (strong, nonatomic) NSString *locNickname;
@property (strong, nonatomic) NSMutableArray *messages;
@property int newChatNum;
@property CLLocationDistance distance;

@end
