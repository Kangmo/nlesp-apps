//
//  VKMatchWrapper.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 17..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKMatch.h"

/*
 This class is a wrapper to add a VKMatch object into NSDictionary.
 */
@interface VKMatchWrapper : NSObject
{
    VKMatch *match;
}

@property VKMatch *match;

@end
