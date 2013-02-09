//
//  ChatRoomViewController.m
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 27..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import "ChatRoomViewController.h"
#import "ChatItem.h"
#import "LabelCell.h"
#import "ChatMessageCell.h"
#import "MyChatMessageCell.h"
#import "AppDelegate.h"
#import "Basement.h"
#import "NotificationNames.h"
#import "Message.h"
#import "ConvertUtils.h"

@interface ChatRoomViewController ()
{
    UIImage *leftBubble;
    UIImage *rightBubble;
    NSMutableArray *chatList;
    NSString *recentDateStr;
    BOOL messageAdded;
}
@end

@implementation ChatRoomViewController

@synthesize myTableView, textView, button;
@synthesize messages;
@synthesize match;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.hidesBottomBarWhenPushed = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveData) name:UIApplicationDidEnterBackgroundNotification object:nil];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveData:) name:VKMatchDelegateDidOnReceiveDataCalledNotification object:nil];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [myTableView addGestureRecognizer:singleFingerTap];
    
    leftBubble = [[UIImage imageNamed:@"LeftBubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 10, 10, 10)];
    rightBubble = [[UIImage imageNamed:@"RightBubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 10, 10, 10)];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_1.png"]];
    [bgImageView setFrame:self.myTableView.frame];
    self.myTableView.backgroundView = bgImageView;
    
    [self getData];
    messageAdded = NO;
    
    NSLog(@"%@:%@ matchID = %lli", NSStringFromClass([self class]), NSStringFromSelector(_cmd), match->matchId());
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (messageAdded)
    {
        [self saveData];
    }
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return chatList.count;
}

#define CONTENT_LABEL_WIDTH 160
#define LEFT_CONTENT_LABEL_X 58
#define LEFT_CONTENT_LABEL_Y 50
#define RIGHT_CONTENT_LABEL_X 140
#define RIGHT_CONTENT_LABEL_Y 25

- (CGSize)sizeForContentLabel:(NSString *)text
{
    CGSize constraint = CGSizeMake(CONTENT_LABEL_WIDTH, 200000.0f);
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    return size;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    ChatItem *item = [chatList objectAtIndex:indexPath.row];
    
    if (item.type == ChatItemType_date)
    {
        LabelCell *labelCell = [tableView dequeueReusableCellWithIdentifier:@"LabelCell"];
        labelCell.label.text = item.dateStr;
        cell = labelCell;
    }
    else if (item.type == ChatItemType_fromFriend)
    {
        ChatMessageCell *chatCell = [tableView dequeueReusableCellWithIdentifier:@"ChatMessageCell"];
        chatCell.imageView.image = item.user.photo;
        chatCell.nameLabel.text = item.user.name;
        chatCell.timeLabel.text = item.timeStr;
        chatCell.contentLabel.text = item.content;
        CGSize  size = [self sizeForContentLabel:item.content];
        [chatCell.contentLabel setFrame:CGRectMake(LEFT_CONTENT_LABEL_X, LEFT_CONTENT_LABEL_Y, size.width, size.height)];

        CGRect timeLabelFrame = chatCell.timeLabel.frame;
        timeLabelFrame.origin.x = LEFT_CONTENT_LABEL_X + size.width + 11;
        [chatCell.timeLabel setFrame:timeLabelFrame];
        
        if (chatCell.textBgImageView.image == nil)
        {
            chatCell.textBgImageView.image = leftBubble;
        }
        CGRect bgImageFrame = chatCell.textBgImageView.frame;
        bgImageFrame.size.width = size.width + 20;
        bgImageFrame.size.height = size.height + 25;
        [chatCell.textBgImageView setFrame:bgImageFrame];
        
        cell = chatCell;
    }
    else
    {
        MyChatMessageCell *chatCell = [tableView dequeueReusableCellWithIdentifier:@"MyChatMessageCell"];
        chatCell.timeLabel.text = item.timeStr;
        chatCell.contentLabel.text = item.content;
        CGSize  size = [self sizeForContentLabel:item.content];
        CGRect contentLabelFrame = chatCell.contentLabel.frame;
        contentLabelFrame.origin.x = RIGHT_CONTENT_LABEL_X + (CONTENT_LABEL_WIDTH - size.width);
        contentLabelFrame.size.width = size.width;
        contentLabelFrame.size.height = size.height;
        [chatCell.contentLabel setFrame:contentLabelFrame];
        
        CGRect timeLabelFrame = chatCell.timeLabel.frame;
        timeLabelFrame.origin.x = 61 + (CONTENT_LABEL_WIDTH - size.width);
        [chatCell.timeLabel setFrame:timeLabelFrame];
        
        if (chatCell.textBgImageView.image == nil)
        {
            chatCell.textBgImageView.image = rightBubble;
        }
        
        CGRect bgImageFrame = chatCell.textBgImageView.frame;
        bgImageFrame.origin.x = RIGHT_CONTENT_LABEL_X + (CONTENT_LABEL_WIDTH - size.width) - 10;
        bgImageFrame.size.width = size.width + 20;
        bgImageFrame.size.height = size.height + 25;
        [chatCell.textBgImageView setFrame:bgImageFrame];
        
        cell = chatCell;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    
    ChatItem *item = [chatList objectAtIndex:indexPath.row];
    if (item.type == ChatItemType_date)
    {
        height = 44;
    }
    else if (item.type == ChatItemType_fromFriend)
    {
        height = 70 + [self sizeForContentLabel:item.content].height;
    }
    else
    {
        height = 50 + [self sizeForContentLabel:item.content].height;
    }

    return height;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

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

- (void)scrollToBottom
{
    if (chatList.count > 0)
    {
        [myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(chatList.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - keyboard

- (void)keyboardWillHide
{
    [UIView animateWithDuration:0.3f animations:^{
        CGRect tableViewFrame = myTableView.frame;
        tableViewFrame.size.height = 369;
        [myTableView setFrame:tableViewFrame];
        
        CGRect textViewFrame = textView.frame;
        textViewFrame.origin.y = 377;
        [textView setFrame:textViewFrame];
        
        CGRect buttonFrame = button.frame;
        buttonFrame.origin.y = 377;
        [button setFrame:buttonFrame];
    }];
}

- (void)keyboardWasShown:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.3f animations:^{
        NSDictionary *info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        CGRect tableViewFrame = myTableView.frame;
        tableViewFrame.size.height = tableViewFrame.size.height - kbSize.height;
        [myTableView setFrame:tableViewFrame];
        
        [self scrollToBottom];
        
        CGRect textViewFrame = textView.frame;
        textViewFrame.origin.y = textViewFrame.origin.y - kbSize.height;
        [textView setFrame:textViewFrame];
        
        CGRect buttonFrame = button.frame;
        buttonFrame.origin.y = buttonFrame.origin.y - kbSize.height;
        [button setFrame:buttonFrame];
    }];
}

#pragma mark - gesture recognizer

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    if ([textView isFirstResponder])
    {
        [textView resignFirstResponder];
    }
}

#pragma mark - send message

- (IBAction)sendButtonPressed:(id)sender
{
    NSLog(@"%@:%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // send message
    TxData data((void *)textView.text.UTF8String, textView.text.length);
    VKError *error;
    bool res = match->sendDataToAllPlayers(data, VKMatchSendDataUnreliable, &error);
    NSLog(@"match->sendDataToAllPlayers res = %d", res);
    if (error)
    {
        NSLog(@"error = %@", convertTxStringToNSString(error->errorMessage()));
    }
    
    // add message to chat room
    Message *message = [[Message alloc] init];
    message.text = textView.text;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    message.userID = appDelegate.myProfile.userID;
    message.date = [[NSDate alloc] init];
    //NSLog(@"time interval = %f", [message.date timeIntervalSince1970]);
    [self addMessage:message];
    textView.text = @"";
}

#pragma mark - manage data

- (void)getData
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    if (messages)
    {
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterFullStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setLocale:locale];
        
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateStyle:NSDateFormatterNoStyle];
        [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
        [timeFormatter setLocale:locale];
        
        ChatItem *item;
        for (NSDictionary *dic in messages)
        {
            NSString *userID = [dic valueForKey:@"UserID"];
            NSString *message = [dic valueForKey:@"Message"];
            NSDate *date = [dic valueForKey:@"Date"];
            
            NSString *dateStr = [dateFormatter stringFromDate:date];
            if (!recentDateStr || ![recentDateStr isEqualToString:dateStr])
            {
                item = [[ChatItem alloc] init];
                item.type = ChatItemType_date;
                item.dateStr = dateStr;
                [list addObject:item];
                recentDateStr = dateStr;
            }
            
            item = [[ChatItem alloc] init];
            if ([userID isEqualToString:appDelegate.myUserID])
            {
                item.type = ChatItemType_fromMe;
            }
            else
            {
                item.type = ChatItemType_fromFriend;
                item.user = [appDelegate getUser:userID];
            }
            item.content = message;
            item.timeStr = [timeFormatter stringFromDate:date];
            
            [list addObject:item];
        }
    }
    chatList = list;
}

- (void)saveData
{
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *plistPath = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%lli.plist", match->matchId()]];
//    NSLog(@"plistPath: %@", plistPath);

    NSString *error = @"";
//    NSLog(@"%@:%@ messages = %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), messages);
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:messages format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    if (plistData)
    {
        [plistData writeToFile:plistPath atomically:YES];
    }
    else
    {
        NSLog(@"error: %@", error);
    }
}

- (void)addMessage:(Message *)message
{
    ChatItem *item;
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateStyle:NSDateFormatterNoStyle];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    [timeFormatter setLocale:locale];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setLocale:locale];
    
    NSString *dateStr = [dateFormatter stringFromDate:message.date];
    if (!recentDateStr || ![recentDateStr isEqualToString:dateStr])
    {
        item = [[ChatItem alloc] init];
        item.type = ChatItemType_date;
        item.dateStr = dateStr;
        [chatList addObject:item];
        recentDateStr = dateStr;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    item = [[ChatItem alloc] init];
    if ([message.userID isEqualToString:appDelegate.myUserID])
    {
        item.type = ChatItemType_fromMe;
    }
    else
    {
        item.type = ChatItemType_fromFriend;
        item.user = [appDelegate getUser:message.userID];
    }
    item.content = message.text;
    item.timeStr = [timeFormatter stringFromDate:message.date];
    
    [chatList addObject:item];
    
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:message.userID, @"UserID", message.text, @"Message", message.date, @"Date", nil];
    //NSLog(@"dic: %@", [dic description]);
    [messages addObject:dic];
    
    messageAdded = YES;
    
    [myTableView reloadData];
    [self scrollToBottom];
}

#pragma mark - notification handlers

- (void)onReceiveData:(NSNotification *)aNotification
{
    NSDictionary *dic = [aNotification userInfo];
    NSString *matchID = [dic objectForKey:@"MatchID"];
    if ([matchID longLongValue] == match->matchId())
    {
        Message *message = [dic objectForKey:@"Message"];
        [self performSelectorOnMainThread:@selector(addMessage:) withObject:message waitUntilDone:NO];
    }
}

@end
