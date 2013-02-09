//
//  LocChatListViewController.m
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 11..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import "LocChatListViewController.h"
#import "LocChatListCell.h"
#import "LocChatListItem.h"
#import "ChatRoomViewController.h"
#import "VKMatchmaker.h"
#import "NotificationNames.h"
#import "MatchmakerHandlers.h"
#import "VKMatchWrapper.h"
#import "Message.h"
#import "ViewControllerUtil.h"

@interface LocChatListViewController ()
{
    LocChatListItem *currentLocItem;
    NSMutableArray *chatList;
    UIImage *currentLocImage;
    UIImage *chatListImage;
    ViewControllerUtil *util;
    // when a chat room is open, it is set to the match of the chat.
    // when the chat list is showing, it is nil.
    VKMatch *currentMatch;
}

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation LocChatListViewController

@synthesize locationManager = _locationManager;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"%@:%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveData:) name:VKMatchDelegateDidOnReceiveDataCalledNotification object:nil];
        currentMatch = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveChatRoomList) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFindMatch:) name:VKMatchmakerDidOnFindMatchCalledNotification object:nil];
        
        // get data
        [self getData];

    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"%@:%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    currentLocImage = [UIImage imageNamed:@"angrybird.png"];
    chatListImage = [UIImage imageNamed:@"angrybird.png"];
    
    // update current location
    currentLocItem = [[LocChatListItem alloc] init];    
    [self startUpdatingCurrentLocation];
    
    // setup util
    util = [[ViewControllerUtil alloc] init];
    [self.view addSubview:util.indicator];
}

