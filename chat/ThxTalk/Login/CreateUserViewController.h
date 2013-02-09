//
//  CreateUserViewController.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 11..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 This class is to sign up.
 */
@interface CreateUserViewController : UITableViewController
{
    IBOutlet UITextField *nameField;
    IBOutlet UITextField *emailField;
    IBOutlet UITextField *pwField;
    IBOutlet UITextField *pw2Field;
    IBOutlet UIButton *button;
}

@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *pwField;
@property (strong, nonatomic) IBOutlet UITextField *pw2Field;
@property (strong, nonatomic) IBOutlet UIButton *button;

@end
