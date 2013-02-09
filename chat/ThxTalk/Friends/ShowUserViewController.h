//
//  ShowUserViewController.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 20..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

/*
 This class shows search result. (a user)
 */
@interface ShowUserViewController : UIViewController <UIAlertViewDelegate>
{
    User *user;
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *statusLabel;
    IBOutlet UIButton *button;
}

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIButton *button;

@end
