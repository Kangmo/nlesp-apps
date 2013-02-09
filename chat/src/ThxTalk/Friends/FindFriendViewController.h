//
//  FindFriendViewController.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 20..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 This class is for search a friend.
 */
@interface FindFriendViewController : UIViewController
{
    IBOutlet UIBarButtonItem *searchButton;
    IBOutlet UITextField *textField;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *searchButton;
@property (strong, nonatomic) IBOutlet UITextField *textField;

@end
