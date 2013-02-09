//
//  MyChatMessageCell.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 27..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyChatMessageCell : UITableViewCell
{
    IBOutlet UILabel *contentLabel;;
    IBOutlet UIImageView *textBgImageView;
    IBOutlet UILabel *timeLabel;
}

@property (strong, nonatomic) IBOutlet UILabel *contentLabel;;
@property (strong, nonatomic) IBOutlet UIImageView *textBgImageView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@end
