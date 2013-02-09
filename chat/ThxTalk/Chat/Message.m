//
//  Message.m
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 18..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import "Message.h"

@implementation Message

@synthesize text, userID, date;

- (NSString *)description
{
    return [NSString stringWithFormat:@"Message text=%@, userID=%@, date=%@", text, userID, date];
}
@end
