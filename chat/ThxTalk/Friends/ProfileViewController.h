//
//  ProfileViewController.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 21..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

/*
 This class shows a user's profile.
 */
@interface ProfileViewController : UIViewController
{
    User *user;
    
    // YES to show my profile, NO to show a friend's profile.
    BOOL isMyProfile;
    
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *statusLabel;
    IBOutlet UIButton *button;
    IBOutlet UIView *transparentView;
}

@property (strong, nonatomic) User *user;
@property BOOL isMyProfile;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) IBOutlet UIView *transparentView;

@end
