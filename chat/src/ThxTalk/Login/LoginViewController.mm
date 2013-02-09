//
//  LoginViewController.m
//  ThxTalk
//
//  Created by 민경 장 on 12. 10. 29..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import "LoginViewController.h"
#import "VKLocalPlayer.h"
#import "LocalPlayerHandlers.h"
#import "NotificationNames.h"
#import "ViewControllerUtil.h"
#import "ConvertUtils.h"

@interface LoginViewController ()
{
    ViewControllerUtil *util;
}
@end

@implementation LoginViewController

@synthesize emailField, pwField, button;


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
    if ([emailField isFirstResponder])
    {
        [emailField resignFirstResponder];
    }
    else if ([pwField isFirstResponder])
    {
        [pwField resignFirstResponder];
    }
    
    // check password
    if (pwField.text.length > 0)
    {
        [self login];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"비밀번호를 입력하세요" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
        [alert show];
    }
}

- (void)login
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAuthenticate:) name:VKLocalPlayerDidOnAuthenticateCalledNotification object:nil];
    
    VKLocalPlayer * localPlayer = VKLocalPlayer::localPlayer();
    LocalPlayerHandlers *handler = LocalPlayerHandlers::sharedInstance();
    NSString *email = emailField.text;
    NSString *pw = pwField.text;
    localPlayer->authenticate(email.UTF8String, pw.UTF8String, handler);
}

#pragma mark - server response

- (void)onAuthenticate:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VKLocalPlayerDidOnAuthenticateCalledNotification object:nil];
    [self performSelectorOnMainThread:@selector(hideIndicator) withObject:nil waitUntilDone:NO];
    
    // check error
    NSString *error = [[aNotification userInfo] objectForKey:@"Error"];
    if (error != nil)
    {
        NSLog(@"%@:%@ error = %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"로그인 실패" message:error delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
        [self performSelectorOnMainThread:@selector(showAlert:) withObject:alert waitUntilDone:NO];
    }
    else
    {
        NSLog(@"%@:%@ sucessfully authenticated", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        VKLocalPlayer * localPlayer = VKLocalPlayer::localPlayer();
        NSString *userID = convertTxStringToNSString(localPlayer->playerID());
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
