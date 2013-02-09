//
//  User.m
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 20..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize email, photo, name, status;
@synthesize userID;

- (NSString *)description
{
    return [NSString stringWithFormat:@"userID: %@, email: %@, name: %@, status: %@", userID, email, name, status];
}

@end
