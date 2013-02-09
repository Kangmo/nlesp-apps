//
//  Message.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 18..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject
{
    NSString *text;
    NSString *userID;
    NSDate *date;
}

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSDate *date;

@end
