//
//  ChatListViewController.m
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 27..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"
#import "ChatListViewController.h"
#import "ChatListCell.h"
#import "ChatListItem.h"
#import "ChatRoomViewController.h"
#import "Message.h"

#import "VicKit.h"
#import "VKMatchmaker.h"
#import "VKLocalPlayer.h"

#import "NotificationNames.h"
#import "MatchmakerHandlers.h"
#import "LocalPlayerHandlers.h"
#import "VKMatchWrapper.h"
#import "VKInviteWrapper.h"
#import "ConvertUtils.h"

@interface ChatListViewController ()
{
    NSMutableArray *chatList;
    NSMutableArray *tempList;
    // when a chat room is open, it is set to the match of the chat.
    // when the chat list is showing, it is nil.
    VKMatch *currentMatch;
}
@end

@implementation ChatListViewController

@synthesize gotoChatRoomUserID;
@synthesize gotoChatRoomMatchID;

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
        gotoChatRoomUserID = nil;
        gotoChatRoomMatchID = nil;
        tempList = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveData:) name:VKMatchDelegateDidOnReceiveDataCalledNotification object:nil];
        currentMatch = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveChatRoomList) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFindMatch:) name:VKMatchmakerDidOnFindMatchCalledNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoadUserProfile:) name:VKLocalPlayerDidOnLoadUserProfileCalledNotification object:nil];

        // get data
        [self getData];

        // set invite handler
        VKMatchmaker * matchmaker = VKMatchmaker::sharedMatchmaker();
        MatchmakerHandlers *handler = MatchmakerHandlers::sharedInstance();
        matchmaker->inviteHandler(handler);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInvite:) name:VKMatchmakerDidOnInviteCalledNotification object:nil];
        
        // initialize VicKitSystem
        //VicKitSystem::initialize();
        
        // set self to app delegate
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        appDelegate.chatListViewController = self;
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
}

- (void)viewWillUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VKMatchmakerDidOnFindMatchCalledNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%@:%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    [self sortChatList];
    [self reloadTableViewAndBadge];
    currentMatch = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%@:%@ gotoChatRoomUserID = %@, gotoChatRoomMatchID = %@",
          NSStringFromClass([self class]), NSStringFromSelector(_cmd),
          gotoChatRoomUserID, gotoChatRoomMatchID);
    if (gotoChatRoomUserID)
    {
        int i = 0;
        BOOL chatRoomFound = NO;
        for (ChatListItem *item in chatList)
        {
            if ([gotoChatRoomUserID isEqualToString:item.user.userID])
            {
                chatRoomFound = YES;
                break;
            }
            i++;
        }
        
        if (chatRoomFound)
        {
            gotoChatRoomUserID = nil;
            [self gotoChatRoom:i];
        }
        else
        {
            // create a chat room with a friend
            VKMatchRequest matchRequest;
            TxStringArray array(1);
            array[0] = gotoChatRoomUserID.UTF8String;
            matchRequest.playersToInvite(array);
            
            VKMatchmaker * matchmaker = VKMatchmaker::sharedMatchmaker();
            MatchmakerHandlers *handler = MatchmakerHandlers::sharedInstance();
            
            matchmaker->findMatch(matchRequest, handler);
        }
    }
    else if (gotoChatRoomMatchID)
    {
        int i = 0;
        BOOL chatRoomFound = NO;
        for (ChatListItem *item in chatList)
        {
            if ([gotoChatRoomMatchID longLongValue] == item.matchID)
            {
                chatRoomFound = YES;
                break;
            }
            i++;
        }
        gotoChatRoomMatchID = nil;
        
        if (chatRoomFound)
        {
            [self gotoChatRoom:i];
        }
        else
        {
            // do nothing
            // app is opened by remote notification, but the chat room is not exist.
            // invite handler will handle this.
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)gotoChatRoomWithNumber:(NSNumber *)number
{
    [self gotoChatRoom:number.intValue];
}

- (void)gotoChatRoom:(int)index
{
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionBottom];
    [self performSegueWithIdentifier:@"ShowChatRoom" sender:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return chatList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatListCell"];
    ChatListItem *item = [chatList objectAtIndex:indexPath.row];
    
    cell.imageView.image = item.user.photo;
    cell.nameLabel.text = item.user.name;
    cell.textLabel.text = item.lastMessage;
    if (item.lastMessageDate)
    {
        NSDate *today = [NSDate date];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setLocale:locale];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateStyle:NSDateFormatterNoStyle];
        [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
        [timeFormatter setLocale:locale];
        
        NSString *todayString = [dateFormatter stringFromDate:today];
        NSString *dateString = [dateFormatter stringFromDate:item.lastMessageDate];
        if ([dateString isEqualToString:todayString])
        {
            cell.timeLabel.text = [timeFormatter stringFromDate:item.lastMessageDate];
        }
        else
        {
            cell.timeLabel.text = [dateFormatter stringFromDate:item.lastMessageDate];
        }
    }
    else
    {
        cell.timeLabel.text = @"";
    }
    
    if (item.newChatNum > 0)
    {
        cell.numButton.hidden = NO;
        [cell.numButton setTitle:[NSString stringWithFormat:@"%d", item.newChatNum] forState:UIControlStateNormal];
        [[cell.numButton layer] setCornerRadius: 10.0f];
    }
    else
    {
        cell.numButton.hidden = YES;
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
        ChatListItem *item = [chatList objectAtIndex:indexPath.row];
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
    NSLog(@"selected index: %d", [self.tableView indexPathForSelectedRow].row);
    ChatListItem *item = [chatList objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    dest.title = item.user.name;
    dest.messages = item.messages;
    dest.match = item.match;
    item.newChatNum = 0;
    currentMatch = item.match;
}

#pragma mark - get data

- (void)getData
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"];
    //NSLog(@"docsDir: %@", docsDir);
    
    // get chat room list
    chatList = [[NSMutableArray alloc] init];
    NSString *chatRoomListPath = [docsDir stringByAppendingPathComponent:@"ChatRoomList.plist"];
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
                ChatListItem *item = [[ChatListItem alloc] init];
                NSNumber *matchID =[dic valueForKey:@"MatchID"]; 
                item.matchID = [matchID longLongValue];
                item.userID = [dic valueForKey:@"UserID"];
                item.user = [appDelegate getUser:item.userID];
                if (!item.user)
                {
                    // get user profile
                    VKLocalPlayer * localPlayer = VKLocalPlayer::localPlayer();
                    LocalPlayerHandlers *localPlayerHandler = LocalPlayerHandlers::sharedInstance();
                    localPlayer->loadUserProfile(item.userID.UTF8String, localPlayerHandler);
                }
                item.newChatNum = 0;
                [chatList addObject:item];
                
                // get VKMatch
                matchRequest.matchId(item.matchID);
                matchmaker->findMatch(matchRequest, handler);
                NSLog(@"%@:%@ findMatch matchID = %lli", NSStringFromClass([self class]), NSStringFromSelector(_cmd), item.matchID);
            }
        }
    }
    
    for (ChatListItem *item in chatList)
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
    
    [self sortChatList];
}

