//
//  User.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 20..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 This class is for a user.
 */
@interface User : NSObject
{
    NSString *userID;
    NSString *email;
    UIImage *photo;
    NSString *name;
    // status message
    NSString *status;
}

@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) UIImage *photo;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *status;

@end
