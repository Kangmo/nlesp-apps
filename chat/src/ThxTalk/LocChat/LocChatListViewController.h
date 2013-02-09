//
//  LocChatListViewController.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 11..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

/*
 This class is for location tab of main tab bar view.
 */

@interface LocChatListViewController : UITableViewController <CLLocationManagerDelegate, UIAlertViewDelegate>
{
}

- (long long)getMatchIDFromLocation:(CLLocationCoordinate2D)coordinate;

@end
