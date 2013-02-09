//
//  ChatRoomViewController.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 27..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKMatch.h"

/*
 This class shows chat messages.
 Both chat tab and location chat tab use this class.
 */
@interface ChatRoomViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *myTableView;
    IBOutlet UITextView *textView;
    IBOutlet UIButton *button;

    /* An array of messages.
     A message is a NSDictionary object which contains "UserID", "Message", and "Date"
     */
    NSMutableArray *messages;
    VKMatch *match;
}

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) NSMutableArray *messages;
@property VKMatch *match;

@end
