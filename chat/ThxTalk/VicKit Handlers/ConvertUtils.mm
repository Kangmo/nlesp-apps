//
//  ConvertUtils.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 18..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#include "ConvertUtils.h"

// convert functions

NSString * convertTxStringToNSString(const TxString &str)
{
    return [NSString stringWithUTF8String:str.c_str()];
}

UIImage * convertTxImageToUIImage(const TxImage &image)
{
    return [UIImage imageWithData:[NSData dataWithBytes:image.bytes() length:image.length()]];
}

User * convertTxUserProfileToUser(VKLocalPlayer::TxUserProfile userProfile)
{
    User *user = [[User alloc] init];
    user.userID = convertTxStringToNSString(userProfile.uid);
    user.email = convertTxStringToNSString(userProfile.email);
    user.name = convertTxStringToNSString(userProfile.name);
    user.status = convertTxStringToNSString(userProfile.statusMessage);
    user.photo = convertTxImageToUIImage(userProfile.photo);
    
    return user;
}