- (void)sortChatList
{
    for (ChatListItem *item in chatList)
    {
        if (item.messages.count > 0)
        {
            // set last message
            NSDictionary *dic = (NSDictionary *)[item.messages objectAtIndex:item.messages.count - 1];
            item.lastMessage = [dic valueForKey:@"Message"];
            
            // set last time
            item.lastMessageDate = [dic valueForKey:@"Date"];
        }
        else
        {
            item.lastMessage = @"";
            item.lastMessageDate = nil;
        }
    }
    
    [chatList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ChatListItem *item1 = (ChatListItem *)obj1;
        ChatListItem *item2 = (ChatListItem *)obj2;
        if (item1.lastMessageDate && item2.lastMessageDate)
        {
            return [item2.lastMessageDate compare:item1.lastMessageDate];
        }
        else
        {
            return NSOrderedSame;
        }
    }];
}

- (void)saveChatRoomList
{
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *chatRoomListPath = [docsDir stringByAppendingPathComponent:@"ChatRoomList.plist"];
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (ChatListItem *item in chatList)
    {
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithLongLong:item.matchID], @"MatchID", item.user.userID, @"UserID", nil];
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
    
    for (ChatListItem *item in chatList)
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

#pragma mark - notification handlers

- (void)onFindMatch:(NSNotification *)aNotification
{
    // check error
    NSString *error = [[aNotification userInfo] objectForKey:@"Error"];
    if (error != nil)
    {
        NSLog(@"ChatListViewController::onFindMatch error: %@", error);
    }
    else
    {
        VKMatchWrapper *matchWrapper = [[aNotification userInfo] objectForKey:@"Match"];
        VKMatch *match = matchWrapper.match;
        
        BOOL chatRoomFound = NO;
        for (ChatListItem *item in chatList)
        {
            NSLog(@"item.matchID = %lli, match->matchId() = %lli", item.matchID, match->matchId());
            if (item.matchID == match->matchId())
            {
                item.match = match;
                chatRoomFound = YES;
                break;
            }
        }
        if (!chatRoomFound)
        {
            // create a chat room with a friend
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            ChatListItem *item = [[ChatListItem alloc] init];
            item.user = [appDelegate getFriend:gotoChatRoomUserID];
            item.match = match;
            item.matchID = match->matchId();
            item.messages = [[NSMutableArray alloc] init];
            [chatList addObject:item];
            [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:NO];
            gotoChatRoomUserID = nil;
            [self performSelectorOnMainThread:@selector(gotoChatRoomWithNumber:) withObject:[NSNumber numberWithInt:(chatList.count - 1)] waitUntilDone:NO];
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
        Message *message = [dic objectForKey:@"Message"];
        for (ChatListItem *item in chatList)
        {
            if ([matchID longLongValue] == item.matchID)
            {
                // add message
                NSDictionary *messageDic = [[NSDictionary alloc] initWithObjectsAndKeys:message.userID, @"UserID", message.text, @"Message", message.date, @"Date", nil];
                [item.messages addObject:messageDic];
                
                // increase new number
                item.newChatNum++;
                [self performSelectorOnMainThread:@selector(reloadTableViewAndBadge) withObject:nil waitUntilDone:NO];
                
                break;
            }
        }
        for (ChatListItem *item in tempList)
        {
            if ([matchID longLongValue] == item.matchID)
            {
                // add message
                NSDictionary *messageDic = [[NSDictionary alloc] initWithObjectsAndKeys:message.userID, @"UserID", message.text, @"Message", message.date, @"Date", nil];
                [item.messages addObject:messageDic];
                
                // increase new number
                item.newChatNum++;
                
                break;
            }
        }
    }
}

- (void)onInvite:(NSNotification *)aNotification
{
    VKInviteWrapper *inviteWrapper = [[aNotification userInfo] objectForKey:@"Invite"];
    
    ChatListItem *item = [[ChatListItem alloc] init];
    item.matchID = inviteWrapper.invite->matchId();
    item.userID = convertTxStringToNSString(inviteWrapper.invite->inviter());
    item.user = nil;
    item.match = nil;
    item.newChatNum = 0;
    item.messages = [[NSMutableArray alloc] init];
    [tempList addObject:item];

    // get match
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMatchForInvite:) name:VKMatchmakerDidOnMatchForInviteCalledNotification object:nil];
    VKMatchmaker * matchmaker = VKMatchmaker::sharedMatchmaker();
    MatchmakerHandlers *handler = MatchmakerHandlers::sharedInstance();
    matchmaker->matchForInvite(inviteWrapper.invite, handler);
    
    // get user profile
    VKLocalPlayer * localPlayer = VKLocalPlayer::localPlayer();
    LocalPlayerHandlers *localPlayerHandler = LocalPlayerHandlers::sharedInstance();
    localPlayer->loadUserProfile(inviteWrapper.invite->inviter(), localPlayerHandler);
}

