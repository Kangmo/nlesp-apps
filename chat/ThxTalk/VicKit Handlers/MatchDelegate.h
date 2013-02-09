//
//  MatchDelegate.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 17..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#ifndef ThxTalk_MatchDelegate_h
#define ThxTalk_MatchDelegate_h

#include "VKMatch.h"

class MatchDelegate: public VKMatchDelegate
{
    public:
    static MatchDelegate * sharedInstance();
    MatchDelegate() {};
    virtual ~MatchDelegate() {};
    
    virtual void onReceiveData( VKMatch * match, const TxData & data, const TxString & playerID );
};

#endif
