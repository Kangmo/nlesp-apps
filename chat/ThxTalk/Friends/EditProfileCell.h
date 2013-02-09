//
//  EditProfileCell.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 21..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditProfileCell : UITableViewCell
{
    IBOutlet UIButton *button;
    IBOutlet UILabel *IDLabel;
}

@property (strong, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) IBOutlet UILabel *IDLabel;

@end