- (void)onMatchForInvite:(NSNotification *)aNotification
{
    // check error
    NSString *error = [[aNotification userInfo] objectForKey:@"Error"];
    if (error != nil)
    {
        NSLog(@"onMatchForInvite error: %@", error);
    }
    else
    {
        VKMatchWrapper *matchWrapper = [[aNotification userInfo] objectForKey:@"Match"];
        VKMatch *match = matchWrapper.match;
        for (ChatListItem *item in tempList)
        {
            if (match->matchId() == item.matchID)
            {
                item.match = match;
                if (item.user)
                {
                    [self performSelectorOnMainThread:@selector(addChatItem:) withObject:item waitUntilDone:NO];
                }
                break;
            }
        }
    }
}

- (void)onLoadUserProfile:(NSNotification *)aNotification
{
    // check error
    NSString *error = [[aNotification userInfo] objectForKey:@"Error"];
    if (error != nil)
    {
        NSLog(@"onLoadUserProfile error: %@", error);
    }
    else
    {
        User *aUser = [[aNotification userInfo] objectForKey:@"UserProfile"];
        for (ChatListItem *item in chatList)
        {
            if ([item.userID isEqualToString:aUser.userID])
            {
                item.user = aUser;
                AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                [appDelegate addUser:aUser];
                break;
            }
        }
        for (ChatListItem *item in tempList)
        {
            if ([item.userID isEqualToString:aUser.userID])
            {
                item.user = aUser;
                AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                [appDelegate addUser:aUser];
                if (item.match)
                {
                    [self performSelectorOnMainThread:@selector(addChatItem:) withObject:item waitUntilDone:NO];
                }
                break;
            }
        }
    }
}

- (void)addChatItem:(ChatListItem *)item
{
    [chatList addObject:item];
    [tempList removeObject:item];
    [self.tableView reloadData];
}

- (void)reloadTableView
{
    [self.tableView reloadData];
}

- (void)reloadTableViewAndBadge
{
    int badgeCount = 0;
    for (ChatListItem *item in chatList)
    {
        if (item.newChatNum > 0)
        {
            badgeCount++;
        }
    }

    NSString *badgeStr = nil;
    if (badgeCount > 0)
    {
        badgeStr = [NSString stringWithFormat:@"%d", badgeCount];
    }

    UITabBarController *tabBarController = (UITabBarController *)self.parentViewController.parentViewController;
    UITabBarItem *tabBarItem = [tabBarController.tabBar.items objectAtIndex:1];
    tabBarItem.badgeValue = badgeStr;

    [self.tableView reloadData];
}

@end
