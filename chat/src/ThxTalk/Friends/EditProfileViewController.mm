//
//  EditProfileViewController.m
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 21..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import "EditProfileViewController.h"
#import "EditProfileCell.h"
#import "AppDelegate.h"
#import "EditViewController.h"
#import "VKLocalPlayer.h"
#import "LocalPlayerHandlers.h"
#import "NotificationNames.h"
#import "ViewControllerUtil.h"

@interface EditProfileViewController ()
{
    User *profile;
    UIButton *photoButton;
    ViewControllerUtil *util;
}
@end

@implementation EditProfileViewController

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
    
    profile = ((AppDelegate *)[UIApplication sharedApplication].delegate).myProfile;
    
    // setup util
    util = [[ViewControllerUtil alloc] init];
    [self.view addSubview:util.indicator];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
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
        return 1;
    }
    else
    {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0)
    {
        EditProfileCell *profileCell = [tableView dequeueReusableCellWithIdentifier:@"EditProfileCell"];
        profileCell.IDLabel.text = profile.email;
        [profileCell.button setImage:profile.photo forState:UIControlStateNormal];
        [profileCell.button addTarget:self action:@selector(changePhoto:) forControlEvents:UIControlEventTouchUpInside];
        photoButton = profileCell.button;
        cell = profileCell;
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell"];
        if (indexPath.row == 0)
        {
            cell.textLabel.text = profile.name;
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = profile.status;
        }
        else
        {
            NSAssert(YES, @"wrong indexpath");
        }
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"";
    }
    else
    {
        return @"이름 & 상태메시지";
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 120;
    }
    else
    {
        return 44;
    }
}


#pragma mark - UI action

- (IBAction)closeButtonPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)changePhoto:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"취소" destructiveButtonTitle:nil otherButtonTitles:@"사진촬영",@"앨범에서 사진 선택", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}


#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    EditViewController *viewController = (EditViewController *)segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath.row == 0)
    {
        viewController.isName = YES;
    }
    else
    {
        viewController.isName = NO;
    }
}

#pragma mark -
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) // take a photo
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.delegate = (id)self;
            imagePicker.allowsEditing = YES;
            [self presentModalViewController:imagePicker animated:YES];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"카메라를 사용할 수 없습니다." delegate:nil cancelButtonTitle:nil otherButtonTitles: @"확인", nil];
            [alert show];
        }
    }
    else if (buttonIndex == 1) // select a photo
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.delegate = (id)self;
            imagePicker.allowsEditing = YES;
            [self presentModalViewController:imagePicker animated:YES];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"사진을 선택할 수 없습니다." delegate:nil cancelButtonTitle:nil otherButtonTitles: @"확인", nil];
            [alert show];
        }
    }
    else // cancel
    {
        
    }
}

#pragma mark -
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
    [photoButton setImage:image forState:UIControlStateNormal];
    profile.photo = image;
    [self updatePhoto];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -
#pragma mark - update

- (void)updatePhoto
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdateUserProfile:) name:VKLocalPlayerDidOnUpdateUserProfileCalledNotification object:nil];
    
    VKLocalPlayer * localPlayer = VKLocalPlayer::localPlayer();
    LocalPlayerHandlers *handler = LocalPlayerHandlers::sharedInstance();

    VKLocalPlayer::TxUserProfile userProfile;
    userProfile.uid = profile.userID.UTF8String;
    userProfile.email = profile.email.UTF8String;
    userProfile.name = profile.name.UTF8String;
    userProfile.statusMessage = profile.status.UTF8String;
    NSData *imageData = UIImageJPEGRepresentation(profile.photo, 1.0);
    TxImage txImage((void*)imageData.bytes, imageData.length);
    userProfile.photo = txImage;
    
    localPlayer->updateUserProfile(userProfile, handler);
    [util showIndicator];
}

- (void)onUpdateUserProfile:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VKLocalPlayerDidOnUpdateUserProfileCalledNotification object:nil];
    [self performSelectorOnMainThread:@selector(hideIndicator) withObject:nil waitUntilDone:NO];
    
    // check error
    NSString *error = [[aNotification userInfo] objectForKey:@"Error"];
    if (error != nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"사진 업데이트 실패" message:error delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
        [self performSelectorOnMainThread:@selector(showAlert:) withObject:alert waitUntilDone:NO];
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

@end
