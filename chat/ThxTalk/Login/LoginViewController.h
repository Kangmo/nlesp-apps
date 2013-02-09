//
//  LoginViewController.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 29..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 This class is to log in.
 */
@interface LoginViewController : UITableViewController
{
    IBOutlet UITextField *emailField;
    IBOutlet UITextField *pwField;
    IBOutlet UIButton *button;
}

@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *pwField;
@property (strong, nonatomic) IBOutlet UIButton *button;

@end
