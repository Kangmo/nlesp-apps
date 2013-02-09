//
//  ConvertUtils.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 18..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#ifndef ThxTalk_Utils_h
#define ThxTalk_Utils_h

#include "User.h"
#include "Basement.h"
#include "VKLocalPlayer.h"

// convert functions

NSString * convertTxStringToNSString(const TxString &str);

UIImage * convertTxImageToUIImage(const TxImage &image);

User * convertTxUserProfileToUser(VKLocalPlayer::TxUserProfile userProfile);

#endif
