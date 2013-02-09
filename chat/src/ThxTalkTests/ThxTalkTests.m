//
//  ThxTalkTests.m
//  ThxTalkTests
//
//  Created by 민경 장 on 12. 9. 19..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import "ThxTalkTests.h"
#import "LocChatListViewController.h"

@implementation ThxTalkTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

//-(long long)caculateNum:(CLLocationCoordinate2D)coordinate
//{
//    CLLocation *loc = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
//    
//}

- (void)checkMatchID:(CLLocationCoordinate2D)coordinate minNumber:(long long)minNumber maxNumber:(long long)maxNumber
{
    LocChatListViewController *locVC = [[LocChatListViewController alloc] init];
    STAssertNotNil(locVC, @"locVC is nil");
    long long resultMatchID = [locVC getMatchIDFromLocation:coordinate];
    NSLog(@"(%f, %f) -> %lli", coordinate.latitude, coordinate.longitude, resultMatchID);
    STAssertTrue(resultMatchID >= minNumber, @"match id is smaller than the min number");
    STAssertTrue(resultMatchID < maxNumber, @"match id is larget than the max number");
}

- (void)testLocMatchID
{
   //STFail(@"Unit tests are not implemented yet in ThxTalkTests");
    
    CLLocationCoordinate2D coordinate;

    long long baseNum1 = 1000000000;
    long long baseNum2 = 2000000000;
    long long baseNum3 = 3000000000;
    long long baseNum4 = 4000000000;
    long long baseNum5 = 5000000000;
    
    long long minNumber;
    long long maxNumber;
    
    // region 1 (loc 101 - 109)
    minNumber = baseNum1;
    maxNumber = baseNum2;
    
    // loc 101
    coordinate.latitude = 90;
    coordinate.longitude = 0;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];
    
    // loc 102
    coordinate.latitude = 90;
    coordinate.longitude = 45;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];
    
    // loc 103
    coordinate.latitude = 90;
    coordinate.longitude = 90;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];
    
    // loc 104
    coordinate.latitude = 45;
    coordinate.longitude = 0;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];
    
    // loc 105
    coordinate.latitude = 45;
    coordinate.longitude = 45;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];
    
    // loc 106
    coordinate.latitude = 45;
    coordinate.longitude = 90;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];
    
    // loc 107
    coordinate.latitude = 0;
    coordinate.longitude = 0;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];
    
    // loc 108
    coordinate.latitude = 0;
    coordinate.longitude = 45;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];
    
    // loc 109
    coordinate.latitude = 0;
    coordinate.longitude = 90;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];
    
    // region 2 (loc 201 - 206)
    minNumber = baseNum2;
    maxNumber = baseNum3;
    
    // loc 201
    coordinate.latitude = 90;
    coordinate.longitude = -90;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];

    // loc 202
    coordinate.latitude = 90;
    coordinate.longitude = -45;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];
    
    // loc 203
    coordinate.latitude = 45;
    coordinate.longitude = -90;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];
    
    // loc 204
    coordinate.latitude = 45;
    coordinate.longitude = -45;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];
    
    // loc 205
    coordinate.latitude = 0;
    coordinate.longitude = -90;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];
    
    // loc 206
    coordinate.latitude = 0;
    coordinate.longitude = -45;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];
    
    // region 3 (loc 301 - 306)
    minNumber = baseNum3;
    maxNumber = baseNum4;
    
    // loc 301
    coordinate.latitude = -45;
    coordinate.longitude = 0;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];

    // loc 302
    coordinate.latitude = -45;
    coordinate.longitude = 45;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];
    
    // loc 303
    coordinate.latitude = -45;
    coordinate.longitude = 90;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];
    
    // loc 304
    coordinate.latitude = -90;
    coordinate.longitude = 0;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];
    
    // loc 305
    coordinate.latitude = -90;
    coordinate.longitude = 45;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];
    
    // loc 306
    coordinate.latitude = -90;
    coordinate.longitude = 90;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];
    
    // region 4 (loc 401 - 404)
    minNumber = baseNum4;
    maxNumber = baseNum5;
    
    // loc 401
    coordinate.latitude = -45;
    coordinate.longitude = -90;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];

    // loc 402
    coordinate.latitude = -45;
    coordinate.longitude = -45;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];

    // loc 403
    coordinate.latitude = -90;
    coordinate.longitude = -90;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];

    // loc 404
    coordinate.latitude = -90;
    coordinate.longitude = -45;
    [self checkMatchID:coordinate minNumber:minNumber maxNumber:maxNumber];
}

@end
