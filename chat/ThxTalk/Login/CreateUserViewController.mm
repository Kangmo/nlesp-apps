//
//  CreateUserViewController.m
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 11..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import "CreateUserViewController.h"
#import "VKLocalPlayer.h"
#import "LocalPlayerHandlers.h"
#import "NotificationNames.h"
#import "ViewControllerUtil.h"

@interface CreateUserViewController ()
{
    ViewControllerUtil *util;
}
@end

@implementation CreateUserViewController

@synthesize nameField, emailField, pw2Field, pwField, button;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // setup util
    util = [[ViewControllerUtil alloc] init];
    [self.view addSubview:util.indicator];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//}

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

#pragma mark - UI Action

/*
 This function is called when the user touches '회원 가입' button.
 */
- (void)buttonPressed:(id)sender
{
    // hide keyboard
    if ([nameField isFirstResponder])
    {
        [nameField resignFirstResponder];
    }
    else if ([emailField isFirstResponder])
    {
        [emailField resignFirstResponder];
    }
    else if ([pwField isFirstResponder])
    {
        [pwField resignFirstResponder];
    }
    else if ([pw2Field isFirstResponder])
    {
        [pw2Field resignFirstResponder];
    }

    // check password
    if ((pwField.text.length > 0) && [pwField.text isEqualToString:pw2Field.text])
    {
        [self createUser];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"비밀번호를 동일하게 입력하세요" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
        [alert show];
        pwField.text = @"";
        pw2Field.text = @"";
    }
}

- (void)createUser
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCreateUserProfile:) name:VKLocalPlayerDidOnCreateUserProfileCalledNotification object:nil];
    
    VKLocalPlayer * localPlayer = VKLocalPlayer::localPlayer();
    VKLocalPlayer::TxUserProfile profile;
    profile.email = emailField.text.UTF8String;
    profile.encryptedPassword = pwField.text.UTF8String;
    profile.name = nameField.text.UTF8String;
    
    LocalPlayerHandlers *handler = LocalPlayerHandlers::sharedInstance();
    localPlayer->createUserProfile(profile, handler);
    
    [util showIndicator];
}

#pragma mark - server response

- (void)onCreateUserProfile:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VKLocalPlayerDidOnCreateUserProfileCalledNotification object:nil];
    [self performSelectorOnMainThread:@selector(hideIndicator) withObject:nil waitUntilDone:NO];

    // check error
    NSString *error = [[aNotification userInfo] objectForKey:@"Error"];
    if (error != nil)
    {
        NSLog(@"%@:%@ error = %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"회원 가입 실패" message:error delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
        [self performSelectorOnMainThread:@selector(showAlert:) withObject:alert waitUntilDone:NO];
    }
    else
    {
        NSString *userID = [[aNotification userInfo] objectForKey:@"UserID"];
        NSLog(@"%@:%@ user id = %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), userID);
        [[NSUserDefaults standardUserDefaults] setValue:userID forKey:@"UserID"];
        [[NSUserDefaults standardUserDefaults] setValue:emailField.text forKey:@"Email"];
        [[NSUserDefaults standardUserDefaults] setValue:pwField.text forKey:@"Password"];
        
        [self performSelectorOnMainThread:@selector(dismissSelf) withObject:nil waitUntilDone:NO];
    }
}

- (void)dismissSelf
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)hideIndicator
{
    [util hideIndicator];
}

- (void)showAlert:(UIAlertView *)alert
{
    [alert show];
}

@end
