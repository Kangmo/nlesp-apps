//
//  FriendListViewController.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 19..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 This class is for friend tab of main tab bar view.
 */
@interface FriendListViewController : UITableViewController
{
    /*
     When a user selects '내 프로필 편집' button of my profile,
     friend list tab is selected and open edit profile immediately.
     Set this variable to YES to show edit profile.
     */
    BOOL showEditProfile;
}

@property BOOL showEditProfile;

@end
