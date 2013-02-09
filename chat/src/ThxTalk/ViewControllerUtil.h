//
//  ViewControllerUtil.h
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 24..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Utility class for UIViewController.
 - show/hide progress indicator
 - check network reachability
 */
@interface ViewControllerUtil : NSObject
{
    UIActivityIndicatorView *indicator;
}

@property (strong, nonatomic) UIActivityIndicatorView *indicator;

/*
 This function shows animating activity indicator.
 */
- (void)showIndicator;

/*
 This function hides activity indicator.
 */
- (void)hideIndicator;

/*
 This function returns whether connected to network or not.
 */
- (BOOL)connectedToNetwork;

/*
 This function checks network connectivity and shows dialog if not connected.
 */
- (BOOL)checkNetworkAndShowDialog;

@end
