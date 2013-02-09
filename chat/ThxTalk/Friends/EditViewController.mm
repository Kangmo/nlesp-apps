//
//  EditViewController.m
//  ThxTalk
//
//  Created by 민경 장 on 12. 9. 21..
//  Copyright (c) 2012년 민경 장. All rights reserved.
//

#import "EditViewController.h"
#import "User.h"
#import "AppDelegate.h"
#import "VKLocalPlayer.h"
#import "LocalPlayerHandlers.h"
#import "NotificationNames.h"
#import "ViewControllerUtil.h"

@interface EditViewController ()
{
    User *profile;
    int maxLength;
    ViewControllerUtil *util;
}
@end

@implementation EditViewController

@synthesize isName, infoLabel, textField, charNumLabel, doneButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    profile = ((AppDelegate *)[UIApplication sharedApplication].delegate).myProfile;
    if (isName)
    {
        self.title = @"이름";
        infoLabel.text = @"본인 이름을 입력해주세요.";
        textField.text = profile.name;
        maxLength = 20;
    }
    else
    {
        self.title = @"상태메시지";
        infoLabel.text = @"상태메시지를 입력해주세요.";
        textField.text = profile.status;
        maxLength = 60;
    }
    [self checkText];
    [textField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    textField.delegate = self;
    
    // setup util
    util = [[ViewControllerUtil alloc] init];
    [self.view addSubview:util.indicator];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)checkText
{
    NSString *stringToCompare;
    if (isName)
    {
        stringToCompare = profile.name;
    }
    else
    {
        stringToCompare = profile.status;
    }
    
    if ((textField.text.length == 0) ||
        ([textField.text isEqualToString:stringToCompare]))
    {
        doneButton.enabled = NO;
    }
    else
    {
        doneButton.enabled = YES;
    }
    charNumLabel.text = [NSString stringWithFormat:@"%d / %d자", textField.text.length, maxLength];
}

- (void)textFieldChanged:(id)sender
{
    [self checkText];
}

- (BOOL)textField:(UITextField *)_textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [_textField.text length] + [string length] - range.length;
    return (newLength > maxLength) ? NO : YES;
}

- (IBAction)doneButtonPressed:(id)sender
{
    BOOL changed = NO;
    if (isName)
    {
        if (![profile.name isEqualToString:textField.text])
        {
            changed = YES;
            profile.name = textField.text;
        }
    }
    else
    {
        if (![profile.status isEqualToString:textField.text])
        {
            changed = YES;
            profile.status = textField.text;
        }
    }
    
    // update to server
    if (changed)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdateUserProfile:) name:VKLocalPlayerDidOnUpdateUserProfileCalledNotification object:nil];
        [util showIndicator];
        
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
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onUpdateUserProfile:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VKLocalPlayerDidOnUpdateUserProfileCalledNotification object:nil];
    [self performSelectorOnMainThread:@selector(hideIndicator) withObject:nil waitUntilDone:NO];
    
    // check error
    NSString *error = [[aNotification userInfo] objectForKey:@"Error"];
    if (error != nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"정보 업데이트 실패" message:error delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
        [self performSelectorOnMainThread:@selector(showAlert:) withObject:alert waitUntilDone:NO];
    }
    
    [self performSelectorOnMainThread:@selector(popViewcontroller) withObject:nil waitUntilDone:NO];
}


- (void)hideIndicator
{
    [util hideIndicator];
}

- (void)showAlert:(UIAlertView *)alert
{
    [alert show];
}

- (void)popViewcontroller
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
