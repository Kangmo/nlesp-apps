//
//  ViewControllerUtil.m
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 24..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import "ViewControllerUtil.h"
#include <netinet/in.h>
#import <SystemConfiguration/SCNetworkReachability.h>

@implementation ViewControllerUtil

@synthesize indicator;

- (id)init
{
    if (self = [super init])
    {
        // setup indicator
        indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        [indicator setCenter:CGPointMake(160, 190)];
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
    return self;
}

- (void)showIndicator
{
    indicator.hidden = NO;
    [indicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)hideIndicator
{
    [indicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

/*
 Code from: http://www.friendlydeveloper.com/2011/04/checking-network-availability-on-ios/
 */
- (BOOL)connectedToNetwork  {
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr*)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if (!didRetrieveFlags)
    {
        NSLog(@"Error. Could not recover network reachability flags");
        return 0;
    }
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    //below suggested by Ariel
    BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsTransientConnection;
    NSURL *testURL = [NSURL URLWithString:@"http://www.apple.com/"]; //comment by friendlydeveloper: maybe use www.google.com
    NSURLRequest *testRequest = [NSURLRequest requestWithURL:testURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
    //NSURLConnection *testConnection = [[NSURLConnection alloc] initWithRequest:testRequest delegate:nil]; //suggested by Ariel
    NSURLConnection *testConnection = [[NSURLConnection alloc] initWithRequest:testRequest delegate:nil]; //modified by friendlydeveloper
    return ((isReachable && !needsConnection) || nonWiFi) ? (testConnection ? YES : NO) : NO;
}

- (BOOL)checkNetworkAndShowDialog
{
    BOOL result = [self connectedToNetwork];
    if (result == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"네트워크를 사용할 수 없습니다." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
        [alert show];
    }

    return result;
}

@end