- (void)viewWillUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VKMatchmakerDidOnFindMatchCalledNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%@:%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    currentMatch = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
    {
        return 1;
    }
    else
    {
        return chatList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    // Configure the cell...
    if (indexPath.section == 0)
    {
        LocChatListCell *currentCell = [tableView dequeueReusableCellWithIdentifier:@"CurrentLocCell"];
        currentCell.imageView.image = currentLocImage;
        [currentCell.startChatButton addTarget:self action:@selector(startChatButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        cell = currentCell;
    }
    else
    {
        LocChatListItem *item = [chatList objectAtIndex:indexPath.row];
        LocChatListCell *listCell = [tableView dequeueReusableCellWithIdentifier:@"LocChatListCell"];
        listCell.imageView.image = chatListImage;
        listCell.locNameLabel.text = item.locName;
        listCell.locNicknameLabel.text = item.locNickname;
        
        cell = listCell;
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LocChatListItem *item = [chatList objectAtIndex:indexPath.row];
        item.match->disconnect();
        [chatList removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"현재 위치";
    }
    else
    {
        return @"채팅 리스트";
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ChatRoomViewController *dest = segue.destinationViewController;
    LocChatListItem *item = [chatList objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    dest.title = item.locName;
    dest.messages = item.messages;
    dest.match = item.match;
    item.newChatNum = 0;
    currentMatch = item.match;
}

#pragma mark - CLLocationManagerDelegate

- (void)startUpdatingCurrentLocation
{
    // if location services are restricted do nothing
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted )
    {
        return;
    }
    
    // if locationManager does not currently exist, create it
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        _locationManager.distanceFilter = 10.0f; // we don't need to be any more accurate than 10m
        _locationManager.purpose = @"This may be used to obtain your reverse geocoded address";
    }
    
    [_locationManager startUpdatingLocation];
    [util showIndicator];
}

- (void)stopUpdatingCurrentLocation
{
    [_locationManager stopUpdatingLocation];
    [util hideIndicator];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // if the location is older than 30s ignore
    if (fabs([newLocation.timestamp timeIntervalSinceDate:[NSDate date]]) > 30)
    {
        return;
    }
    
    currentLocItem.location = newLocation;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currentLocItem.location completionHandler:^(NSArray *placemarks, NSError *error) {
        [self displayPlacemarks:placemarks];
    }];
    
    // after recieving a location, stop updating
    [self stopUpdatingCurrentLocation];
    
    [self sortChatList];
    [self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    
    // stop updating
    [self stopUpdatingCurrentLocation];
    
    // show the error alert
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = @"Error updating location";
    alert.message = [error localizedDescription];
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}

- (void)displayPlacemarks:(NSArray *)placemarks
{
    CLPlacemark *placemark = [placemarks objectAtIndex:0];
    LocChatListCell *cell = (LocChatListCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.locNameLabel.text = placemark.name;
    currentLocItem.locName = placemark.name;
    cell.startChatButton.enabled = YES;
}

#pragma mark - UI actions

- (void)startChatButtonPressed:(id)sender
{
    currentLocItem.matchID = [self getMatchIDFromLocation:currentLocItem.location.coordinate];
    
    // check whether chatroom for the matchID is exist
    BOOL chatRoomExist = NO;
    int chatRoomIndex = 0;
    
    for (LocChatListItem *item in chatList)
    {
        if (item.matchID == currentLocItem.matchID)
        {
            chatRoomExist = YES;
            break;
        }
        chatRoomIndex ++;
    }
    
    // if not exist, add a new chat room
    if (!chatRoomExist)
    {
        VKMatchRequest matchRequest;
        VKMatchmaker * matchmaker = VKMatchmaker::sharedMatchmaker();
        MatchmakerHandlers *handler = MatchmakerHandlers::sharedInstance();
        
        matchRequest.matchId(currentLocItem.matchID);
        matchmaker->findMatch(matchRequest, handler);
        NSLog(@"%@:%@ findmatch currentLocItem.matchID=%lli", NSStringFromClass([self class]), NSStringFromSelector(_cmd), currentLocItem.matchID);
    }
    else
    {
        // open chat room
        [self gotoChatRoom:chatRoomIndex];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    LocChatListItem *item = [[LocChatListItem alloc] init];
    item.matchID = currentLocItem.matchID;
    item.match = currentLocItem.match;
    item.location = currentLocItem.location;
    item.locName = currentLocItem.locName;
    item.locNickname = [alertView textFieldAtIndex:0].text;
    item.messages = [[NSMutableArray alloc] init];
    [chatList addObject:item];
    [self.tableView reloadData];
    [self gotoChatRoom:chatList.count - 1];
}

- (void)gotoChatRoom:(int)index
{
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1] animated:NO scrollPosition:UITableViewScrollPositionBottom];
    [self performSegueWithIdentifier:@"ShowChatRoom" sender:nil];
}

- (long long)getMatchIDFromLocation:(CLLocationCoordinate2D)coordinate
{
    long long matchID = 0;
    long long baseNum;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    //NSLog(@"%@", [location description]);

    if (location.coordinate.latitude >= 0)
    {
        if (location.coordinate.longitude >= 0)
        {
            baseNum = 1000000000;
        }
        else
        {
            baseNum = 2000000000;
        }
    }
    else
    {
        if (location.coordinate.longitude >= 0)
        {
            baseNum = 3000000000;
        }
        else
        {
            baseNum = 4000000000;
        }
    }
    
    CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:0 longitude:location.coordinate.longitude];
    CLLocationDistance dist1 = [loc1 distanceFromLocation:location];
    CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:location.coordinate.latitude longitude:0];
    CLLocationDistance dist2 = [loc2 distanceFromLocation:location];
    
    int dist1InKm = dist1 / 1000;
    int dist2InKm = dist2 / 1000;
    matchID = baseNum + dist1InKm * 30000 + dist2InKm;
    NSLog(@"dist1: %d, dist2: %d", dist1InKm, dist2InKm);
    if (dist2InKm > 30000)
    {
        NSLog(@"***dist2InKm is bigger than 30000");
    }
    return matchID;
}

#pragma mark - get data

- (void)getData
{
    // get chat room list
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSString *chatRoomListPath = [docsDir stringByAppendingPathComponent:@"LocChatRoomList.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:chatRoomListPath])
    {
        NSPropertyListFormat format;
        NSString *errorDesc = nil;
        NSData *chatRoomListData = [[NSFileManager defaultManager] contentsAtPath:chatRoomListPath];
        NSMutableArray *temp = (NSMutableArray *)[NSPropertyListSerialization propertyListFromData:chatRoomListData mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
        if (!temp)
        {
            NSLog(@"Error reading ChatRoomList.plist: %@, format: %d", errorDesc, format);
        }
        else
        {
            VKMatchRequest matchRequest;
            VKMatchmaker * matchmaker = VKMatchmaker::sharedMatchmaker();
            MatchmakerHandlers *handler = MatchmakerHandlers::sharedInstance();

            for (NSDictionary *dic in temp)
            {
                LocChatListItem *item = [[LocChatListItem alloc] init];
                NSNumber *matchID = [dic valueForKey:@"MatchID"];
                item.matchID = [matchID longLongValue];
                NSNumber *latitudeNum = [dic valueForKey:@"Latitude"];
                NSNumber *longitudeNum = [dic valueForKey:@"Longitude"];
                item.location = [[CLLocation alloc] initWithLatitude:[latitudeNum doubleValue] longitude:[longitudeNum doubleValue]];
                item.locName = [dic valueForKey:@"LocName"];
                item.locNickname = [dic valueForKey:@"LocNickname"];
                item.newChatNum = 0;
                
                [list addObject:item];
                
                // get VKMatch
                matchRequest.matchId(item.matchID);
                matchmaker->findMatch(matchRequest, handler);
            }
        }
    }
    
    chatList = list;
    
    for (LocChatListItem *item in chatList)
    {
        NSString *plistPath = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%lli.plist", item.matchID]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath])
        {
            NSPropertyListFormat format;
            NSString *errorDesc = nil;
            NSData *pListData = [[NSFileManager defaultManager] contentsAtPath:plistPath];
            NSMutableArray *temp = (NSMutableArray *)[NSPropertyListSerialization propertyListFromData:pListData mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
            if (!temp)
            {
                NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
            }
            else
            {
                item.messages = temp;
            }
        }
        if (!item.messages)
        {
            item.messages = [[NSMutableArray alloc] init];
        }
    }
}

- (void)saveChatRoomList
{
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *chatRoomListPath = [docsDir stringByAppendingPathComponent:@"LocChatRoomList.plist"];
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (LocChatListItem *item in chatList)
    {
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                             [NSNumber numberWithLongLong:item.matchID], @"MatchID",
                             [NSNumber numberWithDouble:item.location.coordinate.latitude], @"Latitude",
                             [NSNumber numberWithDouble:item.location.coordinate.longitude], @"Longitude",
                             item.locName, @"LocName",
                             item.locNickname, @"LocNickname",
                             nil];
        [list addObject:dic];
    }
    NSString *error;
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:list format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    if (data)
    {
        [data writeToFile:chatRoomListPath atomically:YES];
    }
    else
    {
        NSLog(@"error : %@", error);
    }
    
    for (LocChatListItem *item in chatList)
    {
        if (item.newChatNum > 0)
        {
            NSString *path = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%lli.plist", item.matchID]];
            data = [NSPropertyListSerialization dataFromPropertyList:item.messages format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
            if (data)
            {
                [data writeToFile:path atomically:YES];
            }
            else
            {
                NSLog(@"error: %@", error);
            }
        }
    }
}

- (void)sortChatList
{
    for (LocChatListItem *item in chatList)
    {
        item.distance = [item.location distanceFromLocation:currentLocItem.location];
    }
    
    [chatList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        LocChatListItem *item1 = (LocChatListItem *)obj1;
        LocChatListItem *item2 = (LocChatListItem *)obj2;
        if (item1.distance > item2.distance)
        {
            return NSOrderedDescending;
        }
        else if (item1.distance < item2.distance)
        {
            return NSOrderedAscending;
        }
        else
        {
            return NSOrderedSame;
        }
    }];
}

#pragma mark - notification handlers

- (void)onFindMatch:(NSNotification *)aNotification
{
    NSString *error = [[aNotification userInfo] objectForKey:@"Error"];
    if (error != nil)
    {
        NSLog(@"LocChatListViewController::onFindMatch error: %@", error);
    }
    else
    {
        BOOL chatRoomFound = NO;
        VKMatchWrapper *matchWrpper = [[aNotification userInfo] objectForKey:@"Match"];
        VKMatch *match = matchWrpper.match;
        for (LocChatListItem *item in chatList)
        {
            if (item.matchID == match->matchId())
            {
                item.match = match;
                chatRoomFound = YES;
                break;
            }
        }
        
        NSLog(@"%@:%@ currentLocItem.matchID=%lli, match->matchId=%lli", NSStringFromClass([self class]), NSStringFromSelector(_cmd), currentLocItem.matchID, match->matchId());
        if (!chatRoomFound && (currentLocItem.matchID == match->matchId()))
        {
            currentLocItem.match = match;
            [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)onReceiveData:(NSNotification *)aNotification
{
    // find chat room
    NSDictionary *dic = [aNotification userInfo];
    NSString *matchID = [dic objectForKey:@"MatchID"];
    if (currentMatch && [matchID longLongValue] == currentMatch->matchId())
    {
        // chat room is open and the message belongs it.
    }
    else
    {
        for (LocChatListItem *item in chatList)
        {
            if ([matchID longLongValue] == item.matchID)
            {
                // add message
                Message *message = [dic objectForKey:@"Message"];
                NSDictionary *messageDic = [[NSDictionary alloc] initWithObjectsAndKeys:message.userID, @"UserID", message.text, @"Message", message.date, @"Date", nil];
                [item.messages addObject:messageDic];
                
                // increase new number
                item.newChatNum++;
                [self performSelectorOnMainThread:@selector(reloadTableViewAndBadge) withObject:nil waitUntilDone:NO];

                break;
            }
        }
    }
}

- (void)showAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"장소 설명을 추가하세요" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;

    [alert show];
}

- (void)reloadTableViewAndBadge
{
    int badgeCount = 0;
    for (LocChatListItem *item in chatList)
    {
        if (item.newChatNum > 0)
        {
            badgeCount++;
        }
    }
    if (badgeCount > 0)
    {
        UITabBarController *tabBarController = (UITabBarController *)self.parentViewController.parentViewController;
        UITabBarItem *tabBarItem = [tabBarController.tabBar.items objectAtIndex:1];
        tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", badgeCount];
    }
    [self.tableView reloadData];
}

@end
