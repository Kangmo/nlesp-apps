//
//  FriendListViewController.m
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 19..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import "FriendListViewController.h"
#import "User.h"
#import "UserCell.h"
#import "AppDelegate.h"
#import "ProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "LocalPlayerHandlers.h"
#import "VKLocalPlayer.h"
#import "NotificationNames.h"
#import "ViewControllerUtil.h"

@interface FriendListViewController ()
{
    NSMutableArray *friendList;
    ViewControllerUtil *util;
}
- (void)deleteFriend:(User *)user;

@end

@implementation FriendListViewController

@synthesize showEditProfile;

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
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    friendList = [[NSMutableArray alloc] init];
    
    showEditProfile = NO;
    
    // setup util
    util = [[ViewControllerUtil alloc] init];
    [self.view addSubview:util.indicator];
    
    // request data
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestFinished:) name:AppDelegateRequestDataFinishedNotification object:nil];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate requestData];
    [util showIndicator];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%@:%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%@:%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    if (showEditProfile)
    {
        UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileNavigationController"];
        [self presentViewController:navController animated:YES completion:nil];
    }
    showEditProfile = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
        User *user = ((AppDelegate *)[UIApplication sharedApplication].delegate).myProfile;
        if (user)
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
    else
    {
        return friendList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserCell *cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    User *user;
    
    if (indexPath.section == 0)
    {
        user = ((AppDelegate *)[UIApplication sharedApplication].delegate).myProfile;
    }
    else
    {
        user = (User *)[friendList objectAtIndex:indexPath.row];
    }
    
    if (user)
    {
        cell.imageView.image = user.photo;
        cell.nameLabel.text = user.name;
        cell.statusLabel.text = user.status;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"내 프로필";
    }
    else
    {
        return @"친구";
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        User *user = (User *)[friendList objectAtIndex:indexPath.row];
        [self deleteFriend:user];
        [friendList removeObjectAtIndex:indexPath.row];
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

#pragma mark -
#pragma mark segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowProfile"])
    {
        ProfileViewController *viewController = (ProfileViewController *)segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if (indexPath.section == 0)
        {
            viewController.user = ((AppDelegate *)[UIApplication sharedApplication].delegate).myProfile;
            viewController.isMyProfile = YES;
        }
        else
        {
            viewController.user = (User *)[friendList objectAtIndex:indexPath.row];
            viewController.isMyProfile = NO;
        }
        
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        UIGraphicsBeginImageContext(delegate.window.frame.size);
        [delegate.window.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *imageForBackgroundView=[[UIImageView alloc] initWithFrame:CGRectMake(0, -20, 320, 480)];
        [imageForBackgroundView setImage:viewImage];
        imageForBackgroundView.hidden = YES;
        [viewController.view insertSubview:imageForBackgroundView atIndex:0];
    }
}

- (void)deleteFriend:(User *)user
{
    NSLog(@"delete %@", user.name);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCancelFriend:) name:VKLocalPlayerDidOnCancelFriendCalledNotification object:nil];
    
    VKLocalPlayer * localPlayer = VKLocalPlayer::localPlayer();
    LocalPlayerHandlers *handler = LocalPlayerHandlers::sharedInstance();
    
    localPlayer->cancelFriend(user.userID.UTF8String, handler);
    [util showIndicator];
}

- (void)onCancelFriend:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VKLocalPlayerDidOnCancelFriendCalledNotification object:nil];
    [self performSelectorOnMainThread:@selector(hideIndicator) withObject:nil waitUntilDone:NO];
    
    NSString *error = [[aNotification userInfo] objectForKey:@"Error"];
    if (error != nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"친구 삭제 실패" message:error delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
        [self performSelectorOnMainThread:@selector(showAlert:) withObject:alert waitUntilDone:NO];
    }
}

- (void)requestFinished:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AppDelegateRequestDataFinishedNotification object:nil];
    [self performSelectorOnMainThread:@selector(hideIndicator) withObject:nil waitUntilDone:NO];
    
    // check error
    NSString *error = [[aNotification userInfo] objectForKey:@"Error"];
    if (error != nil)
    {
        NSLog(@"%@:%@ error = %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"친구 리스트 가져오기 실패" message:error delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
        [self performSelectorOnMainThread:@selector(showAlert:) withObject:alert waitUntilDone:NO];
    }
    else
    {
        friendList = ((AppDelegate *)[UIApplication sharedApplication].delegate).friendList;
        [self performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
    }
}

- (void)hideIndicator
{
    [util hideIndicator];
}

- (void)showAlert:(UIAlertView *)alert
{
    [alert show];
}

- (void)reloadTable
{
    [self.tableView reloadData];
}

@end
