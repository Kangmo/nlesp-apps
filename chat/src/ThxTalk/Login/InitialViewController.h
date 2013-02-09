//
//  InitialViewController.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 11..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 This class is to check the user is member or not.
 If the user is member and signed in, move to main view.
 Otherwise, show selection create user / sign in.
 */
@interface InitialViewController : UIViewController
{
    IBOutlet UIButton *createUserButton;
    IBOutlet UIButton *logInButton;
}

@property(nonatomic, strong) IBOutlet UIButton *createUserButton;
@property(nonatomic, strong) IBOutlet UIButton *logInButton;

@end
