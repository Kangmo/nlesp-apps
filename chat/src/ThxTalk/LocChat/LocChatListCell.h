//
//  LocChatListCell.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 11..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocChatListCell : UITableViewCell
{
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *locNameLabel;
    IBOutlet UILabel *locNicknameLabel;
    IBOutlet UIButton *startChatButton;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *locNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *locNicknameLabel;
@property (strong, nonatomic) IBOutlet UIButton *startChatButton;

@end
