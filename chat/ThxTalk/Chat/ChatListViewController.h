//
//  ChatListViewController.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 27..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 This class is for chat tab of main tab bar view.
 */

@interface ChatListViewController : UITableViewController
{
    /*
     When a user selects '1:1 채팅' button of friend's profile,
     chat list tab is selected and open chat room immediately.
     If this variable is set to user id, open chat room immediately.
     */
    NSString *gotoChatRoomUserID;
    
    /*
     When this app is opened by remote notification,
     This variable is set to the match ID
     to open the chat room immediately.
     */
    NSString *gotoChatRoomMatchID;
}

@property (strong, nonatomic) NSString *gotoChatRoomUserID;
@property (strong, nonatomic) NSString *gotoChatRoomMatchID;

@end
