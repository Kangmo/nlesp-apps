//
//  EditViewController.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 21..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 This class is to edit name and status message.
 */
@interface EditViewController : UIViewController <UITextFieldDelegate>
{
    // YES to edit name, NO to edit status message.
    BOOL isName;
    IBOutlet UILabel *infoLabel;
    IBOutlet UITextField *textField;
    IBOutlet UILabel *charNumLabel;
    IBOutlet UIBarButtonItem *doneButton;
}

@property BOOL isName;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UILabel *charNumLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end
