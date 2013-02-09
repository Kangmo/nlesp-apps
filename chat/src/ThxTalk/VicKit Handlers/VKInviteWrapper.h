//
//  VKInviteWrapper.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 18..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKMatchmaker.h"

/*
This class is a wrapper to add a VKInvite object into NSDictionary.
*/
@interface VKInviteWrapper : NSObject
{
    VKInvite *invite;
}

@property VKInvite *invite;

@end
